import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as http_io;
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

final _log = Logger('graph_and_grid_demo');

// --------------------------------------------------------------------------
// Exceptions
// --------------------------------------------------------------------------

class TestFailure implements Exception {
  final String message;

  TestFailure(this.message);

  @override
  String toString() => message;
}

// --------------------------------------------------------------------------
// Polymath config
// --------------------------------------------------------------------------

class PolymathConfig {
  final bool apiActive;
  final int port;

  PolymathConfig({required this.apiActive, required this.port});

  static PolymathConfig load() {
    final file = File(_configPath());

    if (!file.existsSync()) {
      throw TestFailure('Config file not found: ${file.path}');
    }

    final json = jsonDecode(file.readAsStringSync());

    if (json['apiActive'] != true) {
      throw TestFailure('Polymath API is not active');
    }

    return PolymathConfig(apiActive: json['apiActive'], port: json['openPort']);
  }

  static String folderName = 'flux';

  static p.Context contextFor(String operatingSystem) => p.Context(
    style: operatingSystem == 'windows' ? p.Style.windows : p.Style.posix,
  );

  static String? _windowsLocalAppData(p.Context ctx, Map<String, String> env) {
    final profile = envValue(env, 'USERPROFILE');
    return envValue(env, 'LOCALAPPDATA') ??
        (profile == null ? null : ctx.join(profile, 'AppData', 'Local'));
  }

  static String? envValue(Map<String, String> env, String key) {
    final value = env[key];
    return (value == null || value.isEmpty) ? null : value;
  }

  static String desktopRoot({
    required String operatingSystem,
    required Map<String, String> env,
    String? packageFamilyName,
  }) {
    switch (operatingSystem) {
      case 'windows':
        final ctx = contextFor(operatingSystem);
        final local = _windowsLocalAppData(ctx, env);
        if (local == null) {
          throw StateError(
            'Neither LOCALAPPDATA nor USERPROFILE is set; cannot place the Flux data folder',
          );
        }
        final base = (packageFamilyName == null || packageFamilyName.isEmpty)
            ? local
            : ctx.join(local, 'Packages', packageFamilyName, 'LocalState');
        return ctx.normalize(ctx.join(base, folderName));
      case 'macos':
        final home = envValue(env, 'HOME');
        if (home == null)
          throw StateError(
            'HOME is not set; cannot place the Flux data folder',
          );
        // path_provider's Application Support folder appends the bundle id.
        return p.posix.normalize(
          p.posix.join(home, 'Library', 'Application Support', folderName),
        );
      case 'linux':
        // The XDG base directory spec ignores a relative XDG_DATA_HOME.
        final xdg = envValue(env, 'XDG_DATA_HOME');
        final home = envValue(env, 'HOME');
        final base = (xdg != null && p.posix.isAbsolute(xdg))
            ? xdg
            : (home == null ? null : p.posix.join(home, '.local', 'share'));
        if (base == null)
          throw StateError(
            'Neither XDG_DATA_HOME nor HOME is set; cannot place the Flux data folder',
          );
        return p.posix.normalize(p.posix.join(base, folderName));
      default:
        throw ArgumentError.value(
          operatingSystem,
          'operatingSystem',
          'No Flux data root defined',
        );
    }
  }

  static String _configPath() {
    return p.join(
      desktopRoot(
        operatingSystem: Platform.operatingSystem,
        env: Platform.environment,
      ),
      'config',
      'keys.json',
    );
  }
}

// --------------------------------------------------------------------------
// TLS
// --------------------------------------------------------------------------

class TlsHelper {
  static SecurityContext createContext() {
    final context = SecurityContext(withTrustedRoots: true);

    final certPath = switch (Platform.operatingSystem) {
      'linux' =>
        '${Platform.environment['HOME']}/.local/share/com.fluxkeyboard.polymath/tls/cert.pem',

      'macos' =>
        '${Platform.environment['HOME']}/Library/Application Support/com.flux.polymath/tls/cert.pem',

      'windows' =>
        '${Platform.environment['APPDATA']}\\com.fluxkeyboard\\polymath\\tls\\cert.pem',

      _ => throw UnsupportedError('Unsupported platform'),
    };

    final cert = File(certPath);

    if (!cert.existsSync()) {
      throw TestFailure('TLS certificate missing: $certPath');
    }

    context.setTrustedCertificates(cert.path);

    return context;
  }
}

// --------------------------------------------------------------------------
// API Client
// --------------------------------------------------------------------------

class ApiClient {
  final String baseUrl;

  late final http_io.IOClient _client;

  ApiClient(this.baseUrl) {
    _client = http_io.IOClient(HttpClient(context: TlsHelper.createContext()));
  }

  Future<http.Response> get(
    String path, {
    String? apiKey,
    String application = 'ManualTest',
  }) {
    return _client.get(
      Uri.parse('$baseUrl$path'),
      headers: _headers(application, apiKey),
    );
  }

  Future<http.Response> post(
    String path, {
    String? apiKey,
    String application = 'ManualTest',
    Map<String, dynamic>? body,
  }) {
    return _client.post(
      Uri.parse('$baseUrl$path'),
      headers: {
        ..._headers(application, apiKey),
        'Content-Type': 'application/json',
      },
      body: body == null ? null : jsonEncode(body),
    );
  }

  Future<http.Response> put(
    String path, {
    String? apiKey,
    String application = 'ManualTest',
    Map<String, dynamic>? body,
  }) {
    return _client.put(
      Uri.parse('$baseUrl$path'),
      headers: {
        ..._headers(application, apiKey),
        'Content-Type': 'application/json',
      },
      body: body == null ? null : jsonEncode(body),
    );
  }

  Map<String, String> _headers(String application, String? apiKey) {
    return {
      'Accept': 'application/json',
      'User-Agent': application,
      if (apiKey != null) 'Authorization': 'Bearer $apiKey',
    };
  }

  void close() {
    _client.close();
  }
}

// --------------------------------------------------------------------------
// Tests
// --------------------------------------------------------------------------

class Demo {
  final ApiClient client;
  String? id;
  final List<String> ids = [];
  List<String> colors = [];
  List<String> subEndings = [];
  List<double> graphMinBounds = [];
  List<double> graphMaxBounds = [];

  String _colorForInitialValues(List<double> values) {
    if (values.isEmpty) return 'Green';
    final first = values.first;
    final last = values.last;
    return last >= first ? 'Green' : 'Red';
  }

  Demo(this.client);

  Future<String> run() async {
    String? key;

    await _testDocs();

    bool validKey = false;

    final savedKeyPath = p.join(
      PolymathConfig.desktopRoot(
        operatingSystem: Platform.operatingSystem,
        env: Platform.environment,
      ),
      'key.txt',
    );
    File keyFile = File(savedKeyPath);

    if (await keyFile.exists()) {
      key = await keyFile.readAsString();

      if (await _testAuthentication(key)) {
        validKey = true;
      }
    } else {
      await keyFile.create();
    }

    if (!validKey) {
      key = await _testRegistration();

      await _testAuthentication(key);

      await keyFile.writeAsString(key);
    }
    if (key == null) {
      throw ('API key doesn\'t exist');
    }
    await _stocksData(key, 20);

    await _gardenData(key, 20);
    await _factorioData(key, 20);

    return key;
  }

  Future<void> _stocksData(String key, int seconds) async {
    final stockSymbols = ['AAPL', 'MSFT', 'NVDA'];
    final initialValues = [
      List<double>.generate(60, (index) {
        final swing = sin(index / 10.5) * 1.1;
        final drift = index * 0.05;
        final noise = ((index % 5) - 2) * 0.14;
        final value = (188.5 + drift + swing + noise).clamp(184.0, 194.0);
        return (value * 100).roundToDouble() / 100;
      }),
      List<double>.generate(60, (index) {
        final swing = sin(index / 11.0) * 1.3;
        final drift = index * 0.07;
        final noise = ((index % 6) - 2.5) * 0.18;
        final value = (332.0 + drift + swing + noise).clamp(324.0, 340.0);
        return (value * 100).roundToDouble() / 100;
      }),
      List<double>.generate(60, (index) {
        final swing = sin(index / 9.8) * 0.9;
        final drift = index * 0.04;
        final noise = ((index % 4) - 1.5) * 0.12;
        final value = (124.8 + drift + swing + noise).clamp(120.5, 132.0);
        return (value * 100).roundToDouble() / 100;
      }),
    ];

    final gridValues = [
      {'title': 'AMZN', 'value': '184.20', 'subTitle': '+1.8%'},
      {'title': 'GOOG', 'value': '174.60', 'subTitle': '+0.9%'},
      {'title': 'META', 'value': '512.30', 'subTitle': '+2.1%'},
      {'title': 'TSLA', 'value': '242.15', 'subTitle': '-0.6%'},

      {'title': 'NFLX', 'value': '631.90', 'subTitle': '+1.4%'},
      {'title': 'AMD', 'value': '164.80', 'subTitle': '+2.7%'},
    ];
    final stockMinY = initialValues
        .map((series) => series.reduce((a, b) => a < b ? a : b))
        .toList();
    graphMinBounds = List<double>.from(stockMinY);
    graphMaxBounds = List<double>.filled(stockMinY.length, 0.0);

    await _startAdData(
      graphTitles: stockSymbols,
      initialValues: initialValues,
      key: key,
      leadingSymbol: '\$',
      minY: stockMinY,
      startAtZero: false,
      gridPayload: {
        'title': 'Summary',
        'type': 2,
        'index': 3,
        'gridConfig': gridValues.length,
        for (int i = 0; i < gridValues.length; i++)
          'grid${i + 1}': {
            'title': gridValues[i]['title'],
            'value': gridValues[i]['value'],
            'subTitle': gridValues[i]['subTitle'],
          },
      },
    );

    await _sendGraphUpdates(
      graphTitles: stockSymbols,
      gridTitles: gridValues.map((cell) => cell['title'] as String).toList(),
      graphValues: [
        initialValues[0].last,
        initialValues[1].last,
        initialValues[2].last,
      ],
      gridValues: gridValues
          .map((cell) => double.parse(cell['value'] as String))
          .toList(),
      updateCycles: seconds,
      key: key,
      leadingSymbol: '\$',
      minY: graphMinBounds,
      startAtZero: false,
      initialValues: [
        initialValues[0].first,
        initialValues[1].first,
        initialValues[2].first,
      ],
    );
  }

  Future<void> _gardenData(String key, int seconds) async {
    final initialColors = ['Orange', 'Blue', 'Green'];
    colors = initialColors;

    final subTitleEndings = ['%', '%', ''];
    subEndings = subTitleEndings;

    final gardenTitles = ['Sunlight', 'Soil Humidity', 'Soil PH'];
    final initalGardenValues = [
      List<double>.generate(60, (index) {
        final swing = sin(index / 10.5) * 1.1;
        final drift = index * 0.05;
        final noise = ((index % 5) - 2) * 0.14;
        final value = (65.72 + drift + swing + noise).clamp(52, 75);
        return (value * 100).roundToDouble() / 100;
      }),
      List<double>.generate(60, (index) {
        final swing = sin(index / 11.0) * 1.3;
        final drift = index * 0.07;
        final noise = ((index % 6) - 2.5) * 0.18;
        final value = (23.42 + drift + swing + noise).clamp(20, 30);
        return (value * 100).roundToDouble() / 100;
      }),
      List<double>.generate(60, (index) {
        final swing = sin(index / 9.8) * 0.9;
        final drift = index * 0.04;
        final noise = ((index % 4) - 1.5) * 0.12;
        final value = (6.32 + drift + swing + noise).clamp(6, 7.2);
        return (value * 100).roundToDouble() / 100;
      }),
    ];

    final gardenGridValues = [
      {'title': 'Potatoes', 'value': '19', 'unit': '%', 'subTitle': 'Humidity'},
      {
        'title': 'Carrots',
        'value': '16.32',
        'unit': '%',
        'subTitle': 'Humidity',
      },
      {
        'title': 'Zucchini',
        'value': '21.43',
        'unit': '%',
        'subTitle': 'Humidity',
      },
      {
        'title': 'Lettuce',
        'value': '18.21',
        'unit': '%',
        'subTitle': 'Humidity',
      },
      {
        'title': 'Onions',
        'value': '25.31',
        'unit': '%',
        'subTitle': 'Humidity',
      },
      {
        'title': 'Cucumbers',
        'value': '24.76',
        'unit': '%',
        'subTitle': 'Humidity',
      },
    ];

    final gardenMinY = [0.0, 0.0, 0.0];
    final gardenMaxY = [100.0, 100.0, 14.0];
    graphMinBounds = List<double>.from(gardenMinY);
    graphMaxBounds = List<double>.from(gardenMaxY);

    await _startAdData(
      graphTitles: gardenTitles,
      initialValues: initalGardenValues,
      endingSymbol: '%',
      removeEndings: [2],
      key: key,
      minY: gardenMinY,
      maxY: gardenMaxY,
      startAtZero: true,
      gridPayload: {
        'title': 'Summary',
        'type': 2,
        'index': 3,
        'gridConfig': gardenGridValues.length,
        for (int i = 0; i < gardenGridValues.length; i++)
          'grid${i + 1}': {
            'title': gardenGridValues[i]['title'],
            'value': gardenGridValues[i]['value'],
            'unit': gardenGridValues[i]['unit'],
            'subTitle': gardenGridValues[i]['subTitle'],
          },
      },
    );

    await _sendGraphUpdates(
      graphTitles: gardenTitles,
      gridTitles: gardenGridValues
          .map((cell) => cell['title'] as String)
          .toList(),
      gridSubTitles: gardenGridValues
          .map((cell) => cell['subTitle'] as String)
          .toList(),
      endingSymbol: '%',
      removeEndings: [2],
      graphValues: [
        initalGardenValues[0].last,
        initalGardenValues[1].last,
        initalGardenValues[2].last,
      ],
      gridValues: gardenGridValues
          .map((cell) => double.parse(cell['value'] as String))
          .toList(),
      updateCycles: seconds,
      key: key,
      colorCoded: false,
      minY: graphMinBounds,
      maxY: graphMaxBounds,
      startAtZero: true,
    );
  }

  Future<void> _factorioData(String key, int seconds) async {
    final initialColors = ['Blue', 'Lime', 'Green'];
    colors = initialColors;

    final subTitleEndings = ['/min', '/min', 'kWh'];
    subEndings = subTitleEndings;

    final factorioTitle = ['Processing unit', 'Rocket Fuel', 'Power Usage'];
    final initalFactorioValues = [
      List<double>.generate(60, (index) {
        final swing = sin(index / 10.5) * 1.1;
        final drift = index * 0.05;
        final noise = ((index % 5) - 2) * 0.14;
        final value = (500 + drift + swing + noise).clamp(450, 750);
        return (value * 100).roundToDouble() / 100;
      }),
      List<double>.generate(60, (index) {
        final swing = sin(index / 11.0) * 1.3;
        final drift = index * 0.07;
        final noise = ((index % 6) - 2.5) * 0.18;
        final value = (200 + drift + swing + noise).clamp(150, 300);
        return (value * 100).roundToDouble() / 100;
      }),
      List<double>.generate(60, (index) {
        final swing = sin(index / 9.8) * 0.9;
        final drift = index * 0.04;
        final noise = ((index % 4) - 1.5) * 0.12;
        final value = (1143 + drift + swing + noise).clamp(500, 2000);
        return (value * 100).roundToDouble() / 100;
      }),
    ];

    final factorioGridValues = [
      {'title': 'Automation', 'value': '240', 'unit': '', 'subTitle': '+1.8%'},
      {'title': 'Logistic', 'value': '210', 'unit': '', 'subTitle': '+0.9%'},
      {'title': 'Chemical', 'value': '185', 'unit': '', 'subTitle': '+2.1%'},
      {'title': 'Production', 'value': '180', 'unit': '', 'subTitle': '-0.6%'},
      {'title': 'Utility', 'value': '150', 'unit': '', 'subTitle': '+1.4%'},
      {'title': 'Space', 'value': '100', 'unit': '', 'subTitle': '+2.7%'},
    ];

    final factorioMinY = [0.0, 0.0, 0.0];
    graphMinBounds = List<double>.from(factorioMinY);
    graphMaxBounds = [];

    await _startAdData(
      graphTitles: factorioTitle,
      initialValues: initalFactorioValues,
      key: key,
      subTitleEnding: '/min',
      minY: factorioMinY,
      startAtZero: true,
      gridPayload: {
        'title': 'Summary',
        'type': 2,
        'index': 3,
        'gridConfig': factorioGridValues.length,
        for (int i = 0; i < factorioGridValues.length; i++)
          'grid${i + 1}': {
            'title': factorioGridValues[i]['title'],
            'value': factorioGridValues[i]['value'],
            'unit': factorioGridValues[i]['unit'],
            'subTitle': factorioGridValues[i]['subTitle'],
          },
      },
    );

    await _sendGraphUpdates(
      graphTitles: factorioTitle,
      subTitleEnding: '/min',
      gridTitles: factorioGridValues
          .map((cell) => cell['title'] as String)
          .toList(),
      graphValues: [
        initalFactorioValues[0].last,
        initalFactorioValues[1].last,
        initalFactorioValues[2].last,
      ],
      gridValues: factorioGridValues
          .map((cell) => double.parse(cell['value'] as String))
          .toList(),
      updateCycles: seconds,
      key: key,
      colorCoded: false,
      minY: graphMinBounds,
      startAtZero: true,
    );
  }

  Future<void> _testDocs() async {
    final response = await client.get('/docs');

    _expectSuccess(response, 'API docs');
  }

  Future<String> _testRegistration() async {
    final response = await client.post('/authentication/register');

    _expectSuccess(response, 'API registration');

    final body = jsonDecode(response.body);

    return body['message'];
  }

  Future<bool> _testAuthentication(String key) async {
    final response = await client.get('/authentication/check', apiKey: key);

    return response.statusCode == 200;
  }

  Future<void> _startAdData({
    required List<String> graphTitles,
    required List<List<double>> initialValues,
    required String key,
    required Map<String, dynamic> gridPayload,
    List<double>? minY,
    List<double>? maxY,
    bool startAtZero = true,
    String leadingSymbol = '',
    String endingSymbol = '',
    String subTitleEnding = '',
    List<int> removeEndings = const [],
  }) async {
    final graphFutures = List<Future<String>>.generate(graphTitles.length, (
      index,
    ) async {
      final title = graphTitles[index];
      final values = initialValues[index];
      String color = '';
      if (colors.isEmpty) {
        color = _colorForInitialValues(values);
      } else {
        color = colors[index];
      }
      String subEnding;
      if (index < subEndings.length) {
        subEnding = subEndings[index];
      } else {
        subEnding = subTitleEnding;
      }

      final currentValue = (values.last * 100).roundToDouble() / 100;
      final response = await client.post(
        '/config/addGenericTile',
        body: {
          'title': title,
          'type': 1,
          'index': index,
          'length': values.length,
          'initialValues': values
              .map((value) => (value * 100).roundToDouble() / 100)
              .toList(),
          'currentValue': currentValue,
          'subTitle': '$title ${currentValue.toStringAsFixed(2)}$subEnding',
          'unit': '',
          'secondarySubtitle': '',
          'timeUnit': 'Seconds',
          'color': color,
          'leading': leadingSymbol,
          'ending': !removeEndings.contains(index) ? endingSymbol : '',
          if (minY != null) 'minY': minY[index],
          if (maxY != null) 'maxY': maxY[index],
          'startAtZero': startAtZero,
        },
        apiKey: key,
      );

      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return jsonMap['message'] as String;
    });

    final gridFuture = client.post(
      '/config/addGenericTile',
      body: gridPayload,
      apiKey: key,
    );

    await _sendAdData(key, graphFutures, gridFuture);
  }

  Future<void> _sendAdData(
    String key,
    List<Future<String>> graphFutures,
    Future<http.Response> gridFuture,
  ) async {
    ids.clear();

    ids.addAll(await Future.wait(graphFutures));

    final gridResponse = await gridFuture;

    final gridJson = jsonDecode(gridResponse.body) as Map<String, dynamic>;
    ids.add(gridJson['message'] as String);

    id = ids.isNotEmpty ? ids.last : null;
  }

  Future<void> _sendGraphUpdates({
    required List<String> graphTitles,
    required List<String> gridTitles,
    List<String> gridSubTitles = const [],
    required List<double> graphValues,
    required List<double> gridValues,
    required int updateCycles,
    required String key,
    List<double>? minY,
    List<double>? maxY,
    bool startAtZero = true,
    bool colorCoded = true,
    String leadingSymbol = '',
    String endingSymbol = '',
    String subTitleEnding = '',
    List<int> removeEndings = const [],
    List<double> initialValues = const [],
  }) async {
    final random = Random();

    for (int i = 0; i < updateCycles; i++) {
      await Future.delayed(Duration(seconds: 1));

      final updateRequests = <Future<http.Response>>[];

      for (int tileIndex = 0; tileIndex < graphTitles.length; tileIndex++) {
        final previousValue = graphValues[tileIndex];
        final drift = -1 * (random.nextDouble() - 0.5) * 0.025;
        final momentum = (random.nextDouble() - 0.5) * 0.015;
        final nextValue = (previousValue * (1 + drift + momentum)).clamp(
          0,
          9000.0,
        );
        final roundedNextValue = (nextValue * 100).roundToDouble() / 100;
        final valueDelta = initialValues.length == graphTitles.length
            ? roundedNextValue - initialValues[tileIndex]
            : roundedNextValue - previousValue;
        graphValues[tileIndex] = roundedNextValue;

        String color = '';
        String subEnding = '';

        if (colorCoded) {
          color = valueDelta >= 0 ? 'Green' : 'Red';
        } else {
          color = colors[tileIndex];
        }

        if (tileIndex < subEndings.length) {
          subEnding = subEndings[tileIndex];
        } else {
          subEnding = subTitleEnding;
        }

        final currentMinY = minY != null ? minY[tileIndex] : null;
        final currentMaxY = maxY != null ? maxY[tileIndex] : null;
        if (currentMinY != null && !startAtZero) {
          minY![tileIndex] = min(currentMinY, roundedNextValue);
        }
        if (currentMaxY != null && !startAtZero) {
          maxY![tileIndex] = currentMaxY;
        }

        final payload = {
          'id': ids[tileIndex],
          'currentValue': roundedNextValue,
          'subTitle':
              '${graphTitles[tileIndex]} ${roundedNextValue.toStringAsFixed(2)}$subEnding',
          'unit': '',
          'secondarySubtitle': '',
          'timeUnit': 'Seconds',
          'color': color,
          'leading': leadingSymbol,
          'ending': !removeEndings.contains(tileIndex) ? endingSymbol : '',
          if (minY != null) 'minY': minY[tileIndex],
          if (maxY != null) 'maxY': maxY[tileIndex],
          'startAtZero': startAtZero,
        };

        updateRequests.add(
          client.put('/config/updateGenericTile', body: payload, apiKey: key),
        );
      }

      final gridPayload = <String, dynamic>{
        'id': ids[graphTitles.length],
        'gridConfig': gridTitles.length,
      };

      for (int cell = 0; cell < gridTitles.length; cell++) {
        final previousValue = gridValues[cell];
        final percentMove = (random.nextDouble() - 0.5) * 0.045;
        final nextValue = (previousValue * (1 + percentMove)).clamp(0, 1200.0);
        final roundedNextValue = (nextValue * 100).roundToDouble() / 100;
        final delta =
            ((roundedNextValue - previousValue) / previousValue) * 100;
        gridValues[cell] = roundedNextValue;

        String label = delta >= 0
            ? '+${delta.toStringAsFixed(2)}%'
            : '${delta.toStringAsFixed(2)}%';

        if (gridSubTitles.isNotEmpty) {
          label = gridSubTitles[cell];
        }

        gridPayload['grid${cell + 1}'] = {
          'title': gridTitles[cell],
          'value': roundedNextValue.toStringAsFixed(2),
          'unit': endingSymbol,
          'subTitle': label,
        };
      }

      updateRequests.add(
        client.put('/config/updateGenericTile', body: gridPayload, apiKey: key),
      );

      await Future.wait(updateRequests);
    }
  }

  void _expectSuccess(http.Response response, String name) {
    if (response.statusCode != 200) {
      throw TestFailure(
        '$name failed (${response.statusCode}): ${response.body}',
      );
    }
  }
}

// --------------------------------------------------------------------------
// Main
// --------------------------------------------------------------------------

Future<void> main() async {
  Logger.root.level = Level.ALL;

  Logger.root.onRecord.listen((record) {
    stdout.writeln('[${record.level.name}] ${record.message}');
  });

  ApiClient? client;

  try {
    final config = PolymathConfig.load();

    client = ApiClient('https://localhost:${config.port}/v1');

    await Demo(client).run();

    exit(0);
  } catch (e, stack) {
    _log.severe(e);

    _log.severe(stack);

    exit(1);
  } finally {
    client?.close();
  }
}

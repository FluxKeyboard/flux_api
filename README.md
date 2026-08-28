# Documentation for the Flux Polymath API

<a name="ssl-info"></a>

## TLS Certificates

The Flux Polymath API uses a self signed TLS certificate. These certificates are generated at runtime and replaced as needed (when they expire, or when the local IP changes and SAN needs to be reset) so that each installation has a unique certificate. It is possible in the Polymath settings to add a domain that you wish to be attached to the TLS certificate, however all that does is allow requests from that domain. DNS, port forwarding, ect, still needs to be done outside of Polymath.

The certificates are fingerprinted to ensure no manipulation, this is to help prevent someone from accessing a user's machine and attempting a man in the middle attack. The same is also done for the API settings as a whole.

For your plugins you will need to get the certificate to create a security context in your requests. The locations are stored in the keys.json file under the key "publicKeyLocation".

Both wayland examples show how to deterministically generate the path to the config folder.


<a name="documentation-for-api-endpoints"></a>

## Documentation for API Endpoints

The API will attempt to assign themselves to port 52323, however in the event that they are unable to the OS will assign a port. The current active port is accessible in the configuration file. The examples show various ways on how to access them.

All URIs are relative to _https://localhost:PORT/v1_, _https://localIp:PORT/v1_, or depending on how you set up port forwarding, _https://customDomain/v1_ or _https://customDomain:PORT/v1_

| HTTP request                                                                                    | Description                                   |
| ----------------------------------------------------------------------------------------------- | --------------------------------------------- |
| [**GET** /authentication/check ](Apis/PolymathApi.md#authenticationcheckget)                    | Validate API key                              |
| [**POST** /authentication/register](Apis/PolymathApi.md#authenticationregisterpost)             | Register application and generate API key     |
| [**POST** /config/addIcon](Apis/PolymathApi.md#configaddiconpost)                               | Add icon(s) to configuration                  |
| [**PUT** /config/addKeystyleToAppearance](Apis/PolymathApi.md#configaddkeystyletoappearanceput) | Add keystyle(s) to appearance                 |
| [**WSS** /configChange ](Apis/PolymathApi.md#configchangeget)                                   | WebSocket session stream                      |
| [**POST** /config/import ](Apis/PolymathApi.md#configimportpost)                                | Import .flux configuration file               |
| [**POST** /config/addGenericTile ](Apis/PolymathApi.md#configGenericAddPost)            | Creates a generic module of the given type    |
| [**PUT** /config/updateGenericTile ](Apis/PolymathApi.md#configGenericUpdatePut)              | Updates the current data of a generic module  |
| [**GET** /config/keymapData](Apis/PolymathApi.md#configkeymapdataget)                           | Get keymap data                               |
| [**POST** /config/save ](Apis/PolymathApi.md#configsavepost)                                    | Save configuration to keyboard                |
| [**POST** /config/updateActiveProcess ](Apis/PolymathApi.md#configupdateactiveprocesspost)      | Update foreground active process (Linux only) |
| [**POST** /config/updateInputLanguage ](Apis/PolymathApi.md#configupdateinputlanguagepost)      | Update active input language (Linux only)     |
| [**POST** /config/updateProcesses](Apis/PolymathApi.md#configupdateprocessespost)               | Update list of active processes on Linux      |
| [**GET** /docs ](Apis/PolymathApi.md#docsget)                                                   | Link to documentation                         |

<a name="detection-overrides"></a>

## Detection overrides

On Linux, Polymath detects the foreground application and the active keyboard input language for itself. The endpoints below let your application supply those values instead, and what you send takes precedence over Polymath's own detection:

- `POST /config/updateActiveProcess`
- `POST /config/updateProcesses`
- `POST /config/updateInputLanguage`

**A value you supply is served only while your application keeps calling the API.** Polymath treats every authenticated request as a sign that you are still running. If it hears nothing from your application for 20 seconds, it discards the values you supplied and returns to detecting for itself; your next request takes over again, and the values you sent before the gap are not restored, so send them again.

Any authenticated request counts, so an application that posts more often than every 20 seconds needs to do nothing extra. One that reports only when something changes should call `GET /authentication/check` on a timer to stay live; the bundled integrations do this every 5 seconds.

<a name="documentation-for-models"></a>

## Documentation for Models

- [ActiveProcessRequest](./Models/ActiveProcessRequest.md)
- [ErrorResponse](./Models/ErrorResponse.md)
- [GenericTileAddRequest](./Models/GenericTileAddRequest.md)
- [GenericTileUpdateRequest](./Models/GenericTileUpdateRequest.md)
- [IconImportResponse](./Models/IconImportResponse.md)
- [IconRequest](./Models/IconRequest.md)
- [IconRequest_icons_inner](./Models/IconRequest_icons_inner.md)
- [ImportFileRequest](./Models/ImportFileRequest.md)
- [InputLanguageRequest](./Models/InputLanguageRequest.md)
- [ImportResponse](./Models/ImportResponse.md)
- [KeyAction](./Models/KeyAction.md)
- [KeyModel](./Models/KeyModel.md)
- [KeyStyle](./Models/KeyStyle.md)
- [Keymap](./Models/Keymap.md)
- [KeymapResponse](./Models/KeymapResponse.md)
- [KeystyleRequest](./Models/KeystyleRequest.md)
- [MessageResponse](./Models/MessageResponse.md)
- [ProcessUpdateRequest](./Models/ProcessUpdateRequest.md)
- [WebSocketMessage](./Models/WebSocketMessage.md)

<a name="documentation-for-authorization"></a>

## Documentation for Authorization

<a name="bearerAuth"></a>

### bearerAuth

- **Type**: HTTP Bearer Token authentication (API-Key)

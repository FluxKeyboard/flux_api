import Gio from "gi://Gio";
import GLib from "gi://GLib";

const BUS_NAME = "org.fluxkeyboard.InputLanguageMonitor";
const OBJECT_PATH = "/org/fluxkeyboard/InputLanguageMonitor";
const IFACE_NAME = "org.fluxkeyboard.InputLanguageMonitor";

const XML = `
<node>
  <interface name="${IFACE_NAME}">
    <signal name="InputLanguageChanged">
      <arg type="s"/>
    </signal>
    <method name="GetInputLanguage">
      <arg type="s" direction="out"/>
    </method>
  </interface>
</node>
`;

export class InputLanguageDbusManager {
  constructor() {
    this._nodeInfo = Gio.DBusNodeInfo.new_for_xml(XML);
    this._iface = this._nodeInfo.interfaces[0];
    this._conn = null;
    this._inputLanguageProvider = null;
    this._registrationId = 0;

    this._ownerId = Gio.bus_own_name(
      Gio.BusType.SESSION,
      BUS_NAME,
      Gio.BusNameOwnerFlags.NONE,
      (conn) => {
        this._conn = conn;

        this._registrationId = conn.register_object(
          OBJECT_PATH,
          this._iface,
          this._onMethodCall.bind(this),
          null,
          null,
        );

        log("[InputLanguage] Object exported");

        // The provider is usually attached before the bus is acquired,
        // so the first announcement has to wait for the connection.
        this._announceInputLanguage();
      },
      () => log("[InputLanguage] Name acquired"),
      () => log("[InputLanguage] Lost name"),
    );
  }

  // Releases the bus name and the exported object so a later enable() can re-export it.
  destroy() {
    if (this._conn && this._registrationId) {
      this._conn.unregister_object(this._registrationId);
    }

    if (this._ownerId) {
      Gio.bus_unown_name(this._ownerId);
    }

    this._registrationId = 0;
    this._ownerId = 0;
    this._inputLanguageProvider = null;
    this._conn = null;
  }

  emitInputLanguage(inputLanguage) {
    if (this._conn == null) return;

    this._conn.emit_signal(
      null,
      OBJECT_PATH,
      IFACE_NAME,
      "InputLanguageChanged",
      new GLib.Variant("(s)", [JSON.stringify(inputLanguage)]),
    );
  }

  // Polymath may start after the extension, so the current input language has to be
  // queryable rather than only announced on change.
  setInputLanguageProvider(provider) {
    this._inputLanguageProvider = provider;
    this._announceInputLanguage();
  }

  _announceInputLanguage() {
    if (this._conn == null || this._inputLanguageProvider == null) return;

    const inputLanguage = this._inputLanguageProvider();
    if (inputLanguage) {
      this.emitInputLanguage(inputLanguage);
    }
  }

  _onMethodCall(connection, sender, objectPath, interfaceName, methodName, parameters, invocation) {
    if (methodName === "GetInputLanguage") {
      const inputLanguage = this._inputLanguageProvider ? this._inputLanguageProvider() : null;

      invocation.return_value(new GLib.Variant("(s)", [JSON.stringify(inputLanguage)]));
      return;
    }

    invocation.return_error_literal(
      Gio.DBusError,
      Gio.DBusError.UNKNOWN_METHOD,
      `No such method ${methodName}`,
    );
  }
}

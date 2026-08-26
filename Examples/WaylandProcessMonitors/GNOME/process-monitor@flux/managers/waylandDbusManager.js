import Gio from "gi://Gio";
import GLib from "gi://GLib";

const BUS_NAME = "org.waylandProcessMonitor.KWin";
const OBJECT_PATH = "/waylandProcessMonitor/window";
const IFACE_NAME = "org.waylandProcessMonitor.KWin";

const XML = `
<node>
  <interface name="${IFACE_NAME}">
    <signal name="OpenAppsSnapshot">
      <arg type="s"/>
    </signal>
    <signal name="ActiveAppChanged">
      <arg type="s"/>
    </signal>
  </interface>
</node>
`;

export class WaylandDbusManager {
  constructor() {
    this._nodeInfo = Gio.DBusNodeInfo.new_for_xml(XML);
    this._iface = this._nodeInfo.interfaces[0];
    this._conn = null;
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

        log("[DBus] Object exported");
      },
      () => log("[DBus] Name acquired"),
      () => log("[DBus] Lost name"),
    );
  }

  // Without this a later enable() cannot re-export the object (GDBus refuses a
  // second export on the same path and interface), so after a screen lock the
  // object stays bound to the previous, discarded instance.
  destroy() {
    if (this._conn && this._registrationId) {
      this._conn.unregister_object(this._registrationId);
    }

    if (this._ownerId) {
      Gio.bus_unown_name(this._ownerId);
    }

    this._registrationId = 0;
    this._ownerId = 0;
    this._conn = null;
  }

  _emit(name, variant) {
    if(this._conn == null) return;
    this._conn.emit_signal(null, OBJECT_PATH, IFACE_NAME, name, variant);
  }

  emitSnapshot(windows) {
    this._emit(
      "OpenAppsSnapshot",
      new GLib.Variant("(s)", [JSON.stringify(windows)]),
    );
  }

  emitActive(cls) {
    this._emit(
      "ActiveAppChanged",
      new GLib.Variant("(s)", [JSON.stringify({ process: cls })]),
    );
  }

  _onMethodCall() {
    // no methods, required placeholder
  }
}

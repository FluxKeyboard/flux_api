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

    Gio.bus_own_name(
      Gio.BusType.SESSION,
      BUS_NAME,
      Gio.BusNameOwnerFlags.NONE,
      (conn) => {
        this._conn = conn;

        conn.register_object(
          OBJECT_PATH,
          this._iface,
          this._onMethodCall.bind(this),
          null,
          null,
        );

        log("[DBus] Object exported");
      },
      () => log("[DBus] Lost name"),
      () => log("[DBus] Name acquired"),
    );
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

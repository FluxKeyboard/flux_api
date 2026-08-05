import { WaylandDbusManager } from "./waylandDbusManager.js";
import GLib from "gi://GLib";

export class ProfileManager {
  constructor() {
    this._update = this._update.bind(this);

    this._signal = null;
    this._windows = [];
    this.dbus = new WaylandDbusManager();
    this.intervalId = -1;
  }

  start() {
    this._signal = global.display.connect("notify::focus-window", this._update);

    this.intervalId = GLib.timeout_add_seconds(
        GLib.PRIORITY_DEFAULT,
        5, 
        () => {
            this._update();

            return GLib.SOURCE_CONTINUE; 
        }
    );
    this._update();
  }

  stop() {
    if (this._signal) {
      global.display.disconnect(this._signal);
    }

    if(this.intervalId !== -1) {
      GLib.source_remove(this.intervalId);
      this.intervalId = -1;
    }
  }

  _update() {
    const win = global.display.focus_window;

    if (!win) return;

    const wmClass = win.get_wm_class();
    if (wmClass) {
      this.dbus.emitActive(wmClass);
    }
    const workspace = global.workspace_manager.get_active_workspace();

    const windows = workspace.list_windows();

    this._updateWindows(windows)

    this.dbus.emitSnapshot(this._windows);

  }

  _updateWindows(windows) {
    let processedWindows = [];

    for (const win of windows) {
      processedWindows.push(win.get_wm_class());
    }

    if (processedWindows.length !== this._windows.length) {
      this._windows = processedWindows;
      return true;
    }

    for (const win of processedWindows) {
      if (!this._windows.includes(win)) {
        this._windows = processedWindows;
        return true;
      }
    }

    this._windows = processedWindows;
    return false;
  }
}

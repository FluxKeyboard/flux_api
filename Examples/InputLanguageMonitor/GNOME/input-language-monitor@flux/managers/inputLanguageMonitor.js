import * as Keyboard from "resource:///org/gnome/shell/ui/status/keyboard.js";

import { InputLanguageDbusManager } from "./inputLanguageDbusManager.js";

// Reports the active keyboard input language to Polymath.
//
// gnome-shell only writes org.gnome.desktop.input-sources mru-sources when its
// IBus connection is up (_updateMruSettings early-returns on !this._ibusReady),
// so polling gsettings misses every layout switch on sessions where ibus-daemon
// is absent or unhealthy. The InputSourceManager's current-source-changed
// signal is emitted unconditionally, making it the only reliable source.
export class InputLanguageMonitor {
  constructor() {
    this.dbus = null;
    this._shellInputSources = null;
    this._signal = null;
  }

  start() {
    // Resolve the shell's manager before claiming the bus name, so a shell whose
    // API has moved leaves nothing exported for Polymath to talk to.
    this._shellInputSources = Keyboard.getInputSourceManager();

    this.dbus = new InputLanguageDbusManager();

    this._signal = this._shellInputSources.connect(
      "current-source-changed",
      () => this._update(),
    );

    this.dbus.setInputLanguageProvider(() => this.currentInputLanguage());

    this._update();
  }

  stop() {
    if (this._shellInputSources && this._signal) {
      this._shellInputSources.disconnect(this._signal);
    }

    this._signal = null;
    this._shellInputSources = null;

    this.dbus?.destroy();
    this.dbus = null;
  }

  // Returns { type, id } for the active source, or null if none is available.
  // For xkb sources the id is the layout identifier ('us', 'us+dvorak'), which
  // matches the format used in the input-sources gsettings keys.
  currentInputLanguage() {
    const source = this._shellInputSources?.currentSource;

    if (!source) return null;

    return { type: source.type, id: source.id };
  }

  _update() {
    const inputLanguage = this.currentInputLanguage();

    if (inputLanguage) {
      this.dbus.emitInputLanguage(inputLanguage);
    }
  }
}

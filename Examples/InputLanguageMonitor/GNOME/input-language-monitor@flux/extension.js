import { Extension } from "resource:///org/gnome/shell/extensions/extension.js";

import { InputLanguageMonitor } from "./managers/inputLanguageMonitor.js";

export default class FluxInputLanguageMonitor extends Extension {
  enable() {
    this.monitor = new InputLanguageMonitor();
    this.monitor.start();
  }

  disable() {
    this.monitor?.stop();
    this.monitor = null;
  }
}

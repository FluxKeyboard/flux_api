import { Extension } from "resource:///org/gnome/shell/extensions/extension.js";

import { ProfileManager } from "./managers/profileManager.js";

//Initial extension, starts up our process monitor
export default class WaylandProcessMonitor extends Extension {
  enable() {
    this.profileManager = new ProfileManager();

    this.profileManager.start();
  }

  disable() {
    this.profileManager?.stop();
    this.profileManager = null;
  }
}

var lastSnapshot = "";

// Creates a list of open apps to send through DBUS to our bash helper
function getOpenApps() {
    let windows = workspace.windowList();
    let arr = [];

    for (let i = 0; i < windows.length; i++) {
        let w = windows[i];

        arr.push(
            w.resourceClass,
        );
    }

    return arr;
}

function emitSnapshot() {
    let apps = getOpenApps();
    let serialized = JSON.stringify(apps);

    if (serialized === lastSnapshot)
        return;

    lastSnapshot = serialized;

    callDBus(
        "org.waylandProcessMonitor.KWin",
        "/waylandProcessMonitor/window",
        "org.waylandProcessMonitor.KWin",
        "OpenAppsSnapshot",
        serialized
    );
}

// When the window focus changes we take the window and send it through to our helper bash script
function emitActiveWindow(w) {
    if (!w) return;

    callDBus(
        "org.waylandProcessMonitor.KWin",
        "/waylandProcessMonitor/window",
        "org.waylandProcessMonitor.KWin",
        "ActiveAppChanged",
        JSON.stringify({ process: w.resourceClass })
    );

}


// On startup we send out the snapshot and active window so that Polymath can start with the most up to date information
emitSnapshot();
emitActiveWindow(workspace.activeWindow);

workspace.windowAdded.connect(function(window) {
    emitSnapshot();
});

workspace.windowRemoved.connect(function(window) {
    emitSnapshot();
});

workspace.windowActivated.connect(function(w) {
    emitActiveWindow(w);
});

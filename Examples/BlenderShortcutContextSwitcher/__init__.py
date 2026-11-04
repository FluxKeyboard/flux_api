bl_info = {
    "name": "Blender Context Polymath Updater",
    "author": "Flux",
    "version": (1, 0),
    "blender": (4, 5, 11),
    "location": "System Console",
    "description": "Sends updates about the current Blender workspace context to Polymath",
    "category": "System",
}
import bpy

from plyer import notification

from .polymathConnectionManager import PolymathConnectionManager

# If there are any messages we need to send to the user, we send them as an OS level notification through here
def notify(title, message):

    try:
        notification.notify(
            title=title,
            message=message,
            app_name="Polymath Blender Addon",
            timeout=3
        )
    except NotImplementedError:
        print(f"{title}: {message}")



_last_workspace = None
_connectionManager = PolymathConnectionManager(notify)


# The following 3 functions are how we handle workspace changes.
def get_active_workspace():
    wm = bpy.context.window_manager

    for win in wm.windows:
        if win.workspace:
            return win.workspace.name

    return None


def send_active_workspace():
    global _last_workspace

    workspace = get_active_workspace()

    if workspace and workspace != _last_workspace:
        _last_workspace = workspace

        _connectionManager.send_ws_message(workspace)


def timer_callback():
    try:
        send_active_workspace()
    except Exception as e:
        print("[Workspace Logger] Error:", e)

    return 0.5


# We have startup run as we do to help preven UI blocking
def startup():
    _connectionManager.full_restart()


def register():

    bpy.app.timers.register(startup, first_interval=1.0)
    bpy.app.timers.register(timer_callback, persistent=True)


def unregister():
    _connectionManager.stop_connection()
    if bpy.app.timers.is_registered(timer_callback):
        bpy.app.timers.unregister(timer_callback)


if __name__ == "__main__":
    register()
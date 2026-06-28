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
import os
import subprocess
import sys

# We need to ensure that certain packages are available that don't come default with Blender python. We install them here
addon_dir = os.path.abspath(os.path.dirname(__file__))

if addon_dir not in sys.path:
    sys.path.insert(0, addon_dir)

def has_pip():
    try:
        subprocess.check_output([sys.executable, "-m", "pip", "--version"])
        return True
    except Exception:
        return False

def is_installed(module_name):
    try:
        __import__(module_name)
        return True
    except ImportError:
        return False

def install_deps():
    missing = []

    for pkg in ["websockets", "keyring", "plyer"]:
        if not is_installed(pkg):
            missing.append(pkg)

    if not missing:
        return

    if not has_pip():
        print(
            "Missing dependencies",
            f"Missing {missing}, but pip is not available in Blender Python."
        )
        return

    for pkg in missing:
        try:
            subprocess.check_call([sys.executable, "-m", "pip", "install", pkg])
        except Exception as e:
            print(
                "Install failed",
                f"Failed to install {pkg}: {e}"
            )

def ensure_package(package):
    try:
        __import__(package)
    except ImportError:
        python = sys.executable 
        subprocess.check_call([
            python, "-m", "pip", "install", package
        ])

    
install_deps()




# After installing all the needed packages, we can finish importing
from polymathConnectionManager import PolymathConnectionManager
from plyer import notification

# If there are any messages we need to send to the user, we send them as an OS level notification through here
def notify(title, message):
    notification.notify(
        title=title,
        message=message,
        app_name="Polymath Blender Addon",
        timeout=3
    )


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
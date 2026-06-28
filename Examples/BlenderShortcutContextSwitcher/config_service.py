import os
import json
import platform
from pathlib import Path

# The config file is our source of truth. We use it to determine that current open port and if the API is currently active
class ConfigService:
    def get_flux_config_directory(self):
        system = platform.system()

        if system == "Linux":
            user = os.environ.get("USER", "")
            return os.path.join("/home", user, "flux", "config")

        home = str(Path.home())

        return os.path.join(home, "Documents", "flux", "config")

    def get_api_config(self):

        config_path = os.path.join(
            self.get_flux_config_directory(),
            "keys.json"
        )

        try:
            with open(config_path, "r", encoding="utf-8") as f:
                config = json.load(f)

            return {
                "apiActive": config.get("apiActive"),
                "openPort": config.get("openPort"),
            }

        except (FileNotFoundError, json.JSONDecodeError, PermissionError):
            return None
        

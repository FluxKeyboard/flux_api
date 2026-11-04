import os
import json
import platform


class ConfigService:

    def get_flux_config_directory(self):
        system = platform.system().lower()

        if system == "windows":
            local_app_data = os.environ.get("LOCALAPPDATA")

            if not local_app_data:
                user_profile = os.environ.get("USERPROFILE")
                if not user_profile:
                    raise EnvironmentError(
                        "Neither LOCALAPPDATA nor USERPROFILE is set"
                    )

                local_app_data = os.path.join(
                    user_profile, "AppData", "Local"
                )

            return os.path.join(local_app_data, "flux", "config")

        elif system == "darwin":
            home = os.environ.get("HOME")

            if not home:
                raise EnvironmentError("HOME is not set")

            return os.path.join(
                home, "Library", "Application Support", "flux", "config"
            )

        elif system == "linux":
            xdg_data_home = os.environ.get("XDG_DATA_HOME")
            home = os.environ.get("HOME")

            if xdg_data_home and os.path.isabs(xdg_data_home):
                base_directory = xdg_data_home
            elif home:
                base_directory = os.path.join(home, ".local", "share")
            else:
                raise EnvironmentError(
                    "Neither valid XDG_DATA_HOME nor HOME is set"
                )

            return os.path.join(base_directory, "flux", "config")

        else:
            raise OSError(
                f"Unsupported operating system: {platform.system()}"
            )

    def get_api_config(self):
        config_path = os.path.join(
            self.get_flux_config_directory(),
            "keys.json"
        )

        try:
            with open(config_path, "r", encoding="utf-8") as f:
                config = json.load(f)

            if config.get("apiActive") is not True:
                return None

            return {
                "apiActive": True,
                "openPort": config.get("openPort"),
                "publicKeyLocation":config.get("publicKeyLocation")
            }

        except (FileNotFoundError, json.JSONDecodeError, PermissionError):
            return None
import ssl
from pathlib import Path

from .config_service import ConfigService


class SslService:

    @staticmethod
    def get_ssl_context():
        config = ConfigService().get_api_config()

        if not config:
            raise FileNotFoundError("Polymath API configuration not found or inactive")

        cert_path = config.get("publicKeyLocation")

        if not cert_path:
            raise ValueError("SSL certificate path is missing from Polymath configuration")

        cafile = Path(cert_path).expanduser() / "cert.pem"

        if not cafile.is_file():
            raise FileNotFoundError(f"SSL certificate not found: {cafile}")

        return ssl.create_default_context(cafile=str(cafile))
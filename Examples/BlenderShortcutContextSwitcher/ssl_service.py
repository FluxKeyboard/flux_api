import ssl
import os
import sys
from pathlib import Path
import ssl

# Since the Polymath API uses a self signed certificate, we need to pull the cert from the host machine to create a security context

class SslService:
    def get_ssl_context():
        if sys.platform.startswith("win"):
            base = Path(os.environ["APPDATA"]) / "com.fluxkeyboard" / "polymath" / "tls"
        elif sys.platform == "darwin":
            base = Path.home() / "Library" / "Application Support" / "com.fluxkeyboard" / "polymath" / "tls"
        else:
            base = Path(os.environ.get("XDG_DATA_HOME", Path.home() / ".local" / "share" / "com.fluxkeyboard.polymath" / "tls"))

        base.mkdir(parents=True, exist_ok=True)

        cafile = base / "cert.pem"

        return ssl.create_default_context(cafile=str(cafile))
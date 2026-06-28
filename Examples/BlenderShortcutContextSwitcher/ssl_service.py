import ssl
import os
import sys
from pathlib import Path
import ssl

# Since the Polymath API uses a self signed certificate, we need to pull the cert from the host machine to create a security context

class SslService:
    def get_ssl_context():
        
        path = None
        if sys.platform.startswith("win"):
            path = Path(os.environ["APPDATA"]) / "Polymath" / "tls"
        elif sys.platform == "darwin":
            path = Path(os.environ["HOME"]) / "Library" / "Application Support" / "Polymath" / "tls"
        else:
            path = Path(os.environ["HOME"]) / ".config" / "Polymath" / "tls"

        return ssl.create_default_context(cafile=path / "cert.pem")
    
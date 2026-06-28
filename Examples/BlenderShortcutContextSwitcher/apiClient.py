import json
import urllib.request
import urllib.error
from ssl_service import SslService

class ApiClient:
    def __init__(self, port, api_key=None):
        self.port = port
        self.api_key = api_key

    def set_api_key(self, key):
        self.api_key = key

    def set_port(self, port):
        self.port = port

    def get(self, path):
        url = f"https://localhost:{self.port}/v1{path}"
        req = urllib.request.Request(url, method="GET")
        self._apply_headers(req)

        return self._send(req)

    def post(self, path, payload):
        url = f"https://localhost:{self.port}/v1{path}"

        data = json.dumps(payload).encode("utf-8")

        req = urllib.request.Request(
            url,
            data=data,
            method="POST",
        )

        req.add_header("Content-Type", "application/json")

        self._apply_headers(req)

        return self._send(req)

    # Barring some exceptions, all HTTP calls will require a user agent and authorization header.
    # Since it existing on the ones that don't require it isn't detrimental, we add them to every call
    def _apply_headers(self, req):
        req.add_header("User-Agent", "Polymath Blender Addon")

        if self.api_key:
            req.add_header("Authorization", f"Bearer {self.api_key}")

    def _send(self, req):
        try:
            with urllib.request.urlopen(req, context=SslService.get_ssl_context()) as response:
                raw = response.read().decode("utf-8")

                try:
                    return json.loads(raw)
                except json.JSONDecodeError:
                    return raw

        except urllib.error.HTTPError as e:
            raise Exception(e.code)
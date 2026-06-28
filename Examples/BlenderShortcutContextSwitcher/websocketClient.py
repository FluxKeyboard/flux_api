import json
import threading
import time
import websockets
import asyncio
from ssl_service import SslService



class WebSocketClient:
    def __init__(self, url, token=None, user_agent="Polymath Blender Addon"):
        self.url = url
        self.token = token
        self.user_agent = user_agent

        self.ws = None
        self.loop = None
        self.thread = None
        self.connected = False

        self._on_message = None
        self._on_open = None
        self._on_close = None


    def set_on_message(self, callback):
        self._on_message = callback

    def set_on_open(self, callback):
        self._on_open = callback

    def set_on_close(self, callback):
        self._on_close = callback


    def connect(self):
        self.thread = threading.Thread(target=self._run_loop, daemon=True)
        self.thread.start()

    def send(self, data):
        if not self.loop or not self.ws:
            return

        async def _send():
            try:
                await self.ws.send(json.dumps(data))
            except Exception as e:
                print("[WS] Send error:", e)

        asyncio.run_coroutine_threadsafe(_send(), self.loop)

    def close(self):
        if not self.loop:
            return

        async def _close():
            try:
                await self.ws.close()
            except Exception:
                pass

        asyncio.run_coroutine_threadsafe(_close(), self.loop)

    def _run_loop(self):
        self.loop = asyncio.new_event_loop()
        asyncio.set_event_loop(self.loop)

        self.loop.run_until_complete(self._main())

    async def _main(self):
        headers = {
            "User-Agent": self.user_agent
        }

        if self.token:
            headers["Authorization"] = f"Bearer {self.token}"

        try:
            async with websockets.connect(
                self.url,
                additional_headers=headers,
                ssl=SslService.get_ssl_context()
            ) as ws:
                self.ws = ws
                self.connected = True

                if self._on_open:
                    self._on_open()

                async for message in ws:
                    try:
                        data = json.loads(message)
                    except Exception:
                        data = message

                    if self._on_message:
                        self._on_message(data)

        except Exception as e:
            print("[WS] Connection error:", e)
                

        finally:
            self.connected = False

            if self._on_close:
                self._on_close()

            time.sleep(0.1)
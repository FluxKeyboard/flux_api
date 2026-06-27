import threading

from config_service import ConfigService
from secretStore import SecretStore
from apiClient import ApiClient
from websocketClient import WebSocketClient

class PolymathConnectionManager:
    def __init__(self, notificationCallback):
        self.notificationCallback = notificationCallback

        self.config_service = ConfigService()
        self.secret_store = SecretStore()
        self.api_client = None
        self.allow_api_request = True
        self.connected = False
        self.api_key = None
        self.attempting_connection = False
        self.connection_generation = 0
        self.config = None
        self.timer = None
        self.ws = None
        self.attempting_auth = False
        self.currentContext = None
        self.intentional_shutdown = False




    

    def on_ws_open(self):
        self.notificationCallback("Connected", "Successfully connected to Polymath!")

    def on_ws_close(self):
        if self.intentional_shutdown:
            return
        
        self.notificationCallback("Reconnecting", "Lost connection to Polymath, reconnecting")
        self.connected = False
        self.start_connection()

    def on_ws_message(self,msg):
        
        if msg['code'] == 404 and msg['type'] == "Shortcut error":
            self.notificationCallback("Resource Not Found", "Please ensure you have the appliction Blender attached to a profile, and that profile is saved to the keyboard") 

        if msg['code'] == 403 and msg['type'] == "Shortcut error":
            self.notificationCallback("Denied Access", "Our context switching request was denied, or Blender was not the active shortcut set when permissions was given. We'd reccomend allowing promptless switching in Polymath settings") 

        # We werent able to update the context so we resend
        if msg['code'] == 500 and msg['type'] == "Shortcut error":
            self.ws.send({
            "route": "changeContext",
            "message": self.currentContext
        })
            
    def full_restart(self):
        self.intentional_shutdown = False
        self.start_connection()


    def start_connection(self):
        if self.attempting_auth:
            return False
        if self.attempting_connection:
            return False
        if not self.allow_api_request:
            return False
        if self.connected:
            return False

        # We use the generation system to determine if our current call is stale
        self.attempting_connection = True
        generation = self.connection_generation + 1
        self.connection_generation = generation

        self._clear_timers()

        try:

            self.config = self.config_service.get_api_config()
            if(generation != self.connection_generation):
                return
            
            if not self.config or not self.config.get("apiActive"):
                raise Exception("API not active or config missing")
            
            if not self.api_client:
                self.api_client = ApiClient(self.config["openPort"])
            else:
                self.api_client.set_port(self.config["openPort"])

            # This tells us if the API is currently active
            self.api_client.get("/docs")
            if(generation != self.connection_generation):
                return

            self.get_or_set_api_key(False)
            if(generation != self.connection_generation):
                return

            # This allows us to confirm that our api ke is still valid. If it isn't we request a new one
            self.api_client.get("/authentication/check")
            if(generation != self.connection_generation):
                return
            self.connected = True
            if(generation != self.connection_generation):
                self._clear_timers()
                return

            self._start_websocket()
            if(generation != self.connection_generation):
                self._clear_timers()
                self.ws.close()
                return
            return True

        except Exception as e:
            self.handle_error(e)

        finally:
            self.attempting_connection = False



    def handle_error(self, e):
        self.connected = False

        status_code = e.args[0]
        if status_code == 401:
            self.api_key = None
            self.api_client.set_api_key(None)
            self.get_or_set_api_key(True)
            self.attempting_connection = False
            return

        if status_code == 403:
            self.notificationCallback("Denied access", "This Blender addon has been denied access to Polymath. If you wish to continue to revieve keyboard updates, please ensure that this addon isn't banned in Polymath, and restart Blender")
            self.allow_api_request = False
            self._clear_timers()
            return
        
        # The 3 ways a start_connection() call can end are in either success, failure, or early cancellation due to it being stale
        # Only success or early cancellation we have no reason to reattempt connection
        # On error we may, so we handle our restarting here
        
        if self.allow_api_request:
            self.timer = threading.Timer(5.0, self._retry_connection)
            self.timer.start()

    def _retry_connection(self):
        self.start_connection()


    def get_or_set_api_key(self, reset):
        # If we are actively authenticating we return
        if self.attempting_auth:
            return

        # If we have a key in memory we return
        if self.api_key is not None:
            return

        # Unless we are doing a full reset of our API key, we always attempt to retrieve it from secure storage
        if not reset:
            self.api_key = self.secret_store.get_api_key()

        # If we got a key from secure storage, we return
        if self.api_key:
            self.api_client.set_api_key(self.api_key)
            return

        # We have the registration call on a worker so it is non blocking. It could take multiple seconds for the user to accept the request
        # So we don't want the UI blocked during that
        def worker():
            try:
                self.attempting_auth = True
                result = self.api_client.post("/authentication/register", {})
                self.api_key = result["message"]
                self.secret_store.save_api_key(self.api_key)
                self.api_client.set_api_key(self.api_key)

            except Exception as e:
                self.handle_error(e)
            finally:
                self.attempting_auth = False
                if not self.connected:
                    self.start_connection()

        threading.Thread(target=worker, daemon=True).start()



    def _start_websocket(self):
        self.ws = WebSocketClient(
        "wss://localhost:"+str(self.config["openPort"])+"/v1/configChange",
        token=self.api_key
    )
        self.ws.set_on_close(self.on_ws_close)
        self.ws.set_on_message(self.on_ws_message)
        self.ws.set_on_open(self.on_ws_open)
        self.ws.connect()


    def send_ws_message(self,message):
        if(self.ws == None):
            return
        
        self.currentContext = message
        self.ws.send({
            "route": "changeContext",
            "message": message
        })



    def stop_connection(self):
        self._clear_timers()
        self.connection_generation += 1
        self.connected = False
        self.allow_api_request = True
        self.attempting_connection = False
        self.intentional_shutdown = True
        if self.ws:
            self.ws.close()


    def _clear_timers(self):
        if self.timer:
            self.timer.cancel()
            self.timer = None

            
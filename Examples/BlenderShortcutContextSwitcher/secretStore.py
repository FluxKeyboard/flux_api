import keyring

# We use secure storage to store the API key as opposed to saving it in a plain text file on the computer
class SecretStore:
    SERVICE = "com.fluxkeyboard.blenderWorkspaceMonitor"
    ACCOUNT = "com.fluxkeyboard.polymath"

    def get_api_key(self):
        try:
            return keyring.get_password(self.SERVICE, self.ACCOUNT)
        except Exception:
            return None

    def save_api_key(self, key: str):
        try:
            keyring.set_password(self.SERVICE, self.ACCOUNT, key)
        except Exception as e:
            raise RuntimeError(f"Failed to store API key: {e}")
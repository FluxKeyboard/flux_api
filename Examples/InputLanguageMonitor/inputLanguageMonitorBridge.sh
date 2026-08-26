#!/bin/bash

API_URL="https://localhost:52323/v1"
SERVICE="inputLanguageMonitorExample"
USER="api-key"
CONFIG_DIR="$HOME/flux/config"
CONFIG_FILE="$CONFIG_DIR/keys.json"

connected=false
api_key=""
allow_api_request=true
currently_connecting=false

# We have to grab the public key from the device in order to create a security context with our HTTPS requests
TLS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/com.fluxkeyboard.polymath/tls"

# We use secure storage to store and retrieve the key

get_api_key() {
	secret-tool lookup service "$SERVICE" user "$USER" 2>/dev/null
}

set_api_key() {
	local key="$1"

	if [ -z "$key" ]; then
		return 1
	fi

	printf "%s" "$key" | secret-tool store \
		--label="Polymath API Key" \
		service "$SERVICE" \
		user "$USER"

	sleep 1
}

#The keys.json file in the flux config is the source of truth when it comes to API status. This will tell us if the api is current set to active
#as well as what the correct port is. This is reloaded on every connection attempt

#If there is any manipulation of the config file, Polymath will detect this and reset the keys.json file barring the banned/rejected application information
get_api_config() {
	if [[ ! -f "$CONFIG_FILE" ]]; then
		return 1
	fi

	local content apiActive openPort

	content=$(<"$CONFIG_FILE")

	content="${content//[[:space:]]/}"

	if [[ "$content" =~ \"apiActive\":(true|false) ]]; then
		apiActive="${BASH_REMATCH[1]}"
	else
		apiActive="false"
	fi

	if [[ "$content" =~ \"openPort\":([0-9]+) ]]; then
		openPort="${BASH_REMATCH[1]}"
	else
		openPort=0
	fi

	echo "$apiActive|$openPort"
}

#We load the needed config information into memory
load_config() {
	local cfg api_active open_port

	cfg=$(get_api_config) || return 1

	IFS="|" read -r api_active open_port <<<"$cfg"

	if [[ "$api_active" != "true" ]]; then
		return 1
	fi

	API_URL="https://localhost:$open_port/v1"
	return 0
}

# This confirms that our current API key is still valid, if it is not this endpoint tells us as such
auth_check() {

	local key=$(get_api_key)

	if [ -z "$key" ]; then
		return 1
	fi

	local res code

	res=$(
		curl -sS -w "\n%{http_code}" \
			--cacert "$TLS_DIR/cert.pem" \
			-H "Authorization: Bearer $key" \
			-H "User-Agent: Polymath Input Language Monitor Example" \
			"$API_URL/authentication/check"
	)

	code="${res##*$'\n'}"

	[ "$code" = "200" ]
}

# This is how we register with Polymath to get a new API key. If the user denies the request or we are told our application is banned, we stop our connection loop
register_key() {
	if [ "$connected" = true ]; then
		return 1
	fi
	local response body code key
	response=$(
		curl -sS -w "\n%{http_code}" \
			--cacert "$TLS_DIR/cert.pem" \
			-X POST "$API_URL/authentication/register" \
			-H "Content-Type: application/json" \
			-H "User-Agent: Polymath Input Language Monitor Example" \
			-d "{}"
	)

	code="${response##*$'\n'}"
	body="${response%$'\n'*}"
	if [ "$code" != "200" ]; then
		if [[ "$code" = "403" ]]; then
			allow_api_request=false
			connected=false
		fi
		return 1
	fi

	key=$(echo "$body" | grep -oP '"message"\s*:\s*"\K[^"]+')

	if [ -z "$key" ]; then
		return 1
	fi
	set_api_key "$key"

	api_key=$(get_api_key)
}

# Here is where we initiate the auth check, if it fails we automatically request a new key
# We check prior to every message in case the user has revoked our API key
ensure_auth() {
	if [[ "$currently_connecting" = true ]]; then
        return 1
    fi
	api_key=$(get_api_key)
	if [ -z "$api_key" ]; then
		return 1
	fi

	if auth_check; then
		connected=true
		return 0
	fi

	if register_key; then
		if auth_check; then
			connected=true
			return 0
		fi
	fi

	connected=false
	return 1
}

# This is our un authenticated endpoint check. We use this to determine if the API is on since it can be true in the JSON file
# But Polymath could not be running
docs_check() {
	curl -s --cacert "$TLS_DIR/cert.pem" "$API_URL/docs" >/dev/null
}

# This is our connection function, it will go through the various validation steps we have set up, and if all pass we will change the connected flag to true
try_connect() {
	if [[ "$currently_connecting" = true ]]; then
		return
	fi

	if [[ "$allow_api_request" != true && "$connected" == true ]]; then
		kill "$PING_PID"
		return
	fi

	if [[ "$allow_api_request" != true ]]; then
		return
	fi

	currently_connecting=true
	if ! load_config; then
		connected=false
		currently_connecting=false
		return 1
	fi

	if ! docs_check; then
		connected=false
		currently_connecting=false
		return 1
	fi

	if ! auth_check; then

		currently_connecting=false
		register_key || return 1
	fi

	if auth_check; then
		connected=true

		currently_connecting=false

		return 0

	fi

	currently_connecting=false
	connected=false
	return 1
}

# This is our continuous authentication loop. If the user revokes our key (or Polymath wipes them due to security concern)
# We will notice it here and re-request
ping_loop() {
	trap 'echo "ping_loop stopping"; exit 0' INT TERM
	while true; do
		sleep 5

		if [[ "$currently_connecting" = true ]]; then
			continue
		fi

		if [ "$connected" = false ]; then
			try_connect
			continue
		fi

		if ! auth_check; then
			connected=false
			try_connect
		fi
	done
}

# An empty layout is meaningful: it says the active source is not an xkb layout
# (what an input method being active looks like), rather than that the layout is
# unknown.
send_input_language() {
	ensure_auth || return 1

	local layout="$1"

	api_key=$(get_api_key)

	if [ -z "$api_key" ]; then
		return 1
	fi

	curl -s -X POST "$API_URL/config/updateInputLanguage" \
		--cacert "$TLS_DIR/cert.pem" \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $api_key" \
		-H "User-Agent: Polymath Input Language Monitor Example" \
		-d "{\"layout\":\"$layout\"}" >/dev/null

	return $?
}

# We confirm that we are connected before we send messages to the API
handle_input_language() {
	local layout="$1"

	if [ "$connected" = false ]; then
		try_connect
		return
	fi

	send_input_language "$layout"
}

# We initialize by getting the most up to date API key and connecting
api_key=$(get_api_key)
try_connect

# This creates our auth ping loop
ping_loop &
PING_PID=$!

# We use DBus to receive the active input language from the GNOME Shell extension and propagate it to the API
dbus-monitor --session "type='signal',interface='org.fluxkeyboard.InputLanguageMonitor',member='InputLanguageChanged'" |
	while read -r line; do

		trap 'echo "dbus_loop stopping"; exit 0' INT TERM

		if [[ "$line" == *"InputLanguageChanged"* ]]; then
			capture=1
			continue
		fi

		if [[ $capture -eq 1 && "$line" == *"string"* ]]; then
			json="${line#*string \"}"
			json="${json%\"*}"

			capture=0

			# The shell reports null when it has no active source at all.
			if [[ -z "$json" || "$json" == "null" ]]; then
				continue
			fi

			source_type=$(echo "$json" | grep -oP '"type"\s*:\s*"\K[^"]+')
			layout_id=$(echo "$json" | grep -oP '"id"\s*:\s*"\K[^"]+')

			if [[ "$source_type" == "xkb" ]]; then
				handle_input_language "$layout_id"
			else
				handle_input_language ""
			fi
		fi

	done

kill $PING_PID

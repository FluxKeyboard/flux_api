# Input Language Monitor

An official implementation of the Polymath API's input language endpoint. It reports the active keyboard layout on GNOME so the keyboard legends follow layout changes, such as switching between QWERTY and Dvorak.

Polymath reads the active layout from `org.gnome.desktop.input-sources mru-sources`, which GNOME Shell only writes while its IBus connection is healthy. On a session where ibus-daemon is absent or unhealthy the key is never updated and layout switches go unnoticed. The GNOME Shell extension here connects to the shell's `InputSourceManager` and its `current-source-changed` signal instead, which is emitted unconditionally, and publishes the result on DBus for the bash script to relay to the API.

## What the extension reports

`{"type":"xkb","id":"us+dvorak"}` for an xkb layout, or a non-xkb type such as `ibus` while an input method is active. The script sends the id for xkb sources and an empty layout otherwise, which tells Polymath the active source is not an xkb layout rather than that the layout is unknown.

## Staying connected

The script calls `GET /authentication/check` every 5 seconds. That is not only a key validity check: it is what keeps the layout it has sent from being discarded, as described in [Detection overrides](../../README.md#detection-overrides).

## Adapting it

Register under an application name of your own rather than reusing this one. Polymath stores one key per application name, so two processes sharing a name invalidate each other's key and neither can stay connected. This example uses `Polymath Input Language Monitor Example`, which is deliberately different from the name Polymath's own bundled integration uses, so the two can run side by side.

The plumbing is kept inline here so the script can be read and run on its own. Polymath ships the same logic with that plumbing factored into a library shared with its process monitor.

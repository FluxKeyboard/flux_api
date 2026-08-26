# Wayland Process Monitors

The following are official and utilized implimentations of the Polymath API. Specifically these two projects are for handling Wayland process detection in GNOME and KDE Plasma

The project utiizes the process endpoints, and as of now those endpoints are only supported on Linux hosts.

The native helpers are installed on OS' that support them, and they use DBus signals to send them over to the bash script that handles the actual API communication and managment

The bash script keeps calling `GET /authentication/check` every 5 seconds. That is not only a key validity check: it is what keeps the process values it has sent from being discarded, as described in [Detection overrides](../../README.md#detection-overrides).

Register under an application name of your own rather than reusing one of these. Polymath stores one key per application name, so two processes sharing a name invalidate each other's key and neither can stay connected.

Polymath ships these with its API plumbing factored into a shared library it also uses for its input language monitor. The script here keeps that plumbing inline so it can be read and run on its own.


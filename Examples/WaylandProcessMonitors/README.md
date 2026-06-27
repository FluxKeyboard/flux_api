# Wayland Process Monitors

The following are official and utilized implimentations of the Polymath API. Specifically these two projects are for handling Wayland process detection in GNOME and KDE Plasma

The project utiizes the process endpoints, and as of now those endpoints are only supported on Linux hosts.

The native helpers are installed on OS' that support them, and they use DBus signals to send them over to the bash script that handles the actual API communication and managment

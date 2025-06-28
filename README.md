# Getting Started
Add this directory to your $PATH to enable user scripts. Reading both this page
and the script contents is recommended before use. Edits are encouraged, though
hopefully not required :)

# `themectl`
This script is responsible for all theming of eligible services
See [here](../theme/.skeleton/README.md#themectl) for reference.

# `rofi-session`
A rofi wrapper to provide a menu for shutdown/reboot/logout/lock/sleep.
The default keybind is `Mod+Shift+Q`. 

To enable shutdown / reboot via this menu, you must allow the user to call 
`/sbin/halt`, `/sbin/reboot`, and `/sbin/poweroff` without a password. Write 
the following to the file `/etc/sudoers.d/shutdown`:

```bash
# Allows shutdown / reboot without password
eduardo ALL = NOPASSWD: /sbin/halt, /sbin/reboot, /sbin/poweroff
```

# `rofi-audio`
Default keybind is `Mod+V`.

A rofi wrapper to set the default pipewire audio sink. Will switch the audio
outputs used by all streams that are currently using the default.

You can exempt certain applications from this by opening `pavucontrol` and 
explicitly selecting an output for a stream. This is then saved in 
`~/.local/state/wireplumber`. If you would like to un-exempt a stream 
from using defaults, delete `~/.local/state/wireplumber` and restart:

`systemctl --user restart wireplumber.service`

# `rofi-notes`
Default keybind is `Mod+N`.

A rofi wrapper to create / edit markdown notes. Either enter the name of a
new note, or select `New` and one will be created for you with the timestamp
as the name. Notes are saved by default in `$HOME/notes`.

Note: all notes will be appended with `.md` if you enter a name without an
`.md` at the end. This is pretty much just for markdown notes.

# `fetch`
Calls `fastfetch` using available logos in the current theme. Will otherwise
just use a default small logo.

# `screenshot`
Default keybind is `Mod+P`.

Calls `hyprshot` in region mode. Use the mouse cursor to take a screenshot
of some region on the screen. Will save to `$HOME/pictures/screenshot` by
default.

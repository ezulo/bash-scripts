# Getting Started
Add this directory to your $PATH to enable user scripts. Reading both this page
and the script contents is recommended before use. Edits are encouraged, though
hopefully not required :)

# `themectl`

### Quick Start
This script supports (or will support) basic theme functionality for:

    * hyprpaper
    * kitty
    * waybar
    * rofi
    * dunst

Though it requires some setup. A themes directory must be made (`$HOME/themes`,
for instance) which contains a directory for each theme. It should appear 
something like the following:
```
theme/
├── pointillism
│   ├── colors.json
│   ├── wallpapers/
│   └── config/
│       ├── dunst/
│       │   └── theme
│       ├── hyprland/
│       │   └── theme.conf
│       ├── waybar/
│       │   └── rules.css
│       └── rofi/
│           └── theme.rasi
└── frutiger_aero/
│   ├── colors.json
│   ├── wallpapers/
│   └── config/
│       ├── dunst/
│       │   └── theme
│       ├── hyprland/
│       │   └── theme.conf
│       ├── waybar/
│       │   └── rules.css
│       └── rofi/
│           └── theme.rasi
```

Each theme directory should have a `colors.json` file and 
a `wallpapers/` directory with one or more wallpaper image files.

Finally, The environment variable `THEME_DIR` should be set to the themes 
directory (e.g. `$HOME/themes`)

### Usage
The script is responsible for changing and applying themes. It has two options:

- `themectl <set> <theme_name>`: changes the theme, also performs a `reload`
- `themectl <get>`: gets the current theme name
- `themectl <reload>`: reloads theme elements + config files

There is also an additional `themecolor` script to retrieve current theme
colors from `colors.json`. Example invocations:

```bash
themecolor 0            # get color0
themecolor background   # get background color
themecolor color3       # get color3
themecolor 9 noformat   # get color9 without formatting or coloration
                        # etc...give it a try!
```

As a nice touch, the script will also color its output to the appropriate
color, and match its luminance against the terminal background to determine
whether to colorize the foreground or background of the text. This is
disabled (for use in scripts) when passing it "noformat" as a second argument.

### Creating Themes
To create a theme, use one of the included themes as reference.

rofi, hyprland, and waybar will inherit colors from `colors.json`. However,
it is not a requirement that you use these colors. You can treat these
as additional configs applied on top of default configs. Note that `themectl`
will inform you via `notify-send` of the files it writes every time it
reloads. The config directories will be ready to import theme files written 
by this script.

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
`$HOME/.local/state/wireplumber`. If you would like to un-exempt a stream 
from using defaults, delete this directory and restart wireplumber by calling:

`systemctl --user restart wireplumber.service`

# `rofi-notes`
Default keybind is `Mod+N`.

A rofi wrapper to create / edit markdown notes. Either enter the name of a
new note, or select `New` and one will be created for you with the timestamp
as the name. Notes are saved by default in `$HOME/notes`.

Note: all notes will be appended with `.md` if you enter a name without an
`.md` at the end. This is pretty much just for markdown notes.

# `fetch`
Calls `fastfetch` using the logo in the current theme, if it finds one. Will
otherwise just use the `arch_small` icon.

# `screenshot`
Default keybind is `Mod+P`.

Calls `hyprshot` in region mode. Use the mouse cursor to take a screenshot
of some region on the screen. Will save to `$HOME/pictures/screenshot` by
default.

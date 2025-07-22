# Eduardo's User Scripts

## Getting Started
Add this directory to your $PATH to enable user scripts. Reading both this page
and the script contents is recommended before use. Edits are encouraged, though
hopefully not required :)

## Notes
These scripts are designed with hyprland in mind, but it is not necessarily
required. The following have a hyprland dependency (at least):
- `zmenu:session` uses `hyprctl` and `hyprlock` to implement logout/lock
- `zmenu:scaling` interfaces with hyprland to set monitor scaling
- `themectl` contains the `hyprland` and `hyprpaper` modules, but they can be
  deactivated by removing them from `include/themectl/active-modules`

## `themectl`
A script responsible for theming. 
See [here](doc/themectl.md) for reference.

## `zmenu`
A wrapper for "dmenu-like" prompt menus.
See [here](doc/zmenu.md) for reference.

## `fetch`
Calls `fastfetch` using available logos in the current theme. Will otherwise
just use a default small logo.

## `screenshot` [Mod+P]
Calls `hyprshot` in region mode. Use the mouse cursor to take a screenshot
of some region on the screen. Will save to `$HOME/pictures/screenshot` by
default.

## `testdunst`
Displays dunst messages of all urgencies, for conveniences' sake when
customizing dunst configuration.

## `update-mirrors`
Uses `reflector` to update Pacman mirrors. Will prompt for `sudo` password
and confirmation before committing mirrors.


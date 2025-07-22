# Zmenu (wrapper for "dmenu-likes")

## Table of Contents
* [Overview](#overview)
* [Modules](#modules)
    * [admin](#admin)
    * [audio](#audio)
    * [convert](#convert)
    * [notes](#notes)
    * [scaling](#scaling)
    * [session](#session)
    * [tasks](#tasks)
    * [theme](#theme)

## Overview
A wrapper for scripts that operate on simple graphical menus,
invoked with specific `$mainMod SHIFT` keybinds. The default menu backend is
`wofi` for selection options, and a special `kitty` frontend for a text prompt.

## Modules
Available modules can be found in the 
[zmenu modules directory](./include/zmenu/modules). These all consist of simple
shell scripts that read from graphical menus. Some modules, like `convert` for
instance, use cached named pipes for convenience, which are stored in
`$XDG_CACHE_HOME/zmenu:convert/`.

You may call `zmenu` directly and select a module, or `zmenu [module_name]`.
The modules in this repo are detailed here, with default keybinds 
(for hyprland):

#### `admin` [Mod+Shift A] 
Saved for admin options. Right now, the only option is to clear the cache for
all modules.

#### `audio` [Mod+Shift V] 
Selects default audio sink output for pipewire/pulse.

You can exempt certain applications from this from `pavucontrol` by explicitly 
selecting an output stream for an application. This can be undone by deleting
`~/.local/state/wireplumber` and restarting  wireplumber: 

`systemctl --user restart wireplumber.service`

#### `convert` [Mod+Shift C]
Performs some helpful unit conversions!

#### `notes` [Mod+Shift N] 
Provides a handy interface for quickly scribbling markdown notes. Default 
notes directory is `$HOME/Notes`. If no name is specified for a note, one will
be created with a timestamp.

#### `scaling` [Mod+Shift M] \(Hyprland specific\)
Sets the scaling of the primary monitor (percentage)

Open `~/.config/scripts/include/zmenu/modules/scaling` and change the
`PRIMARY_MON=` line to the desired monitor ID.

#### `session` [Mod+Shift Q] Shutdown / reboot / sleep / logout.
To enable shutdown / reboot via this menu, you must enable the user to
execute the relevant commands without a password.

Add the following line to  `/etc/sudoers.d/shutdown`:

`your_username ALL = NOPASSWD: /sbin/halt, /sbin/reboot, /sbin/poweroff`

#### `tasks` [Mod+Shift Z]
Frontend for `zeit` for task tracking.

#### `theme` [Mod+Shift T]
Frontend for `themectl` for system theming.


# Eduardo's Linux Themes (`themectl`)

## Table of Contents
* [Glossary](#glossary)
* [Notes](#notes)
* [Getting Started](#getting-started)
* [Theming](#theming)
    * [themectl](#themectl)
* [Theme Configuration](#theme-configuration)
    * [colors.json](#colors.json)
    * [wallpapers](#wallpapers)
    * [fastfetch](#fastfetch)
    * [hyprland](#hyprland)
    * [kitty](#kitty)
    * [dunst](#dunst)
    * [waybar](#waybar)
    * [rofi](#rofi)
* [Modules](#modules)

## Glossary
- "THEME_HOME": The location where themes are installed.
- `themectl`: The script which handles theming in `$HOME/.config/scripts`

## Notes
- This is not an overview for how to configure individual services. This is
  simply a document describing how my theming system works and get you off the
  ground. All config files in a theme are ***optional***.

## Getting Started
We can use the [default theme](../../theme/.skeleton) for reference.

Note the following subdirectories:

* `dunst`
* `fastfetch`
* `hyprland`
* `kitty`
* `rofi`
* `waybar`

These contain config files that pertain to these services, and the way they
are handled is specific to the service. 

For the most part, these can be thought of as overrides to your default 
configurations. 

#### A note on `waybar`, `rofi`, and `wofi`
These services use flavors of CSS, and
[CSS specificity rules](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_cascade/Specificity) 
will apply. Keep in mind if your rules are not working, there may be a more
specific rule in your `waybar` or `rofi` config directories.

## Theming

The bulk of the theming work is performed by `themectl`. It has a handful of
directives (which are subject to change):

* `themectl clear`: unsets the current theme (reverts to system defaults)
* `themectl color <query> [no_color]`: pretty prints theme color(s) to terminal
    * The query `all` will prettyprint all available keys + colors
    * You may query by 8/16 color codes (0 -> 15) or by any key under "special"
      in the current theme's `colors.json` file.
    * It will colorize background / foreground of text based on a perceived
      luminance comparison of the color queried against the background color.
      Pass the `no_color` option to disable coloration.
* `themectl create <themename> [src_theme]`: Creates a new theme directory
    * `src_theme` can be used to duplicate an existing theme
* `themectl get`: Returns the name of the current theme.
* `themectl ls`: Returns a list of all available themes.
* `themectl set <themename>`: Sets the theme, based on its name in `$THEME_HOME`
* `themectl reload`: Rewrites all theme files and reloads relevant services
    * If any changes to `dunst` were detected, it will wait for log messages to
      timeout before initiating a reload.
    * You can call `themectl reload <module>` to reload one service

## Theme Configuration
The objects / directories here contain configs that will override service 
configs on the system. These are handled differently for each service. I will 
aim to provide a brief description for each.

#### `colors.json`
This file contains the 16-color ANSI color scheme for your terminal, and
these colors can be used in various services, which will be explained in
detail further along. An explanation on ANSI color scheming can be found 
[here](https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797#256-colors).

`color0` through `color15` are your 8 standard colors, and the colors under
"special" are additional colors that may be used by certain services.
[terminal.sexy](http://terminal.sexy) is a great resource for building a color
scheme.

The colors under the `special` key are used primarily by `kitty.conf`. The ones
in the default theme are required, but more can be added if you wish to do so.

#### `wallpapers/`
This directory is an image repository for `hyprpaper`.

`themectl` will, for each monitor, select a random image from this directory 
and send them to `hyprpaper` for display.

As a general rule, have at least one file per monitor. Less than that leads to
undefined behavior.

#### `fastfetch/`
Similarly to `wallpapers`, this is an image repository, but for `fastfetch` 
logos. Drop any `fastfetch` images you want to use in lieu of a system logo 
here. They will be selected at random and displayed in `kitty`.

#### `hyprland`
This contains your theme-specific `hyprland` configurations, and will be saved 
to `$HOME/.config/hypr/theme` by `themectl`.

The only required file under this directory is `hyprland.conf`, which is your
"root" configuration for this theme. You can make additional files so long as
you `source` them properly in your theme's `hyprland.conf`.

#### `kitty`
`themectl` will perform the following for `kitty`: 

* generate a `colors.conf` in `$HOME/.config/kitty/theme`
* copy all files under `./kitty` to `$HOME/.config/kitty/theme`.

All files in the `$HOME/.config/kitty/theme` directory will be `globinclude`'d
by `kitty.conf`. Thus, It doesn't matter what you name them, so long as they 
have the `conf` extension. Order isn't guaranteed so take care not to provide 
duplicate configs in multiple files.

Also, take care you do not create a `colors.conf` file in `./kitty`, as that
will override the one generated by `themectl` (unless you desire that)

#### `dunst`
***WARNING***: `themectl` destroys your current `dunstrc` file and replaces it.
Rename your `dunstrc`, if a custom one exists, to `dunstrc.default`.

`$HOME/.config/dunst/dunstrc.default` is to be regarded as your system-wide
dunst config file. Keep all settings you want to be applied regardless of theme
here. (ex. message timeouts)

`dunstrc` is created by `cat $FILE >> ~/.config/dunst/dunstrc` where `$FILE`
consists of `dunstrc.default` and every file under the `./dunst` directory
here. This means `dunstrc` is sort of just a mashup of your system and
theme configuration.

Apply any theme-specific `dunst` settings here. Name the files whatever you
wish.

#### `waybar`
`themectl` will perform two actions for `waybar`:

* Generate a file `$HOME/.config/waybar/theme/colors.css` from `colors.json`
* Copy the config files from `./waybar/*` to `$HOME/.config/waybar/theme/`

The only required file is `waybar/style.css`, which is explicitly imported
by `$HOME/.config/waybar/style.css`. You may break up your theme styles into 
multiple files, but they must be explicitly imported by `./waybar/style.css`.

Your theme's `style.css` is imported at the end of the waybar service config 
`$HOME/.config/waybar/style.css`. CSS specificity rules apply.

`colors.css` contains color definitions based on `colors.json`, and may be used
something like the following:

```css
/* mytheme/waybar/styles.css */
@import 'colors.css';
/* ... */
#my_id {
    background: linear-gradient(@color0, @color7);
}
```

#### `rofi`
Similarly to `waybar`, `themectl` will perform two actions for `rofi`:

* Generate a file `$HOME/.config/rofo/theme/colors.rasi` from `colors.json`
* Copy the config files from `./rofi` to `$HOME/.config/rofi/theme/`

You may regard the procedure for customization as practically identical to
`waybar`, but using the `.rasi` file extension.

#### `wofi`
This one works a bit different from `rofi` and has the unfortunate limitation
that relative paths in the CSS `@import` directive are evaluated from where the
process is called (useless!). This is due to a GTK technicality and cannot be
remedied, short of making a new menu tool.

What this means practically is that any CSS file imports you want to do will
have to specify absolute paths. 

As a workaround, I have this module inject the absolute path of `colors.css`,
using a simple sed substitution which looks for a marker "{_COLORS_CSS_}".
Simply add this string wherever you wish to fill in the `colors.css` path.
The default `wofi/style.css` already does this.

In summary, this module will:

* Generate a file `$HOME/.config/wofi/theme/colors.css` from `colors.json`
* Copy config files from `./wofi` to `$HOME/.config/wofi/theme`, substituting
  the marker `{_COLORS_CSS_}` for the absolute path of our `colors.css` file.

## Modules
In order to apply the above configurations, we split off the functionality of
each into `themectl` **modules**.

These are located in `~/.config/scripts/include/themectl/modules`, and contain
specific functions to perform theming, cleaning, and reloading of relevant
services, with the names of each function being significant.

For instance, if we look at the [kitty](../include/themectl/modules/kitty)
module, we can see three methods defined: `kitty_theme()`, `kitty_reload()`,
and `kitty_clean()`. The prefix of these methods should match the name of the
module (e.g. for `dunst` it is `dunst_theme()` and so on). These files will
be sourced by `themectl` and these functions invoked.

- `*_theme()` handles application of theme files to the relevant config
  locations on the system.
- `*_reload()` reloads said 
- `*_clean()` cleans up the theme files from the system.

Writing a module is as simple as writing 3 small functions to perform these
tasks. Use the current ones as in the `themectl` modules directory as
reference.

We then activate the modules by editing the
[active-modules](../include/themectl/active-modules) file to specify which
ones we'd like `themectl` to load.


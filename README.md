# Scripts

## Getting Started
Add this directory to your $PATH to enable user scripts. Reading both this page
and the script contents is recommended before use. Edits are encouraged.

## Theming
This supports (or will support) basic theme functionality for:
    * hyprpaper
    * kitty
    * waybar
Though it requires some setup. A themes directory must be made (`$HOME/themes`,
for instance) which contains a directory for each theme. It should appear 
something like the following:
```
theme/
├── baroque/
│   ├── colors
│   └── wallpapers/
│       ├── my_pape.jpeg
│       ├── portrait.jpeg
│       └── 3.jpeg
├── pointillism
│   ├── colors
│   └── wallpapers/
└── frutiger_aero/
    ├── colors
    └── wallpapers/
        ├── A1.jpeg
        ├── 2.jpeg
        └── my_pape.jpeg
```
Finally, the environment variable `THEME_DIR` should be set to the themes 
directory (e.g. `$HOME/themes`)

Each theme directory should have a `colors` file (in Kitty theme format) and 
a `wallpapers/` directory with one or more wallpapers to be randomly selected 
by the `refreshtheme` script.

**Theme scripts**:
    - `refreshtheme`: will make theme changes to kitty, hyperpapr, waybar
    - `settheme <theme>`: sets the theme, and also calls `refreshtheme`


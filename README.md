# Scripts

## Getting Started
Add this directory to your $PATH to enable user scripts. Reading both this page
and the script contents is recommended before use. Edits are encouraged.

## `theme`
This script supports (or will support) basic theme functionality for:

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

Each theme directory should have a `colors` file (in Kitty theme format) and 
a `wallpapers/` directory with one or more wallpaper image files.

Finally, The environment variable `THEME_DIR` should be set to the themes 
directory (e.g. `$HOME/themes`)

The script is responsible for changing and applying themes. It has two options:

- `theme <set> <theme_name>`: changes the theme
- `theme <update>`: updates theme elements

Setting a new theme will also invoke an update.


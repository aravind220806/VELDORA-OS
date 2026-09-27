# Veldora ISO file map

This is a source and ISO staging map. No paths below are instructions to install
on the build host. Earlier live-desktop installation was rolled back; historical
files in `veldora-generated/` and `veldora-previews/` are not packaged.

| Source | Staged runtime destination |
|---|---|
| `Veldora*.qml`, `Veldora*.js`, `qmldir`, settings/tokens JSON, hardware helper, scale SVG | `/etc/skel/.config/quickshell/veldora/` |
| `veldora-entry.qml` | `/etc/skel/.config/quickshell/veldora/shell.qml` |
| `../shell/hyprland.lua` | `/etc/skel/.config/hypr/hyprland.lua` |
| Generated token-based compositor theme | `/etc/skel/.config/hypr/veldora-theme.lua` |
| Generated GTK styles and settings | `/etc/skel/.config/gtk-{3,4}.0/` |
| Generated Qt palette | `/etc/skel/.config/kdeglobals`, `/usr/share/color-schemes/Veldora.colors` |
| Generated terminal/launcher styles | `/etc/skel/.config/{kitty,foot,fuzzel}/` |
| Generated lock screen | `/etc/skel/.config/hypr/hyprlock.conf` |
| `../shell/theme/black-dragon.png` | `/usr/share/veldora/theme/black-dragon.png` |
| Archiso shell wrapper | `/usr/local/bin/veldora-shell` |

The generator writes an exact asset list to
`/usr/share/veldora/veldora-image-files.json` inside each prepared image root.
`prepare-profile.sh` also copies the workbench and explicit GTK fallback.
`tests/veldora_isolated.py` keeps runtime files, screenshots and results in a fresh
`build/veldora-isolated-*/` directory. Current published previews live in
`docs/screenshots/veldora-*.png` and are isolated shell captures, not ISO boots.

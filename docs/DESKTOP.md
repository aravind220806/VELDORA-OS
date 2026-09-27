# Veldora desktop

The ISO now packages the original shell in `veldora-shell/`: charcoal glass,
coral highlights, rounded surfaces, a bottom app dock and a top-center VelDock.
The Windows key opens a searchable workspace overview inspired by the supplied
layout, using Veldora's own components and styling.

See [controls and theme customization](../veldora-shell/README.md),
[feature audit](VELDORA-FEATURE-AUDIT.md), and [validation](VALIDATION.md).
`veldora-tokens.json` is the shared theme source for QML, GTK, Qt, terminals,
Hyprland and the lock screen. `scripts/prepare-profile.sh` generates these inside
a fresh ISO root. It never changes the build host's desktop.

The repository's black-dragon wallpaper is copied into the ISO. Noto Sans,
Material Symbols Rounded and Breeze cursors come from the package manifest.
The older `shell/end4/` and `vendor/end4/` sources remain for history, with their
existing licenses and notices; the current staging script does not package them.
The independently implemented GTK shell remains an explicit `--legacy` fallback.

The workbench provides 20 tool entries, installed-state detection, search,
local diagnostics, SHA-256 calculation and private engagement folders with report
templates. Launching a tool shows its help; it does not start a scan. Engagement
scope is documentation rather than network enforcement. Live-session files are
lost at reboot unless copied to persistent storage. Sentinel is not implemented.

# Veldora Shell

An original Quickshell desktop for this Arch Linux / Hyprland 0.56 Lua setup.
Floating pills, a magnifying dock, a Control Center, notifications, hardware OSDs,
and a searchable app launcher. Your existing wallpaper stays in place.

## Install

Requires the already-installed Quickshell, Qt Quick Controls and Effects, Python,
Hyprland, PipeWire/WirePlumber (`wpctl`), NetworkManager (`nmcli`, `nmtui`), BlueZ
(`bluetoothctl`), `brightnessctl`, Kitty, Hyprlock, and `gsettings`. Typography uses
Noto Sans and Material Symbols Rounded (SIL OFL); the cursor is Bibata Modern
Classic (GPL-3.0). No upstream shell source, icons, or wallpaper are bundled.

From this directory:

```sh
python3 veldora-integrate.py --install
```

The installer saves replaced files and previous GSettings values in a fresh
`~/veldora-backup-YYYYMMDD-HHMMSS/`, creates the `~/.config/quickshell/veldora`
symlink, adds the Lua integration, and applies GTK/Qt/Kitty settings. Keep this
source directory in place. Stop your previous shell before starting `qs -c veldora -d`.
This session is already installed and running. The first complete config/source
snapshot is `/home/codealpha/veldora-backup-20260919-190052/`; the installation
rollback snapshot is `/home/codealpha/veldora-backup-20260919-191556/`.

## Reload and customize

```sh
python3 veldora-integrate.py --reload
```

The **only design source** is `veldora-tokens.json`. Change `colors.accent` and run
the reload command; glass tints, window borders and toolkit colors follow it.
`veldora-generated/` contains derived files, not independent theme settings.
Reopen GTK/Qt/Kitty applications to apply their new appearance. Application-owned
styling can override toolkit colors; Hyprland supplies their 16 px outer corners.

`veldora-settings.json` holds the existing wallpaper path and pinned desktop-entry
IDs. It contains preferences, not design values. Pin mode and Focus mode last for
the current shell session. The wallpaper is referenced in its original location.

Super opens applications; Escape closes the launcher. Super+A opens controls.
Ctrl+Super+R reloads. Click a running dock app to focus it; repeated clicks cycle
its windows. The pin button switches between a persistent dock and edge reveal.
The Audio tile expands output choices; Network opens `nmtui`. Sound controls cap
at 100%; externally boosted volume remains visible in red with a Boost label.
Focus suppresses new popups. Power actions require an explicit menu selection;
restart and shutdown additionally require the in-panel confirmation button.

## Verification and recovery

`python3 veldora-check.py` exercises the live shell and saves screenshots plus
results under `veldora-previews/`. It temporarily uses an empty workspace and
changes volume, then restores both. It opens and closes a test Kitty window.
It requires `grim` and `wtype`; it does not trigger power or connectivity changes.
Use `qs log -c veldora --no-color` and `hyprctl configerrors` to inspect errors.
Restart-based reload avoids Qt warnings observed during Quickshell's automatic
in-process reload on this installed version.

For rollback, stop Veldora, restore each existing file from the installation
backup's `veldora-files/` to the matching location in your home directory, remove
new configuration files listed in `veldora-changed-files.json` that have no saved
counterpart, and restore the three GSettings values in `veldora-gsettings.jsonl`.
Then run `hyprctl reload` and restart your previous shell. The original complete
snapshot excludes application caches, vendor/build trees and Git metadata.

`veldora-files.md` lists every created or changed path. `shell.qml` is a symlink
to the original `veldora-entry.qml`; `shell.qml`, `qmldir`, and `README.md` retain
their standard discovery/documentation names. All Veldora implementation files
are new; pre-existing repository work and third-party directories were preserved.

API references: [Quickshell](https://quickshell.org/docs/),
[Hyprland Lua bindings](https://wiki.hypr.land/configuring/core/binds/).

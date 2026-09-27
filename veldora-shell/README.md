# Veldora Shell

Original Quickshell desktop for the Veldora Archiso image: coral accents, charcoal
glass, rounded panels, a workspace overview, an app dock and the VelDock island.
Development and previews stay in this repository. Do not install this shell on
the build host or run the legacy desktop installer.

## Stage and build

From the repository root:

```sh
./scripts/prepare-profile.sh build/profile
python scripts/validate.py --profile build/profile
sudo ./scripts/build-iso.sh
```

Use a fresh staging directory. `veldora-integrate.py --root build/profile/airootfs`
generates toolkit and compositor styles from `veldora-tokens.json`. It accepts
only a prepared profile under this repository's `build/`; it never changes host
settings. Change tokens and prepare another profile to rebuild the theme.
`veldora-generated/` and `veldora-previews/` are historical development artifacts,
not ISO inputs. The packaged wallpaper is `shell/theme/black-dragon.png`; the
build host's wallpaper is preserved.

## Controls

| Action | Shortcut |
|---|---|
| Workspace overview and app/window search | Windows/Super, or Super+Tab |
| App launcher | Super+Space |
| VelDock media/audio/events/apps/settings | Super+I, or center clock |
| Control Center | Super+A |
| Terminal / files / browser / workbench | Super+Return / E / B / S |
| Lock / reload shell | Super+L / Ctrl+Super+R |

Overview shows ten spaces in a 5×2 grid at desktop width and fewer columns on
smaller displays. Occupied cards show live window captures when supported, with
an app glyph fallback. Click a window or workspace; arrows and Enter also work.
Type to search apps and window titles. Escape closes the active panel.

The bottom dock groups running windows with pinned apps, including apps without
a desktop entry. Click to launch or focus; repeated clicks cycle grouped windows.
Hover enlarges icons. Pin mode persists; unpinned mode reveals at the bottom edge.
VelDock keeps up to 100 recent events in memory, deduplicates updates, and returns
to the clock after a glance expires. Focus mode suppresses glances and popups.
Lock clears private history; fullscreen hides the dock and suppresses glances.
Reduced motion and dock pinning are stored in the live user's settings JSON.
Volume controls cap at 100%; external boost is labeled. No hardware services,
Sentinel protection or managed jobs are simulated as available.

## Verification

See [validation](../docs/VALIDATION.md) and [feature audit](../docs/VELDORA-FEATURE-AUDIT.md).
`tests/veldora_isolated.py` stages a new profile and runs a private compositor and
session bus. It does not send input to the active host session. An isolated UI
run is not an ISO build or boot test. Hardware, authentication, suspend and power
actions require a disposable VM or intended-device test.

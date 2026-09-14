# Validation record

Tested on 2026-09-12 with Arch Linux, Archiso 90-1, Hyprland 0.56.2-2,
Python 3.14, GTK3, and gtk-layer-shell 0.10.1.

Passed:

- `python scripts/validate.py`: package requirements, shell syntax, notification
  interface XML, greetd TOML, boot configuration, live-user/remote-service checks.
- `python -m unittest discover -s tests -v`: four notification model tests.
- `Hyprland --verify-config -c "$PWD/shell/hyprland.lua"`: config OK.
- All 159 requested packages resolve in the host's pacman sync databases.
- Prepared profile includes the shell and `/etc/skel/.config/hypr/hyprland.lua`.
- Shell runs in an isolated D-Bus session under a second Hyprland compositor,
  with screenshots captured from its 1920×1080 headless output.
- `tests/session_smoke.py` against that bus: notification capabilities, server
  identity, replacement ID, explicit-close signal, and timed-expiration signal.
- A second shell invocation is rejected, preventing duplicate panels.
- Expanded/collapsed island rendered without runtime config errors.

The isolated bus produced AT-SPI warnings and PyGObject API deprecation notices;
these did not prevent shell rendering or notification handling.

Not yet verified:

- A complete `mkarchiso` build. Root authentication was unavailable to the agent.
- BIOS/UEFI boot, live account creation, greetd startup, networking and audio in ISO.
- Hardware brightness, playback with a real MPRIS player, GPU/Wi-Fi compatibility.
- Secure Boot, persistent installation, Sentinel security services (not implemented).

The screenshots show the actual running shell, not an ISO boot or a mockup.

## Compact desktop revision

The layout smoke test checks aligned top pills, idle island width below 200 pixels,
no dock/desktop-clock surfaces, notification-driven width expansion, return to idle
width after the timeout, and manual expansion/collapse. The theme is a Hyprland
layout with date/time-only idle content. Hardware Bluetooth/power actions and lock
password authentication still require live-image/hardware testing.

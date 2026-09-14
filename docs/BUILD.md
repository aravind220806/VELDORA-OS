# Build and test Veldora

This is an experimental live desktop, not the complete security distribution in the
architecture proposal. Nothing partitions disks automatically. The ISO includes
Arch's `archinstall`; it is not a Veldora installer and does not install this shell
automatically. Sentinel, USB default-deny, voice control, encryption setup, and
Secure Boot signing are not implemented.

## Build on Arch Linux x86_64

Allow at least 30 GB of free space and use an up-to-date Arch host. Packages are
resolved from rolling repositories, so builds are not bit-for-bit reproducible.

```bash
sudo pacman -Syu --needed archiso python
python scripts/validate.py
python -m unittest discover -s tests -v
sudo ./scripts/build-iso.sh
```

Find the ISO and its SHA-256 checksum in `out/`. Each build uses a fresh directory
under `build/` and keeps its log. Do not delete an interrupted archiso work tree
until `findmnt -R /absolute/path/to/work` confirms there are no remaining mounts.
The build script deliberately does not unmount or delete anything automatically.

For a profile you can inspect without root:

```bash
./scripts/prepare-profile.sh build/profile
```

The source profile and shell are separate; **use the build script** to include the
shell. Running mkarchiso directly on `archiso-profile/` omits the shell assets.
The profile retains Archiso v90 releng's BIOS and UEFI boot machinery.

## Boot test

```bash
sudo pacman -S --needed qemu-desktop edk2-ovmf
./scripts/run-vm.sh out/veldora-YYYY.MM.DD-x86_64.iso bios
./scripts/run-vm.sh out/veldora-YYYY.MM.DD-x86_64.iso uefi
```

The VM uses accelerated virtual graphics for Hyprland and attaches no host disks.
It requires a graphical host with OpenGL support. Secure Boot should be disabled
for this unsigned development ISO. Use at least 4 GB guest RAM.

The live desktop logs in as `liveuser`. Password: `veldora`. This account has
passwordless sudo **for the disposable live environment**. SSH is disabled and
the root password is locked. These are not suitable installed-system defaults.
If graphics fail, switch to Ctrl+Alt+F2 and sign in with the live credentials.

Before calling an ISO usable, check both firmware modes:

- Desktop appears; center clock pill and side panels are visible.
- Super+Return launches the terminal; Super+Space launches search.
- Network connects (`nmtui` for Wi-Fi); browser loads a page.
- `notify-send 'Hello Veldora' 'Notification test'` appears in the island.
- Super+I expands/collapses it; Escape collapses it; dismiss works.
- Media metadata/playback responds to an MPRIS-capable player.
- Audio keys show feedback; brightness works on supported physical hardware.
- `systemctl --failed` and `journalctl -b -p err` show no unexplained failures.
- Repeat on intended GPU/Wi-Fi hardware. VM success is not hardware certification.

## Theme

`shell/hyprland.lua` targets **Hyprland 0.56 or newer** (Lua configuration).
`shell/style.css` controls the island/dock. `shell/main.py` loads an optional wallpaper and runs the GTK3 layer-shell desktop. This initial
implementation uses Python/GTK rather than the planned AGS/Astal rewrite.

The current design follows the supplied compact Hyprland reference: workspace and
system pills at top left, a small centered date/time island, and audio/network,
Bluetooth, battery and power controls at top right. There is no bottom dock or
large desktop clock. Notifications, new media metadata and control feedback widen
the island temporarily; after five seconds it returns to date/time. Click the pill
or press Super+I for media, notifications, quick controls, and app shortcuts.

The wallpaper defaults to near-black. To use your original artwork (PNG or JPEG),
copy it to `~/.config/veldora/wallpaper` and restart the shell. For ISO inclusion,
place it at `archiso-profile/airootfs/etc/skel/.config/veldora/wallpaper` before
building. The reference screenshot has not been embedded as wallpaper because it
already contains desktop UI.

Workspaces 1–10 are clickable; Super+0 selects 10. Active/occupied states update
from Hyprland's event socket. CPU/RAM/CPU-temperature/root-disk readings refresh
at five-second intervals; unavailable sensors display a dash. On screens narrower
than 1500 logical pixels, metrics move into the expanded island to prevent overlap.
Network opens `nmtui`, Bluetooth opens Blueman, and audio opens Pavucontrol.
The power menu explicitly offers lock, suspend, restart and shutdown. Super+L
launches Hyprlock; the disposable live account still uses the documented password.

This is an independent Dynamic Island-inspired interaction, not Apple/vivo software.

The island is a session D-Bus notification server. Do not run another notification
daemon alongside it. It supports plain text, replacement, dismissal and expiration;
notification action buttons and images are not implemented. Up to 30 notifications
are retained in memory; expired notifications are removed. Media is refreshed every
two seconds via playerctl. There is no claimed zero-idle-cost or Sentinel integration.
The initial desktop uses the compositor's default output; full multi-monitor shell
placement and per-output settings are future work.

No changes to the build host's Hyprland configuration are made by these scripts.

## Sources

- [Archiso documentation](https://github.com/archlinux/archiso/tree/v90/docs)
- [Hyprland configuration](https://wiki.hypr.land/Configuring/Start/)
- [GTK layer shell](https://github.com/wmww/gtk-layer-shell)
- [vivo OriginOS visual reference](https://www.vivo.com/en/originos/)

The upstream profile was copied from Archiso v90, commit
`0270567a2914330ff236ccd7d4f40eaee7b8e708`. Its license is in
[ARCHISO-LICENSE](ARCHISO-LICENSE). Original project licensing remains to be selected
by the owner; do not assume that upstream's license covers new Veldora files.

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

## Theme and staging

The current ISO shell is original Quickshell code in `veldora-shell/`, with
Hyprland 0.56+ Lua configuration in `shell/hyprland.lua`. The generator derives
GTK, Qt, terminal and lock-screen styling from one token file. It packages the
repository's black-dragon wallpaper and leaves the build host unchanged.

After preparing a profile, validate its assets and paths:

```bash
python scripts/validate.py --profile build/profile
node tests/veldora_models.cjs
```

See [desktop controls](DESKTOP.md) and the [feature audit](VELDORA-FEATURE-AUDIT.md).
Bare Super opens the workspace overview; Super+I opens VelDock; Super+A opens
Control Center. Include the overview, app launch/focus, notifications and media
controls in both BIOS and UEFI boot tests. Test lock authentication, audio,
brightness, connectivity and power actions on intended hardware separately.
Profile validation and isolated rendering do not establish ISO boot success.

## Sources

- [Archiso documentation](https://github.com/archlinux/archiso/tree/v90/docs)
- [Hyprland configuration](https://wiki.hypr.land/Configuring/Start/)
- [GTK layer shell](https://github.com/wmww/gtk-layer-shell)
- [vivo OriginOS visual reference](https://www.vivo.com/en/originos/)

The upstream profile was copied from Archiso v90, commit
`0270567a2914330ff236ccd7d4f40eaee7b8e708`. Its license is in
[ARCHISO-LICENSE](ARCHISO-LICENSE). Original project licensing remains to be selected
by the owner; do not assume that upstream's license covers new Veldora files.

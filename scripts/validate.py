#!/usr/bin/env python3
"""Static ISO preflight; this does not claim to replace a real boot test."""
import argparse
import json
import ast
from pathlib import Path
import subprocess
import sys
import tomllib
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
PROFILE = ROOT / "archiso-profile"
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--profile', type=Path, help='Prepared ISO profile to validate')
args = parser.parse_args()
errors = []


def check(condition, message):
    if not condition:
        errors.append(message)


for path in [*(ROOT / "shell").glob("*.py"), *(ROOT / "workbench").glob("*.py"), *(ROOT / "veldora-shell").glob("*.py")]:
    ast.parse(path.read_text(), filename=str(path))
ET.parse(ROOT / "shell/notifications.xml")
tomllib.loads((PROFILE / "airootfs/etc/greetd/config.toml").read_text())
for path in list((ROOT / "scripts").glob("*.sh")) + [PROFILE / "profiledef.sh"] + list((PROFILE / "airootfs/usr/local/bin").glob("veldora-*")):
    check(subprocess.run(["bash", "-n", str(path)]).returncode == 0, f"Invalid shell: {path}")
packages = (PROFILE / "packages.x86_64").read_text().splitlines()
check(len(packages) == len(set(packages)), "Duplicate packages")
for package in "linux linux-firmware mkinitcpio-archiso hyprland python-gobject python-cairo gtk-layer-shell greetd greetd-tuigreet networkmanager foot fuzzel playerctl wireplumber quickshell qt6-declarative qt6-5compat qt6-wayland kitty breeze breeze-cursors plasma-integration ttf-material-symbols-variable noto-fonts".split():
    check(package in packages, f"Missing package: {package}")
sys.path.insert(0, str(ROOT / "workbench"))
from core import TOOLS
for tool in TOOLS:
    check(tool.package in packages, f"Unpackaged workbench tool: {tool.name}")
check((PROFILE / "airootfs/usr/share/applications/veldora-workbench.desktop").exists(), "Missing workbench desktop entry")
units = PROFILE / "airootfs/etc/systemd/system"
for name in ["greetd.service", "NetworkManager.service", "veldora-live-setup.service"]:
    check((units / "multi-user.target.wants" / name).is_symlink(), f"Service not enabled: {name}")
for path in units.rglob("*"):
    if path.is_symlink():
        check(path.name not in {"sshd.service", "iwd.service", "systemd-networkd.service", "systemd-networkd.socket"}, f"Conflicting or remote service enabled: {path}")
check((PROFILE / "airootfs/etc/shadow").read_text().startswith("root:!:"), "Live root account must be locked")
check(not (units / "getty@tty1.service.d/autologin.conf").exists(), "Root console autologin must be disabled")
for path in ["efiboot/loader/loader.conf", "syslinux/syslinux.cfg", "pacman.conf"]:
    check((PROFILE / path).exists(), f"Missing boot configuration: {path}")
if args.profile:
    root = args.profile.resolve() / 'airootfs'
    config = root / 'etc/skel/.config'
    manifest = root / 'usr/share/veldora/veldora-image-files.json'
    check(manifest.is_file(), 'Missing generated theme manifest')
    if manifest.is_file():
        for name in json.loads(manifest.read_text()):
            target = root / name.lstrip('/')
            check(target.resolve().is_relative_to(root), f'Staged asset escapes root: {name}')
            check(target.is_file(), f'Missing staged asset: {name}')
    shell = config / 'quickshell/veldora'
    for name in ['shell.qml','qmldir','VeldoraOverview.qml','VeldoraIsland.qml','VeldoraDock.qml','VeldoraEvents.js','VeldoraApps.js']:
        check((shell/name).is_file(), f'Missing shell component: {name}')
    if (shell/'veldora-settings.json').is_file():
        settings = json.loads((shell/'veldora-settings.json').read_text())
        check(settings['wallpaper'].startswith('/usr/share/veldora/'), 'Wallpaper must use an ISO runtime path')
        check((root/settings['wallpaper'].lstrip('/')).is_file(), 'Wallpaper missing from ISO')
        for pin in settings['pinnedApps']:
            check(pin in {'thunar','kitty','firefox'} or (root/f'usr/share/applications/{pin}.desktop').is_file(), f'Unresolved pinned app: {pin}')
    check(not (config/'quickshell/ii').exists(), 'Unexpected legacy end4 shell in current profile')
    for path in [config/'hypr/hyprland.lua', config/'hypr/veldora-theme.lua', *shell.glob('*.qml'), *shell.glob('*.json')]:
        if path.is_file():
            text = path.read_text()
            check('/home/codealpha' not in text and '/Documents/GitHub/' not in text, f'Host path in staged configuration: {path}')
    lua = (config/'hypr/hyprland.lua').read_text()
    check('Super_L' in lua and 'veldora-shell --overview' in lua, 'Bare Super overview binding missing')
    wrapper = (root/'usr/local/bin/veldora-shell').read_text()
    check('-c veldora' in wrapper and '-c ii' not in wrapper, 'Shell startup targets wrong configuration')
    for path in ['gtk-3.0/settings.ini','gtk-4.0/settings.ini','kdeglobals','kitty/kitty.conf','hypr/hyprlock.conf']:
        check((config/path).is_file(), f'Missing generated toolkit theme: {path}')
    print('Prepared profile assets and runtime paths checked (not an ISO build or boot).')
if errors:
    sys.exit("\n".join(errors))
print(f"Static preflight passed: {len(packages)} packages; shell, boot files, live account, and service configuration checked.")

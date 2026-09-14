#!/usr/bin/env python3
"""Static ISO preflight; this does not claim to replace a real boot test."""
import ast
from pathlib import Path
import subprocess
import sys
import tomllib
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
PROFILE = ROOT / "archiso-profile"
errors = []


def check(condition, message):
    if not condition:
        errors.append(message)


for path in [*(ROOT / "shell").glob("*.py"), *(ROOT / "workbench").glob("*.py")]:
    ast.parse(path.read_text(), filename=str(path))
ET.parse(ROOT / "shell/notifications.xml")
tomllib.loads((PROFILE / "airootfs/etc/greetd/config.toml").read_text())
for path in list((ROOT / "scripts").glob("*.sh")) + [PROFILE / "profiledef.sh"] + list((PROFILE / "airootfs/usr/local/bin").glob("veldora-*")):
    check(subprocess.run(["bash", "-n", str(path)]).returncode == 0, f"Invalid shell: {path}")
packages = (PROFILE / "packages.x86_64").read_text().splitlines()
check(len(packages) == len(set(packages)), "Duplicate packages")
for package in "linux linux-firmware mkinitcpio-archiso hyprland python-gobject python-cairo gtk-layer-shell greetd greetd-tuigreet networkmanager foot fuzzel playerctl wireplumber".split():
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
if errors:
    sys.exit("\n".join(errors))
print(f"Static preflight passed: {len(packages)} packages; shell, boot files, live account, and service configuration checked.")

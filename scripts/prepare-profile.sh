#!/usr/bin/env bash
# Stage an ISO tree only. This script never installs the desktop on the host.
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
destination=${1:-"$repo/build/profile"}
python - "$repo" "$destination" <<'PYSAFE'
from pathlib import Path
import sys
repo, destination = map(Path, sys.argv[1:])
if not destination.resolve().is_relative_to(repo.resolve() / 'build'):
    raise SystemExit('Stage profiles inside this repository’s build directory.')
PYSAFE
if [[ -e "$destination" || -L "$destination" ]]; then
    echo "Destination already exists; use a fresh directory: $destination" >&2
    exit 1
fi
mkdir -p -- "$destination"
cp -a -- "$repo/archiso-profile/." "$destination/"
config="$destination/airootfs/etc/skel/.config"
mkdir -p "$config/hypr" "$destination/airootfs/usr/share/veldora/workbench" "$destination/airootfs/usr/share/veldora/shell"
cp -- "$repo/shell/hyprland.lua" "$config/hypr/hyprland.lua"
# Keep the independently implemented GTK fallback explicitly available.
cp -- "$repo"/shell/{main.py,model.py,notifications.xml,style.css} "$destination/airootfs/usr/share/veldora/shell/"
cp -- "$repo"/workbench/{main.py,core.py,style.css} "$destination/airootfs/usr/share/veldora/workbench/"
python "$repo/veldora-shell/veldora-integrate.py" --root "$destination/airootfs"
printf 'Prepared profile: %s\n' "$destination"

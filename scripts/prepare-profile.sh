#!/usr/bin/env bash
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
destination=${1:-"$repo/build/profile"}
if [[ -e "$destination" ]]; then
    echo "Destination already exists; use a fresh directory: $destination" >&2
    exit 1
fi
mkdir -p -- "$destination"
cp -a -- "$repo/archiso-profile/." "$destination/"
mkdir -p -- "$destination/airootfs/usr/share/veldora/shell" "$destination/airootfs/etc/skel/.config/hypr"
cp -- "$repo"/shell/{main.py,model.py,notifications.xml,style.css} "$destination/airootfs/usr/share/veldora/shell/"
cp -- "$repo/shell/hyprland.lua" "$destination/airootfs/etc/skel/.config/hypr/"
mkdir -p "$destination/airootfs/usr/share/veldora/workbench"
cp -- "$repo"/workbench/{main.py,core.py,style.css} "$destination/airootfs/usr/share/veldora/workbench/"
config="$destination/airootfs/etc/skel/.config"
cp -a -- "$repo/vendor/end4/dots/.config/quickshell" "$config/"
cp -a -- "$repo/shell/end4/." "$config/quickshell/ii/"
mkdir -p "$config/illogical-impulse"
cp "$repo/shell/end4-config.json" "$config/illogical-impulse/config.json"
# Supporting paths expected by upstream actions; do not replace Veldora's compositor config.
cp -a "$repo/vendor/end4/dots/.config/hypr/hyprland" "$config/hypr/"
cp -a "$repo/vendor/end4/dots/.config/matugen" "$config/"
mkdir -p "$destination/airootfs/usr/share/licenses/veldora-end4"
cp "$repo/vendor/end4/LICENSE" "$destination/airootfs/usr/share/licenses/veldora-end4/"
cp -a "$repo/vendor/end4/licenses" "$destination/airootfs/usr/share/licenses/veldora-end4/"
printf 'Prepared profile: %s\n' "$destination"

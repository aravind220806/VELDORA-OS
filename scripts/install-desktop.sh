#!/usr/bin/env bash
# Install the desktop for the current user; preserve replaced configuration first.
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
config=${XDG_CONFIG_HOME:-"$HOME/.config"}
data=${XDG_DATA_HOME:-"$HOME/.local/share"}
backup="$data/veldora/backups/$(date +%Y%m%d-%H%M%S)-$$"
for app in python qs Hyprland fuzzel foot; do
    command -v "$app" >/dev/null || { echo "Install required application: $app" >&2; exit 1; }
done
mkdir -p "$backup" "$config" "$data/veldora" "$HOME/.local/bin" "$data/applications"
for item in quickshell/ii illogical-impulse/config.json hypr/hyprland.lua fuzzel/fuzzel.ini matugen; do
    if [[ -e "$config/$item" ]]; then
        mkdir -p "$backup/$(dirname "$item")"
        cp -a "$config/$item" "$backup/$item"
    fi
done
mkdir -p "$config/quickshell/ii" "$config/illogical-impulse" "$config/hypr" "$config/fuzzel"
cp -a "$repo/vendor/end4/dots/.config/quickshell/ii/." "$config/quickshell/ii/"
cp -a "$repo/shell/end4/." "$config/quickshell/ii/"
cp "$repo/shell/theme/storm.json" "$config/quickshell/ii/"
cp -a "$repo/vendor/end4/dots/.config/matugen" "$config/"
cp -a "$repo/shell/theme" "$repo/workbench" "$repo/shell" "$data/veldora/"
cp "$repo/shell/theme/fuzzel/fuzzel.ini" "$config/fuzzel/"
cp "$repo/shell/end4-config.json" "$config/illogical-impulse/config.json"
cp "$repo/shell/hyprland.lua" "$config/hypr/"
cp "$repo/archiso-profile/airootfs/usr/share/applications/veldora-workbench.desktop" "$data/applications/"
cp "$repo/archiso-profile/airootfs/usr/local/bin/veldora-shell" "$HOME/.local/bin/"
cp "$repo/archiso-profile/airootfs/usr/local/bin/veldora-workbench" "$HOME/.local/bin/"
python - "$config" "$data" "$HOME/.local/bin" <<'PY'
import json, sys
from pathlib import Path
config, data, binary = map(Path, sys.argv[1:])
p=config/'illogical-impulse/config.json'
c=json.loads(p.read_text()); c['background']['wallpaperPath']=str(data/'veldora/theme/black-dragon.png');p.write_text(json.dumps(c,indent=2))
p=binary/'veldora-workbench';p.write_text('#!/usr/bin/env python\nimport runpy, sys\nsys.path.insert(0, '+repr(str(data/'veldora/workbench'))+')\nrunpy.run_path('+repr(str(data/'veldora/workbench/main.py'))+', run_name="__main__")\n')
p=binary/'veldora-shell';s=p.read_text().replace("/usr/share/veldora/shell/main.py", str(data/"veldora/shell/main.py"));p.write_text(s)
p=config/'hypr/hyprland.lua';s=p.read_text();s='hl.env("PATH", '+json.dumps(str(binary)+':'+__import__('os').environ['PATH'])+')\n'+s;p.write_text(s)
PY
chmod +x "$HOME/.local/bin/veldora-shell" "$HOME/.local/bin/veldora-workbench"
echo "Installed. Backup: $backup"
echo 'Log out and back in to start the updated desktop. Existing session was not stopped.'

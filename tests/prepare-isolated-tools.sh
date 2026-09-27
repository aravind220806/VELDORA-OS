#!/usr/bin/env bash
# Optional test tools only: extract into build/, never install on the host or ISO.
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$repo"
python - <<'PY'
from pathlib import Path
import subprocess
import urllib.request
root = Path('build/isolated-tools')
root.mkdir(parents=True, exist_ok=True)
for url in subprocess.check_output(['pacman','-Sp','--print-format','%l','sway','quickshell'], text=True).splitlines():
    name = url.rsplit('/',1)[1]
    archive = root/name
    if not archive.exists():
        urllib.request.urlretrieve('https://geo.mirror.pkgbuild.com/extra/os/x86_64/'+name,archive)
    subprocess.run(['tar','-xf',str(archive),'-C',str(root)],check=True)
qs = root/'usr/bin/qs'
if qs.is_symlink():
    qs.unlink()
    qs.symlink_to('quickshell')
PY
# Aquamarine 0.15 unconditionally requests protocol v6 from nested compositors.
# Negotiate the advertised version in a test-only copy (never packaged in ISO).
source_dir="$repo/build/isolated-tools/aquamarine-src"
if [[ ! -d "$source_dir" ]]; then
    git clone --depth 1 --branch v0.15.0 https://github.com/hyprwm/aquamarine.git "$source_dir"
fi
python - "$source_dir" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])/'src/backend/Wayland.cpp'
text = path.read_text()
for interface in ['xdg_wm_base','wl_compositor']:
    text = text.replace('&'+interface+'_interface, 6)', '&'+interface+'_interface, std::min(version, 6u))')
path.write_text(text)
PY
cmake -S "$source_dir" -B build/isolated-tools/aquamarine-build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build/isolated-tools/aquamarine-build -j 3

#!/usr/bin/env bash
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
if (( EUID != 0 )); then
    echo 'ISO creation needs root for mounts and pacstrap. Run: sudo ./scripts/build-iso.sh' >&2
    exit 1
fi
for command in mkarchiso python pacman; do
    command -v "$command" >/dev/null || { echo "Missing dependency: $command" >&2; exit 1; }
done
[[ $(uname -m) == x86_64 ]] || { echo 'Build on an x86_64 Arch Linux host.' >&2; exit 1; }
python "$repo/scripts/validate.py"
# Fresh work directories prevent archiso stamp files from silently reusing old content.
mkdir -p "$repo/build" "$repo/out"
run_dir=$(mktemp -d "$repo/build/run-XXXXXXXX")
"$repo/scripts/prepare-profile.sh" "$run_dir/profile"
python "$repo/scripts/validate.py" --profile "$run_dir/profile"
echo "Build log: $run_dir/build.log"
mkarchiso -v -w "$run_dir/work" -o "$repo/out" "$run_dir/profile" 2>&1 | tee "$run_dir/build.log"
(
    cd "$repo/out"
    for iso in veldora-*.iso; do
        [[ -f "$iso" ]] || continue
        sha256sum "$iso" > "$iso.sha256"
    done
)
echo "ISO and checksums: $repo/out"
echo "Work files retained at $run_dir. Check findmnt -R before manually cleaning an interrupted build."

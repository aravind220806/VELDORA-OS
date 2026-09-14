#!/usr/bin/env bash
set -euo pipefail
if (( $# < 1 || $# > 2 )); then
    echo "Usage: $0 path/to/veldora.iso [bios|uefi]" >&2
    exit 1
fi
iso=$(realpath -- "$1")
[[ -f "$iso" ]] || { echo "ISO not found: $iso" >&2; exit 1; }
command -v qemu-system-x86_64 >/dev/null || { echo 'Install qemu-desktop and edk2-ovmf.' >&2; exit 1; }
args=(-m 4096 -smp 2 -cdrom "$iso" -boot d -nic user,model=virtio-net-pci -device virtio-vga-gl -display gtk,gl=on)
if [[ -r /dev/kvm && -w /dev/kvm ]]; then
    args+=(-enable-kvm -cpu host)
fi
case ${2:-bios} in
    bios) ;;
    uefi)
        firmware=/usr/share/edk2/x64/OVMF_CODE.4m.fd
        [[ -f "$firmware" ]] || { echo "Missing UEFI firmware: $firmware" >&2; exit 1; }
        vm_vars=$(mktemp --suffix=.fd)
        trap 'rm -f -- "$vm_vars"' EXIT
        cp /usr/share/edk2/x64/OVMF_VARS.4m.fd "$vm_vars"
        args+=(-drive "if=pflash,format=raw,readonly=on,file=$firmware")
        args+=(-drive "if=pflash,format=raw,file=$vm_vars")
        ;;
    *) echo 'Boot mode must be bios or uefi.' >&2; exit 1 ;;
esac
# No host disks or shared directories are attached.
qemu-system-x86_64 "${args[@]}"

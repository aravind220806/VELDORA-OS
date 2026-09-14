#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="veldora"
iso_label="VELDORA_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="Veldora OS Project"
iso_application="Veldora OS Live Desktop"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux'
           'uefi.systemd-boot')
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86,arm64' '-b' '1M' '-Xdict-size' '1M')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '--long' '-19')
file_permissions=(
  ["/usr/local/bin/veldora-workbench"]="0:0:755"
  ["/usr/local/bin/veldora-live-setup"]="0:0:755"
  ["/usr/local/bin/veldora-session"]="0:0:755"
  ["/usr/local/bin/veldora-shell"]="0:0:755"
  ["/etc/sudoers.d/10-veldora-live"]="0:0:440"
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/root/.gnupg"]="0:0:700"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
)

#!/usr/bin/env bash
set -euo pipefail

# === Configuración de particiones ===
DISK=/dev/sdb
BOOT_START=1MiB; BOOT_END=513MiB
SWAP_START=${BOOT_END}; SWAP_END=4.5GiB
ROOT_START=${SWAP_END}; ROOT_END=80%
HOME_START=${ROOT_END}

# Función de log
info() { echo -e "\n[*] $*"; }

info "Wiping disk $DISK"
wipefs -a "$DISK"

info "Creating GPT partitions on $DISK"
parted "$DISK" --script mklabel gpt \
  mkpart ESP fat32  "$BOOT_START" "$BOOT_END" \
  set 1 boot on \
  mkpart primary linux-swap "$SWAP_START" "$SWAP_END" \
  mkpart primary ext4       "$ROOT_START" "$ROOT_END" \
  mkpart primary ext4       "$HOME_START" 100%

info "Reloading partition table"
partprobe "$DISK"

info "Formatting partitions"
mkfs.fat  -F32 "${DISK}1"
mkswap         "${DISK}2"
mkfs.ext4      "${DISK}3"
mkfs.ext4      "${DISK}4"

info "Mounting partitions"
mount "${DISK}3" /mnt
mkdir -p /mnt/{boot,home}
mount "${DISK}1" /mnt/boot
mount "${DISK}4" /mnt/home
swapon "${DISK}2"

info "Installing base system"
pacstrap /mnt base linux linux-firmware networkmanager sudo vim nano

info "Generating fstab"
genfstab -U /mnt >> /mnt/etc/fstab

info "Copying post-install script"
cp install_arch_post.sh /mnt/root/
chmod +x /mnt/root/install_arch_post.sh

info "Entering arch-chroot"
arch-chroot /mnt /root/install_arch_post.sh
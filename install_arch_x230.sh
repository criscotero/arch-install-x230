#!/bin/bash
set -e

DISK="/dev/sdb"

echo "[*] Borrando el disco $DISK..."
wipefs -a "$DISK"

echo "[*] Creando particiones..."
parted "$DISK" --script mklabel gpt \
  mkpart ESP fat32 1MiB 513MiB \
  set 1 boot on \
  mkpart primary linux-swap 513MiB 4.5GiB \
  mkpart primary ext4 4.5GiB 340GiB \
  mkpart primary ext4 340GiB 100%

echo "[*] Formateando particiones..."
mkfs.fat -F32 "${DISK}1"
mkswap "${DISK}2"
mkfs.ext4 "${DISK}3"
mkfs.ext4 "${DISK}4"

echo "[*] Montando particiones..."
mount "${DISK}3" /mnt
mkdir -p /mnt/boot /mnt/home
mount "${DISK}1" /mnt/boot
mount "${DISK}4" /mnt/home
swapon "${DISK}2"

echo "[*] Instalando sistema base..."
pacstrap /mnt base linux linux-firmware networkmanager sudo vim nano

echo "[*] Generando fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

echo "[*] Copiando script post-instalación al sistema..."
cp install_arch_post.sh /mnt/root/
chmod +x /mnt/root/install_arch_post.sh

echo "[*] Entrando a chroot..."
arch-chroot /mnt /root/install_arch_post.sh

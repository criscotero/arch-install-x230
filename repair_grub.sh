#!/usr/bin/env bash
set -euo pipefail

# (Asegúrate de haber montado ya /dev/sdb3 en /mnt, /dev/sdb1 en /mnt/boot y haber activado swap)

echo "[*] Entrando a chroot para reparar entradas de arranque..."
arch-chroot /mnt /bin/bash <<'EOF'
set -euo pipefail

echo "[*] Limpiando entradas antiguas UEFI como 'ubuntu'..."
# Extrae BootXXXX sin prefijo y sin asterisco
for entry in $(efibootmgr | grep -i ubuntu | awk '{print $1}' | sed 's/Boot//;s/\*//'); do
  echo "  -> Borrando Boot${entry}"
  efibootmgr -b "$entry" -B
done

echo "[*] Reinstalando GRUB..."
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

echo "[*] Creando fallback loader en EFI/BOOT/BOOTX64.EFI..."
mkdir -p /boot/EFI/BOOT
cp /boot/EFI/GRUB/grubx64.efi /boot/EFI/BOOT/BOOTX64.EFI

EOF

echo "[*] Limpieza final..."
swapoff -a
umount -R /mnt

echo "Listo. Puedes reiniciar ahora y Arch debería arrancar correctamente."
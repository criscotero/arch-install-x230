#!/bin/bash
set -e

echo "[*] Configurando zona horaria e idioma..."
ln -sf /usr/share/zoneinfo/America/Bogota /etc/localtime
hwclock --systohc

sed -i 's/^#es_CO.UTF-8 UTF-8/es_CO.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=la-latin1" > /etc/vconsole.conf

echo "[*] Configurando hostname..."
echo "prometheusX230" > /etc/hostname
cat >> /etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   prometheusX230.localdomain prometheusX230
EOF

echo "[*] Estableciendo contraseña de root..."
echo "root:archlinux" | chpasswd

echo "[*] Creando usuario..."
useradd -m -G wheel -s /bin/bash christian
echo "christian:archlinux" | chpasswd
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

echo "[*] Instalando GRUB..."
pacman -S --noconfirm grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

echo "[*] Habilitando NetworkManager..."
systemctl enable NetworkManager

echo "[*] Instalando entorno gráfico XFCE..."
pacman -S --noconfirm xorg xfce4 xfce4-goodies lightdm lightdm-gtk-greeter firefox
systemctl enable lightdm

echo "[*] Instalación finalizada. Puedes reiniciar."

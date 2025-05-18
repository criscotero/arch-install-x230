#!/usr/bin/env bash
set -euo pipefail

# Función de log
info() { echo -e "\n[*] $*"; }

info "Setting timezone and locale"
ln -sf /usr/share/zoneinfo/America/Bogota /etc/localtime
hwclock --systohc
sed -i 's/^#es_CO.UTF-8 UTF-8/es_CO.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf

info "Configuring hostname and hosts"
echo "prometheusX230" > /etc/hostname
cat >> /etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   prometheusX230.localdomain prometheusX230
EOF

# Prompt para contraseña de root
info "Please set the root password"
passwd root

# Prompt para crear nuevo usuario
info "Enter the name of the new user"
read -r NEW_USER
useradd -m -G wheel -s /bin/bash "$NEW_USER"

info "Please set password for user '$NEW_USER'"
passwd "$NEW_USER"

# Habilitar sudo para el grupo wheel
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

info "Installing and configuring GRUB"
pacman -S --noconfirm grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

info "Enabling NetworkManager"
systemctl enable NetworkManager

info "Installing XFCE desktop and LightDM"
pacman -S --noconfirm xorg xfce4 xfce4-goodies lightdm lightdm-gtk-greeter firefox
systemctl enable lightdm

info "Post-installation complete. You may reboot now."
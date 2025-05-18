#!/bin/bash

set -e

SWAP_PARTITION="/dev/sda2"
SWAPFILE="/swapfile"
SWAPFILE_SIZE="4G"
GRUB_FILE="/etc/default/grub"
POLKIT_RULE="/etc/polkit-1/rules.d/50-hibernate.rules"

echo ">>> 1. Setting up swap partition..."
sudo mkswap $SWAP_PARTITION || true
sudo swapon $SWAP_PARTITION

echo ">>> 2. Creating and activating swap file..."
if [ ! -f "$SWAPFILE" ]; then
  sudo fallocate -l $SWAPFILE_SIZE $SWAPFILE
  sudo chmod 600 $SWAPFILE
  sudo mkswap $SWAPFILE
fi
sudo swapon $SWAPFILE

echo ">>> 3. Adding swap entries to /etc/fstab..."
grep -q "$SWAP_PARTITION" /etc/fstab || echo "$SWAP_PARTITION none swap sw 0 0" | sudo tee -a /etc/fstab
grep -q "$SWAPFILE" /etc/fstab || echo "$SWAPFILE none swap sw 0 0" | sudo tee -a /etc/fstab

echo ">>> 4. Configuring GRUB for resume from swap partition..."
SWAP_UUID=$(blkid -s UUID -o value $SWAP_PARTITION)
if ! grep -q "resume=UUID=" $GRUB_FILE; then
  sudo sed -i "/^GRUB_CMDLINE_LINUX_DEFAULT/ s|\"$| resume=UUID=$SWAP_UUID\"|" $GRUB_FILE
fi

echo ">>> 5. Updating GRUB..."
if [ -d /boot/grub ]; then
  sudo grub-mkconfig -o /boot/grub/grub.cfg
elif [ -d /boot/grub2 ]; then
  sudo grub2-mkconfig -o /boot/grub2/grub.cfg
fi

echo ">>> 6. Installing XFCE Power Management tools and upower..."
sudo pacman -Sy --noconfirm upower xfce4-power-manager polkit

echo ">>> 7. Creating Polkit rule to allow hibernate from GUI..."
sudo tee $POLKIT_RULE > /dev/null <<EOF
polkit.addRule(function(action, subject) {
    if (
        action.id == "org.freedesktop.login1.hibernate" &&
        subject.isInGroup("wheel")
    ) {
        return polkit.Result.YES;
    }
});
EOF

echo ">>> 8. Adding user to wheel group..."
sudo usermod -aG wheel $USER

echo ">>> 9. Instructions to finalize XFCE setup:"
echo ">>   • Reboot your system"
echo ">>   • Right-click XFCE panel > Panel > Add New Items > 'Action Buttons'"
echo ">>   • Right-click Action Buttons > Properties > Enable 'Hibernate' checkbox"

echo ">>> All done. Swap and GUI Hibernate setup complete. Reboot to apply changes."
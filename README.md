# Arch Linux Auto Install for ThinkPad X230

This repository contains two Bash scripts that automate the installation of Arch Linux on a Lenovo ThinkPad X230. It includes full disk partitioning, system setup, user creation, and XFCE desktop installation.

## Files

- `install_arch_x230.sh`: Run this from the **Live Arch ISO** environment.
- `install_arch_post.sh`: This script is automatically executed inside `chroot` to complete the installation.

## Partition Scheme

The script formats the entire `/dev/sdb` disk with the following layout:

| Partition | Mount Point | Size    | Type       |
|-----------|-------------|---------|------------|
| sdb1      | /boot       | 512MiB  | FAT32 (EFI)|
| sdb2      | swap        | ~4GiB   | swap       |
| sdb3      | /           | ~335GiB | ext4       |
| sdb4      | /home       | ~99GiB  | ext4       |

> **Warning:** This will erase all data on `/dev/sdb`.

## Usage

### 1. Boot into Arch Linux Live USB

Make sure you are connected to the internet (ethernet or `iwctl` for Wi-Fi).

### 2. Clone this repository

```bash
pacman -Sy git --noconfirm
git clone https://github.com/criscotero/arch-install-x230.git
cd arch-install-x230
chmod +x install_arch_x230.sh
```

### 3. Run the main install script

```bash
./install_arch_x230.sh
```

This will:
- Partition and format the disk
- Mount partitions
- Install base system
- Enter `arch-chroot` and run the post-install script

### 4. Reboot

Once finished, reboot and remove the USB. Arch Linux with XFCE will be ready to use.

## Default Credentials

- **Root password**: `archlinux`
- **User**: `christian` / `archlinux`

> Change these after the first login!

---

## License

MIT License. Free to use and adapt.

---

Created with love for the ThinkPad community.

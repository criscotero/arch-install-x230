# Arch Linux Auto Install for ThinkPad X230

Este repositorio ofrece un conjunto de scripts Bash para automatizar completamente la instalación y arranque de Arch Linux en un Lenovo ThinkPad X230, incluyendo:

* **setup\_from\_github.sh**: Clona tu repositorio desde GitHub y lanza el instalador principal.
* **install\_arch\_x230.sh**: Particiona el disco, formatea, monta, instala el sistema base y ejecuta el script post-instalación.
* **install\_arch\_post.sh**: Configura locales, zona horaria, usuarios, GRUB, NetworkManager y escritorio XFCE dentro de `chroot`.
* **repair\_grub.sh**: Repara las entradas UEFI obsoletas (como "ubuntu"), reinstala GRUB y crea un fallback en `EFI/BOOT/BOOTX64.EFI`.

---

## Esquema de particiones

El script formatea **TODO** el disco `/dev/sdb` con esta disposición:

| Partición | Punto de montaje | Tamaño    | Tipo        |
| --------- | ---------------- | --------- | ----------- |
| sdb1      | /boot            | 512 MiB   | FAT32 (EFI) |
| sdb2      | swap             | \~4 GiB   | swap        |
| sdb3      | /                | \~335 GiB | ext4        |
| sdb4      | /home            | Resto     | ext4        |

> **⚠️ Advertencia:** Se borrará **TODO** el contenido de `/dev/sdb`.

---

## Opciones de uso

### A. Instalación online (con Internet)

1. Arranca con el Live USB de Arch Linux.
2. Monta tu pendrive con `setup_from_github.sh` en `/mnt/usb`:

   ```bash
   mkdir -p /mnt/usb
   mount /dev/sdXn /mnt/usb   # Reemplaza sdXn
   ```
3. Copia y ejecuta:

   ```bash
   cp /mnt/usb/setup_from_github.sh /root/
   chmod +x /root/setup_from_github.sh
   cd /root
   ./setup_from_github.sh
   ```

Esto instalará Arch Linux automáticamente y lanzará el script de post-instalación.

### B. Instalación manual (Internet disponible)

1. Arranca Live USB de Arch.
2. Instala `git` e importa el repositorio:

   ```bash
   pacman -Sy git --noconfirm
   git clone https://github.com/criscotero/arch-install-x230.git
   cd arch-install-x230
   chmod +x install_arch_x230.sh
   ```
3. Ejecuta:

   ```bash
   ./install_arch_x230.sh
   ```

### C. Instalación offline (sin Internet)

1. Copia manualmente **install\_arch\_x230.sh** y **install\_arch\_post.sh** a `/root` desde un segundo USB:

   ```bash
   mount /dev/sdXn /mnt/usb
   cp /mnt/usb/install_arch_*.sh /root/
   chmod +x /root/install_arch_*.sh
   ```
2. Monta tu disco y ejecuta:

   ```bash
   cd /root
   ./install_arch_x230.sh
   ```

---

## Reparación de arranque UEFI

Si el sistema no arranca y ves entradas obsoletas (“ubuntu”) o PXE, ejecuta **repair\_grub.sh** desde Live USB:

```bash
mount /dev/sdb3 /mnt
mount /dev/sdb1 /mnt/boot
mount /dev/sdb4 /mnt/home
swapon /dev/sdb2
cp repair_grub.sh /root/
chmod +x /root/repair_grub.sh
/root/repair_grub.sh
```

Esto limpiará entradas UEFI antiguas, reinstalará GRUB y creará un fallback en `EFI/BOOT/BOOTX64.EFI`.

---

## Credenciales por defecto

* **Root**: `archlinux` (te pedirá cambiarla al primer login)
* **Usuario**: `christian` / contraseña `archlinux`

> **🔒 Recomendación:** Cambia ambas contraseñas inmediatamente.

---

## Licencia

MIT License – libre de usar y adaptar.

---

*Creado con cariño para la comunidad ThinkPad y Arch Linux.*

#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/username/arch-install-x230.git"
CLONE_DIR="arch-install-x230"

echo "[*] Verificando que 'git' esté instalado..."
if ! command -v git &> /dev/null; then
  echo "[*] Instalando git..."
  sudo pacman -Sy --noconfirm git
fi

echo "[*] Clonando repositorio desde GitHub..."
git clone "$REPO_URL"
cd "$CLONE_DIR"

echo "[*] Dando permisos de ejecución a los scripts..."
chmod +x install_arch_x230.sh install_arch_post.sh

echo "[*] Ejecutando script principal..."
./install_arch_x230.sh

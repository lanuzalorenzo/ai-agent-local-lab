#!/usr/bin/env bash
#
# install_ollama.sh
# Instalación de Ollama en Ubuntu mediante el instalador del proveedor
# Autor: Lorenzo Lanuza Arellano
# Proyecto: ai-agent-local-lab

set -euo pipefail

if ! command -v apt-get >/dev/null 2>&1; then
    echo "Error: este script requiere una distribución basada en Debian/Ubuntu." >&2
    exit 1
fi

read -r -p "Se instalará Ollama usando su instalador remoto y se habilitará el servicio. ¿Continuar? [y/N] " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Instalación cancelada."
    exit 1
fi

echo "🔧 Actualizando paquetes..."
sudo apt-get update

echo "🔧 Instalando dependencias necesarias..."
sudo apt-get install -y curl

if systemctl is-active --quiet ollama; then
    echo "Aviso: el servicio Ollama ya está activo; no se eliminará ni detendrá." >&2
fi

echo "📥 Descargando el instalador remoto de Ollama..."
INSTALLER="$(mktemp)"
trap 'rm -f "$INSTALLER"' EXIT
curl -fsSL https://ollama.com/install.sh -o "$INSTALLER"

echo "📦 Ejecutando el instalador remoto con privilegios..."
echo "Se ejecutará el instalador descargado desde ollama.com; revisa y acepta este origen antes de continuar."
sudo bash "$INSTALLER"

echo "🟩 Verificando servicio..."
sudo systemctl enable ollama
sudo systemctl start ollama

echo "🧪 Comprobando GPU..."
if ! journalctl -u ollama -n 50 --no-pager | grep -Ei "CUDA|GPU|NVIDIA"; then
    echo "⚠️ Advertencia: No se detectó GPU CUDA en Ollama."
    echo "Esto no demuestra por sí solo que la instalación haya fallado."
fi

echo "✅ Instalación completada."
echo "Puedes probar un modelo con:"
echo "    ollama run llama3.1:8b"
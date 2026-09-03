#!/usr/bin/env bash
#
# install_ollama.sh
# Instalación limpia de Ollama con soporte GPU en Ubuntu
# Autor: Lorenzo Lanuza Arellano
# Proyecto: ai-agent-local-lab

set -e

echo "🔧 Actualizando paquetes..."
sudo apt update

echo "🔧 Instalando dependencias necesarias..."
sudo apt install -y curl wget gnupg lsb-release

echo "🚫 Eliminando versiones previas de Ollama (si existen)..."
sudo systemctl stop ollama || true
sudo systemctl disable ollama || true
sudo rm -f /usr/bin/ollama || true
sudo rm -rf /usr/share/ollama || true

echo "📥 Descargando instalador oficial de Ollama..."
curl -fsSL https://ollama.com/install.sh -o /tmp/ollama_install.sh

echo "📦 Instalando Ollama..."
sudo bash /tmp/ollama_install.sh

echo "🟩 Verificando servicio..."
sudo systemctl enable ollama
sudo systemctl start ollama

echo "🧪 Comprobando GPU..."
journalctl -u ollama -n 50 --no-pager | grep -i "CUDA" || {
    echo "⚠️ Advertencia: No se detectó GPU CUDA en Ollama."
}

echo "✅ Instalación completada."
echo "Puedes probar un modelo con:"
echo "    ollama run llama3.1:8b"
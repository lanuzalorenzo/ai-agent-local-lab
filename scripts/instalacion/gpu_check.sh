#!/usr/bin/env bash
#
# gpu_check.sh
# Verificación del estado de la GPU y del servicio Ollama
# Autor: Lorenzo Lanuza Arellano
# Proyecto: ai-agent-local-lab

set -e

echo "🔧 Comprobando estado del servicio Ollama..."
systemctl status ollama --no-pager

echo ""
echo "🧪 Últimos logs del servicio (buscando GPU/CUDA)..."
journalctl -u ollama -n 50 --no-pager | grep -Ei "CUDA|GPU|NVIDIA" || {
    echo "⚠️ No se detectaron referencias a GPU en los logs recientes."
}

echo ""
echo "📊 Información de la GPU (nvidia-smi)..."
if command -v nvidia-smi >/dev/null 2>&1; then
    nvidia-smi
else
    echo "⚠️ nvidia-smi no está disponible. ¿Drivers NVIDIA instalados?"
fi

echo ""
echo "✅ Comprobación completada."
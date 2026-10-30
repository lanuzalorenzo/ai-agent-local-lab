#!/usr/bin/env bash
#
# run_agent.sh
# Ejecuta un modelo local con Ollama y muestra los últimos logs al finalizar
# Autor: Lorenzo Lanuza Arellano
# Proyecto: lab-ia-aprendizaje

set -euo pipefail

MODEL="${MODEL:-qwen2.5-coder:7b}"

if ! command -v ollama >/dev/null 2>&1; then
    echo "Error: 'ollama' no está instalado o no está en PATH." >&2
    exit 1
fi

echo "🚀 Iniciando agente local con el modelo: $MODEL"
echo ""

# Ejecutar el modelo
ollama run "$MODEL"

echo ""
echo "📜 Logs recientes del servicio Ollama:"
journalctl -u ollama -n 30 --no-pager

echo ""
echo "💡 Consejo:"
echo "Puedes cambiar el modelo al invocarlo: MODEL=qwen2.5-coder:7b ./scripts/utilidades/run_agent.sh"
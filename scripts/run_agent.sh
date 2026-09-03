#!/usr/bin/env bash
#
# run_agent.sh
# Ejecuta un modelo LLM local con Ollama y muestra logs en tiempo real
# Autor: Lorenzo Lanuza Arellano
# Proyecto: ai-agent-local-lab

MODEL="llama3.1:8b"

echo "🚀 Iniciando agente local con el modelo: $MODEL"
echo ""

# Ejecutar el modelo
ollama run "$MODEL"

echo ""
echo "📜 Logs recientes del servicio Ollama:"
journalctl -u ollama -n 30 --no-pager

echo ""
echo "💡 Consejo:"
echo "Puedes cambiar el modelo editando la variable MODEL al inicio del script."
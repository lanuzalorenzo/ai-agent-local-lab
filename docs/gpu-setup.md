# Comprobación de GPU para Ollama

## Objetivo y alcance

Procedimiento de diagnóstico para determinar si el sistema ve una GPU NVIDIA y si hay indicios de que Ollama la utiliza. No instala ni configura automáticamente drivers y no garantiza compatibilidad para todas las combinaciones de GPU, driver, runtime y modelo.

## Requisitos previos

- Ubuntu con una GPU NVIDIA y un driver instalado.
- Ollama instalado y ejecutándose.
- Acceso a `nvidia-smi`, si el driver proporciona esa herramienta.

Las versiones concretas de Ubuntu, driver, Ollama y modelo no están fijadas en este repositorio. Anótalas al documentar una ejecución real.

## Procedimiento de comprobación

1. **Comprueba si el sistema ve la GPU.**

   ```bash
   nvidia-smi
   ```

   Si no está disponible o falla, el problema precede a la comprobación de Ollama. Revisa el estado del driver y la configuración del equipo según el entorno; no cambies Secure Boot, BIOS o modo de almacenamiento como pasos genéricos.

2. **Comprueba el servicio y sus logs.**

   ```bash
   systemctl status ollama --no-pager
   journalctl -u ollama -n 50 --no-pager
   ```

   La ausencia de menciones a CUDA en un fragmento de logs no demuestra por sí sola que la GPU no se haya utilizado.

3. **Ejecuta una inferencia controlada.**

   ```bash
   ollama run llama3.1:8b
   ```

   El modelo se obtiene si no está disponible localmente. Confirma que el modelo elegido cabe en los recursos del sistema antes de usarlo.

4. **Observa actividad durante esa inferencia.**

   ```bash
   nvidia-smi
   ```

   Para documentar uso de GPU, conserva la relación temporal entre una inferencia concreta y evidencias pertinentes de logs/uso de recursos. No uses una salida de ejemplo como resultado propio.

El script [`scripts/gpu_check.sh`](../scripts/gpu_check.sh) reúne comprobaciones de servicio, logs y GPU, pero no ejecuta una inferencia ni demuestra por sí mismo que una petición se procesó en CUDA.

## Interpretación y seguridad

- GPU visible: confirma que el sistema reporta un dispositivo, no que Ollama lo esté usando.
- Servicio activo: confirma el estado reportado por systemd, no el funcionamiento del cliente Continue.
- Modelo que responde: confirma una respuesta, no el backend de cómputo utilizado.
- Evidencia de GPU durante la inferencia: respalda esa ejecución concreta; no generalizarla a otros modelos o configuraciones.

No descargues ni ejecutes scripts privilegiados, cambies drivers o desinstales paquetes como primer paso de diagnóstico. Evalúa las consecuencias y el alcance de cualquier cambio antes de aplicarlo.

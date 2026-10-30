# Comprobar la GPU para Ollama

> **Estado:** Runbook preparado. Es un procedimiento de diagnóstico; no hay una ejecución registrada en este repositorio.

Esta guía sirve para saber dos cosas: si el sistema ve una GPU NVIDIA y si Ollama la usa de verdad. No instala drivers ni cambia la configuración del equipo, y no garantiza que funcione con cualquier combinación de GPU, driver y modelo.

## Qué necesitas

- Ubuntu con una GPU NVIDIA y su driver instalado.
- Ollama instalado y en marcha.
- La herramienta `nvidia-smi`, que el driver instala.

Anota la versión de Ubuntu, del driver, de Ollama y del modelo cuando hagas la prueba. Sin esos datos, el resultado no se puede repetir.

## Pasos

### 1. Comprueba que el sistema ve la GPU

```bash
nvidia-smi
```

Si el comando falla, el problema está antes que Ollama. Revisa el driver según tu equipo. No cambies Secure Boot, la BIOS ni el modo de almacenamiento como paso de diagnóstico.

### 2. Comprueba el servicio y sus logs

```bash
systemctl status ollama --no-pager
journalctl -u ollama -n 50 --no-pager
```

La falta de la palabra CUDA en un fragmento de logs no demuestra que la GPU no se use. Los logs se leen mejor junto con la prueba del paso siguiente.

### 3. Lanza una inferencia

```bash
ollama run qwen2.5-coder:7b
```

Si el modelo no está descargado, Ollama lo descarga primero. Antes de usarlo, comprueba que cabe en la memoria del equipo.

### 4. Mira la GPU mientras responde

Con la inferencia en marcha, ejecuta otra vez:

```bash
nvidia-smi
```

Si la memoria de la GPU sube durante la respuesta, la GPU se está usando. Anota la hora de la prueba y los logs de ese momento. Ese dato vale para esa ejecución concreta; no lo extiendas a otros modelos o configuraciones.

El script [`run_agent.sh`](../../scripts/utilidades/run_agent.sh) abre una sesión con el modelo y comprueba el servicio, los logs y la GPU. No demuestra por sí solo que una petición se haya procesado en la GPU.

## Cómo leer el resultado

- **La GPU aparece en `nvidia-smi`:** el sistema la reconoce. No dice que Ollama la esté usando.
- **El servicio está activo:** systemd informa de que el servicio corre. No dice que el cliente conecte bien.
- **El modelo responde:** hay respuesta. No dice en qué parte del equipo se calculó.
- **La memoria de la GPU sube durante la respuesta:** hay uso de la GPU en esa prueba.

Ante cualquier cambio en el driver o en el sistema, evalúa antes sus consecuencias. No desinstales paquetes ni ejecutes scripts con privilegios como primer paso.

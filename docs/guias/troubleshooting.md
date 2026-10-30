# Diagnóstico del laboratorio

> **Estado:** Runbook preparado. Cada paso es una comprobación para empezar, no una solución garantizada. No se han probado todos los casos en este repositorio.

Las comprobaciones de esta guía no cambian nada en el sistema. Aplica un arreglo solo cuando sepas qué provoca el problema.

## Ollama no aparece activo

Mira el estado del servicio y sus últimos mensajes:

```bash
systemctl status ollama --no-pager
journalctl -u ollama -n 50 --no-pager
```

Antes de reiniciar, reinstalar o reemplazar archivos, comprueba qué unidad está instalada y qué dice el error. El archivo `config/ollama.service` es una referencia que no se ha validado: no lo copies encima de la unidad que ya tienes.

## El sistema no detecta la GPU

```bash
nvidia-smi
```

Si falla, el problema está en el controlador (driver) del equipo, no en Ollama. Revisa la instalación del driver según tu sistema.

No cambies Secure Boot ni las opciones de la BIOS como primer paso. Esos cambios pueden afectar a la seguridad o impedir que el equipo arranque.

## Ollama no parece usar la GPU

Revisa los logs durante una inferencia y sigue la [guía de comprobación de GPU](gpu-setup.md). Que no aparezca la palabra CUDA en un fragmento de logs no prueba nada: haz la comprobación con una inferencia completa.

Reinstalar no siempre resuelve el problema. Antes, revisa que el hardware, el driver y la memoria disponible son compatibles con el modelo.

## Continue no conecta con el modelo

- Comprueba que Ollama está activo y responde en el propio servidor.
- Revisa en Continue el proveedor, el nombre del modelo y la dirección del servidor.
- El repositorio no guarda la configuración de Continue, así que no des por buena una dirección o un formato copiado de aquí: compruébalo en tu equipo.
- No pegues logs ni prompts en reportes públicos.

## El modelo falla por falta de memoria

Anota el modelo, el mensaje de error y los recursos disponibles. Puedes probar un modelo más pequeño si sirve para la tarea. Cerrar aplicaciones o reiniciar el servicio puede ayudar, pero no siempre.

Si el modelo funciona en CPU, no significa que use la GPU. Para eso necesitas la comprobación de la sección anterior.

## Conflicto con Snap u otra instalación

Antes de tocar nada, identifica cuál es la unidad activa, dónde está el programa que se ejecuta y cómo se instaló. No borres directorios del sistema ni datos de modelos para resolver un conflicto con un solo paquete. Si decides quitar una instalación, limita la operación a ese paquete y guarda antes lo que quieras conservar.

## Los logs no dicen nada útil

Empieza por el estado del servicio y los logs con `systemctl` y `journalctl`. El script [`gpu_check.sh`](../../scripts/instalacion/gpu_check.sh) agrupa algunas comprobaciones. Si termina con error porque el servicio está parado, eso es información: el servicio no está levantado.

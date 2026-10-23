# Diagnóstico del laboratorio local

Esta guía propone comprobaciones no destructivas. No se ha verificado cada caso en este repositorio, por lo que los pasos son pistas de diagnóstico, no soluciones garantizadas.

## Ollama no aparece activo

Consulta estado y logs:

```bash
systemctl status ollama --no-pager
journalctl -u ollama -n 50 --no-pager
```

Comprueba qué paquete/unidad está instalado y qué informa el error antes de reiniciar, reinstalar o reemplazar archivos. `system/ollama.service` es una referencia no validada y no debe copiarse encima de la unidad existente como remedio general.

## El sistema no detecta la GPU

```bash
nvidia-smi
```

Si falla, diagnostica primero el driver y la configuración específica del equipo. No desactives Secure Boot ni cambies opciones de BIOS/almacenamiento de forma genérica: esos cambios pueden afectar la seguridad o impedir que el sistema arranque.

## Ollama no parece usar GPU

Revisa los logs durante una inferencia y consulta [`docs/gpu-setup.md`](gpu-setup.md). La falta de una palabra clave en una muestra de logs no es concluyente. Comprueba compatibilidad de hardware/runtime y disponibilidad de memoria sin asumir que reinstalar resolverá el problema.

## Continue no conecta con el modelo

- Comprueba que Ollama está activo y responde localmente.
- Revisa en la configuración de Continue el proveedor, el identificador del modelo y el endpoint.
- No des por supuesto un endpoint o formato de API a partir de este repositorio: no se versiona la configuración de Continue.
- No pegues logs, prompts ni datos sensibles en reportes públicos.

## El modelo falla por memoria

Registra el modelo utilizado, el mensaje de error y los recursos disponibles. Prueba un modelo de menor tamaño solo si es adecuado para la tarea y está disponible; cerrar aplicaciones o reiniciar el servicio son opciones operativas, no soluciones garantizadas. No interpretes la ejecución en CPU como prueba de aceleración GPU.

## Sospecha de conflictos con Snap u otra instalación

Identifica el origen de la unidad activa, la ruta del ejecutable y el método de instalación antes de modificar el sistema. No elimines directorios del sistema, datos de modelos ni toda la infraestructura Snap para resolver un conflicto de un único paquete. Si decides retirar una instalación, limita la operación al paquete confirmado y protege antes los datos que quieras conservar.

## Logs vacíos o sin información suficiente

Consulta primero estado y logs con `systemctl`/`journalctl`; [`scripts/gpu_check.sh`](../scripts/gpu_check.sh) agrupa algunas comprobaciones. El script puede terminar con error si el servicio está parado; eso debe tratarse como información diagnóstica, no ocultarse.

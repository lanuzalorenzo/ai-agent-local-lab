# Contenedores para el servicio de inferencia (diseño)

> **Estado:** Diseño. No hay Dockerfile, Compose ni ejecución asociada.

## Qué es

Un contenedor es una caja que incluye un programa con todo lo que necesita para funcionar. Con Docker, el servicio de inferencia (Ollama y el modelo) se levantaría igual en cualquier equipo, sin instalarlo a mano sobre el sistema.

## Qué se ganaría

- **Arranque automático.** El servicio vuelve a levantarse solo después de reiniciar el servidor.
- **Mismo resultado en cualquier equipo.** Lo que funciona aquí funciona en otro sitio, porque el entorno viaja con el servicio.
- **Modelos guardados fuera del contenedor.** Los modelos y las imágenes se guardan en volúmenes, así que no se pierden al recrear el contenedor.

## Qué falta para hacerlo

- Comprobar que la GPU funciona dentro del contenedor. Eso requiere herramientas de NVIDIA que no se han probado en este repositorio.
- Decidir si el contenedor sustituye a la instalación directa o convive con ella.
- Medir si el coste de mantenerlo compensa. Hoy el servicio se instala directamente y funciona.

## Cuándo se retomaría

Cuando haya que mover el servicio a otro equipo o reconstruirlo con frecuencia. Hasta entonces, la [guía de despliegue](../guias/server-deployment-ubuntu-ollama.md) sigue siendo la referencia.

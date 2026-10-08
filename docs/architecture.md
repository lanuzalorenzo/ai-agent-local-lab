# Arquitectura del laboratorio

## Propósito y alcance

Este documento describe el flujo que el repositorio pretende facilitar: usar Ollama como runtime local y acceder a un modelo desde VS Code mediante Continue. Es una descripción de diseño, no una prueba de que todos los componentes estén instalados o configurados.

## Componentes y límites de confianza

| Componente | Responsabilidad | Consideraciones |
|---|---|---|
| VS Code + Continue | Interfaz y cliente del asistente | La configuración del cliente no está versionada; debe revisarse qué proveedor y endpoint usa |
| Ollama | Recibe peticiones y ejecuta el modelo | El repositorio no verifica la interfaz de red en la que escucha ni define controles de autenticación |
| Modelo | Genera respuestas a partir del prompt y el contexto disponible | No se fija una versión; la calidad y el consumo dependen del modelo seleccionado |
| GPU NVIDIA / driver | Posible aceleración de inferencia | La GPU puede no estar disponible para el servicio; CPU/GPU y uso real deben verificarse por ejecución |
| Scripts del repositorio | Instalación, diagnóstico y ejecución interactiva | Algunos pasos necesitan privilegios; revisar antes de ejecutar |
| systemd | Gestión del proceso persistente | `system/ollama.service` es una referencia no validada y no debe reemplazar automáticamente la unidad existente |

## Flujo previsto

1. El usuario configura Continue para conectarse a Ollama en el mismo equipo.
2. Continue envía una petición y el contexto que corresponda al endpoint configurado.
3. Ollama carga el modelo seleccionado y procesa la petición en CPU o GPU según compatibilidad y disponibilidad.
4. Continue presenta la respuesta.
5. El usuario verifica por separado servicio, logs y uso de recursos si necesita confirmar el comportamiento.

El flujo no implica que Continue solo envíe datos a Ollama ni que el contenido del repositorio nunca salga del equipo. Esa propiedad depende de la configuración efectiva y debe comprobarse antes de usar información sensible.

## Artefactos del repositorio

- `scripts/install_ollama.sh`: instala Ollama utilizando el instalador remoto del proveedor.
- `scripts/gpu_check.sh`: consulta servicio, logs y `nvidia-smi`.
- `scripts/run_agent.sh`: abre una sesión interactiva de Ollama con el modelo definido en el script.
- `docs/gpu-setup.md`: pasos de comprobación de GPU.
- `docs/troubleshooting.md`: diagnóstico conservador.
- `examples/`: ejemplos ilustrativos, sin evidencias de ejecución adjuntas.
- `system/ollama.service`: unidad de referencia cuyo usuario, rutas, permisos y compatibilidad con GPU no se han validado aquí.

## Validación necesaria para una instalación concreta

Para afirmar que una instalación funciona, registra el sistema y versiones relevantes, el modelo exacto, la configuración del endpoint y los resultados de pruebas realizadas. Para afirmar que se utilizó GPU, recoge evidencia durante una inferencia; detectar la GPU en el sistema no es suficiente. No incluyas logs con prompts, rutas privadas, tokens u otros datos sensibles.

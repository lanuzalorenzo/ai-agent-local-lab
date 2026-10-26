# Coste de contexto y optimización de prompts

> **Privado del laboratorio.** Marco de referencia para controlar el consumo de tokens y el coste de contexto en sesiones con agentes. No es una evidencia de ejecución; describe riesgos, controles y verificación.

## 1. El riesgo

El coste de una sesión no está solo en la respuesta del modelo. Está en todo lo que se envía en cada petición:

- Instrucciones fijas (`AGENTS.md`, prompts de sistema, reglas).
- Historial de la conversación y resultados de herramientas.
- Archivos leídos por el agente, incluidos binarios o evidencias grandes si no se filtran.
- Contexto recuperado por MCP o por búsqueda local.

Un contexto grande no solo cuesta más: degrada la atención del modelo, aumenta la latencia y puede provocar truncado o pérdida de instrucciones críticas. En un laboratorio local, el mismo problema aparece como saturación de la ventana de contexto y respuestas incoherentes.

Ejemplo medido en este laboratorio: el esquema MCP de XERJ añadía ~14,2 k tokens fijos por sesión, por encima del ahorro esperado. El piloto se descartó por esa razón.

## 2. Controles aplicados

### 2.1 Filtrado de entrada

- `.opencodeignore` en cada repositorio: convención de proyecto. Medido el 2026-10-26 en OpenCode v2.1.4: **no filtra** lo que devuelven `glob`, `grep` ni `read`, así que no cuenta como ahorro real.
- Regla de no abrir material archivado (briefs antiguos, diario y agenda archivados, evidencias ya cerradas): el ahorro viene de no leerlo, no de un fichero de exclusiones.
- `watcher.ignore` en la configuración global para evitar reindexar rutas de build.
- `tool_output` acotado (líneas y bytes por resultado) y lectura por rangos (`offset`/`limit`) con `grep` en lugar de `cat` de archivos completos.

### 2.2 Instrucciones compactas

- `AGENTS.md` por repositorio compactado: solo reglas y convenciones locales; el detalle vive en documentos de referencia y se lee bajo demanda.
- Un enrutador por workspace (`AGENTS.md del workspace`) en lugar de duplicar el mapa en cada repo.

### 2.3 Archivado

- Los documentos antiguos o resueltos se mueven a carpetas `archivadas/` o sufijo `-archivo.md`.
- No se leen por defecto; solo bajo demanda explícita.
- El diario, la agenda y la guía mantienen solo la parte activa; el histórico queda archivado.

### 2.4 Compactación automática

- `compaction.auto: true` con `keep.tokens` bajo (8000) para conservar solo el contexto reciente.
- `compaction.prune: true` para podar salidas de herramientas antiguas.
- `experimental.background_compaction: true` para no bloquear la sesión.

### 2.5 Salida de herramientas acotada

- `tool_output.max_lines` y `max_bytes` limitados para evitar que una salida gigante entre en el contexto.
- Las evidencias pesadas (imágenes, PDF) se leen solo cuando la tarea lo exige.

### 2.6 Selección de modelo

- Modelo por defecto gratuito (`opencode/deepseek-v4.1-flash-free`) para no depender de suscripciones de pago.
- Reservar modelos de razonamiento para decisiones de diseño y seguridad; usar modelos rápidos para DTOs, tests, Markdown e índices.

## 3. Prevención en el flujo de trabajo

- **Un repo, un objetivo, un ítem por sesión.** No abrir dos frentes a la vez.
- **Prompt atómico**: indicar repo, ítem, objetivo, archivos a leer y archivos a no leer.
- **No cargar el plan completo** si el estado compacto ya responde: basta el backlog del plan de trabajo.
- **No leer archivos archivados** salvo que falte contexto.
- **Cerrar la sesión con un brief** para que la siguiente no tenga que releer todo.
- **Medir**: usar `opencode stats` o las métricas del proveedor para detectar picos; investigar la causa antes de aceptarlos.

## 4. Verificación

- `git status -s` solo de los repos implicados, no del workspace entero.
- `check-guia.sh` del repositorio privado de notas para comprobar que los comandos y la guía están sincronizados.
- Revisar periódicamente el tamaño de los archivos que se cargan con frecuencia (`AGENTS.md` y el backlog del plan).
- Si un archivo supera ~8 KB y se lee en cada sesión, evaluar compactarlo o archivar parte de su contenido.

## 5. Relación con seguridad

El coste de contexto es también un riesgo de disponibilidad y de integridad:

- Un prompt inyectado en una salida de herramienta grande puede colarse en el contexto y alterar el comportamiento.
- Un contexto saturado puede hacer que el modelo ignore instrucciones de seguridad o validación.
- La prevención pasa por acotar salidas, filtrar archivos y mantener instrucciones compactas y verificables.

## 6. Límites

- Este documento no afirma ahorros medidos en este laboratorio; solo describe controles aplicados y su justificación.
- Los valores de `keep.tokens`, `max_lines` y `max_bytes` son puntos de partida; deben ajustarse según el modelo y la tarea.
- No sustituye a las políticas de privacidad ni a los límites de cuota del proveedor.
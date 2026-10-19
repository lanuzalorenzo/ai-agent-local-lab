# Caso de Estudio: Migración de Continue a OpenCode con Qwen 2.5 Coder y Ollama Remoto

Repositorio: `ai-agent-local-lab` — Laboratorio y Portfolio de Aprendizaje en IA Local  
Ámbito: Migración del cliente de desarrollo de asistente de IA  
Estado: Documento de diseño y aprendizaje; distingue resultados validados de trabajo pendiente

---

## 1. Resumen Ejecutivo

Este caso de estudio documenta la migración del asistente de desarrollo integrado en VS Code de **Continue** a **OpenCode**, manteniendo el runtime de inferencia local basado en **Ollama** desplegado en un servidor bare-metal remoto (Ubuntu Server headless) y pasando del modelo `portfolio-agent` (basado en `llama3`) al modelo de codificación **Qwen 2.5 Coder**, servido a través de Ollama remoto.

El objetivo del laboratorio es conservar la soberanía de datos y la ejecución on-premise, reemplazando el cliente de asistente por una herramienta de línea de comandos y automatización de agentes (OpenCode) sin introducir dependencias de APIs cloud de terceros.

---

## 2. Contexto y Escenario

### 2.1 Estado inicial (antes de la migración)

| Componente | Configuración | Origen / Estado en el repositorio |
|---|---|---|
| Runtime de inferencia | Ollama en servidor Ubuntu Server headless, puerto `11434` | Desplegado y documentado en `docs/server-deployment-ubuntu-ollama.md` |
| Endpoint Ollama remoto | `http://ollama.lab.local:11434` | Accesible desde el equipo cliente mediante red local / SSH |
| Modelo | `portfolio-agent` (basado en `llama3`, `num_ctx 16384`) | `system/Modelfile.portfolio-agent` y entrada 04 de la bitácora |
| Cliente asistente | VS Code + extensión Continue | Documentado en `docs/continue-remote-ollama-setup.md` |
| Configuración cliente | `~/.continue/config.yaml` con `provider: ollama`, `apiBase`, `contextLength: 16384` | No versionada en el repositorio |

### 2.2 Estado objetivo (tras la migración)

| Componente | Configuración planeada | Notas |
|---|---|---|
| Runtime de inferencia | Ollama en servidor Ubuntu Server headless, puerto `11434` | Sin cambios; se reutiliza el despliegue existente |
| Endpoint Ollama remoto | `http://ollama.lab.local:11434` | Se reutiliza; acceso desde el cliente mediante red local |
| Modelo | `qwen2.5-coder` (servido por Ollama) | Modelo de codificación descargado en el servidor Ollama |
| Cliente asistente | OpenCode (CLI) | Nueva herramienta cliente; sustituye a Continue en VS Code |
| Configuración cliente | Configuración de OpenCode apuntando al endpoint Ollama remoto | Por definir; no versionada aún |

---

## 3. Motivación de la Migración

1. **Enfoque en tareas de codificación:** Qwen 2.5 Coder es un modelo especializado en generación y edición de código, más adecuado que un modelo de propósito general (`llama3`) para el desarrollo del portfolio técnico y del laboratorio de IA.
2. **Reducción de superficie del cliente:** OpenCode opera como cliente ligero de agentes desde la terminal, evitando la extensión de VS Code y su configuración de ventana de contexto sincronizada (`contextLength` vs `num_ctx`).
3. **Mantenimiento de la ejecución local:** Se conserva Ollama como runtime on-premise; no se migra a APIs cloud ni se exponen prompts o código a proveedores externos.
4. **Automatización y scriptabilidad:** OpenCode permite orquestar flujos de agente desde línea de comandos, alineado con la filosofía headless y scriptable del laboratorio (`scripts/`, `systemd`).

---

## 4. Comparativa de Arquitectura

| Aspecto | Antes: Continue + Ollama | Después: OpenCode + Ollama |
|---|---|---|
| Cliente | Extensión de VS Code (GUI) | CLI de OpenCode (terminal) |
| Modelo | `portfolio-agent` (`llama3`, propósito general) | `qwen2.5-coder` (especializado en código) |
| Runtime | Ollama remoto en `ollama.lab.local:11434` | Ollama remoto en `ollama.lab.local:11434` (sin cambios) |
| Contexto | Sincronización `contextLength` / `num_ctx` (16K) | Gestión de contexto nativa de OpenCode contra Ollama |
| Inyección de contexto | `@file`, `@folder`, `@workspace`, `@code` | Contexto de archivos y comandos de OpenCode |
| Ejecución | Interactiva dentro del editor | Interactiva y automatizable desde terminal |
| Datos sensibles | Configuración de cliente no versionada | Configuración de cliente no versionada; no incluir credenciales |

---

## 5. Componentes y Versiones (referencia)

- **Servidor:** Ubuntu Server headless (bare-metal), Ollama como servicio systemd en puerto `11434`.
- **Cliente:** equipo de desarrollo con acceso SSH/red local al servidor.
- **Modelo destino:** `qwen2.5-coder` (GGUF quantized, servido por Ollama). La cuantía exacta (por ejemplo Q4_K_M, Q5_K_M, Q8_0) debe registrarse tras la descarga real en el servidor.
- **Cliente asistente:** OpenCode (versión por definir en la instalación efectiva).

> **Nota:** Las versiones exactas de Ollama, OpenCode y el modelo `qwen2.5-coder` deben anotarse en el momento de la instalación efectiva. Esta guía no las fija porque no se han validado en una ejecución concreta en este repositorio.

---

## 6. Pasos de la Migración

### 6.1 Preparación del servidor Ollama remoto

1. Verificar que el servicio Ollama está activo y escuchando en el servidor remoto:
   ```bash
   systemctl status ollama
   journalctl -u ollama --no-pager -n 50
   ```
2. Descargar el modelo de codificación en el servidor remoto:
   ```bash
   ollama pull qwen2.5-coder
   ```
3. Verificar que el modelo está disponible localmente en el servidor:
   ```bash
   ollama list
   ```
4. Confirmar conectividad desde el equipo cliente al endpoint remoto:
   ```bash
   curl -s http://ollama.lab.local:11434/api/tags
   ```

> No se incluyen credenciales, claves API ni identificadores personales. La exposición del endpoint en la red debe revisarse con `ufw` o túnel SSH/VPN antes de usar datos sensibles (véase el Eje 2 de la hoja de ruta en `docs/bitacora-decisiones-aprendizaje.md`).

### 6.2 Instalación y configuración del cliente OpenCode

1. Instalar OpenCode en el equipo cliente siguiendo la documentación oficial del proyecto.
2. Configurar OpenCode para que utilice el endpoint Ollama remoto en lugar de un proveedor cloud. La configuración debe apuntar a `http://ollama.lab.local:11434` y al modelo `qwen2.5-coder`.
3. Probar una solicitud de inferencia simple contra el servidor remoto sin incluir datos sensibles ni código privado.

### 6.3 Traslado de flujos de trabajo desde Continue

- Reemplazar la inyección de contexto bajo demanda de Continue (`@file`, `@folder`, `@workspace`, `@code`) por el mecanismo de contexto de archivos y comandos de OpenCode.
- Revisar las instrucciones del sistema y el rol (*asistente de desarrollo*, criterio de trabajo acordado, activo `lab-api-local-azure`) definidos en `system/Modelfile.portfolio-agent` y adaptarlos al prompt del sistema de OpenCode si es necesario.
- Validar que el modelo `qwen2.5-coder` responde correctamente a tareas de codificación y arquitectura del portfolio.

### 6.4 Descomisión de Continue (opcional)

- Conservar `docs/continue-remote-ollama-setup.md` como referencia histórica de la configuración previa.
- No eliminar la extensión de VS Code hasta que OpenCode haya sido validado para los casos de uso del laboratorio.

---

## 7. Resultados Esperados y Métricas de Validación

Esta sección describe qué se espera verificar tras la migración. Ninguna de estas métricas está validada aún en el repositorio; debe registrarse la evidencia de una ejecución real antes de afirmarla.

| Métrica / Comprobación | Método propuesto | Criterio de aceptación | Estado |
|---|---|---|---|
| Modelo disponible en Ollama remoto | `ollama list` en el servidor | `qwen2.5-coder` aparece en la lista | Pendiente |
| Conectividad cliente → Ollama remoto | `curl` / solicitud de OpenCode | Respuesta exitosa sin error de conexión | Pendiente |
| Inferencia de código con Qwen 2.5 Coder | Solicitud de codificación desde OpenCode | El modelo genera código válido y relevante | Pendiente |
| No fuga de datos a cloud | Revisar configuración de OpenCode y tráfico de red | Todas las peticiones van a `ollama.lab.local:11434` | Pendiente |
| Comparativa de utilidad para codificación | Uso cualitativo en tareas del portfolio | Qwen 2.5 Coder resulta más útil que `llama3` para código | Pendiente (subjetivo) |

---

## 8. Lecciones Aprendidas (del entorno previo que se conserva)

- La sincronización exacta entre `contextLength` del cliente y `num_ctx` del servidor fue crítica en Continue para evitar errores de longitud de contexto. Con OpenCode se debe verificar cómo gestiona la ventana de contexto contra Ollama.
- Un prompt de sistema ligero y la inyección de contexto bajo demanda redujeron drásticamente el TTFT (Time To First Token) frente a un prompt masivo estático (documentado en la Entrada 04 de la bitácora).
- Detectar una GPU en el sistema no demuestra que Ollama usara CUDA; cualquier afirmación de aceleración requiere evidencia durante una inferencia real.

---

## 9. Limitaciones y Trabajo Pendiente

- **No validado:** Este caso de estudio es un documento de diseño. La instalación de OpenCode, la descarga de `qwen2.5-coder` y las pruebas de inferencia contra Ollama remoto no se han ejecutado en este repositorio.
- **Versiones no fijadas:** Ollama, OpenCode y la cuantía del modelo `qwen2.5-coder` no están versionadas aquí.
- **Seguridad de red:** No se ha configurado ni verificado restricción de firewall, túnel SSH ni proxy inverso TLS para el endpoint de Ollama.
- **Hoja de ruta relacionada:** Véase el Eje 3 (Integración de Clientes y Asistentes de Desarrollo) y el Eje 4 (RAG Local y Agentes Autónomos) de `docs/bitacora-decisiones-aprendizaje.md`.

---

## 10. Conclusión

La migración de Continue a OpenCode con Qwen 2.5 Coder sobre Ollama remoto permite mantener la ejecución local y privada de inferencia mientras se adopta un modelo especializado en codificación y un cliente más ligero y scriptable. Los próximos pasos son instalar OpenCode en el equipo cliente, descargar `qwen2.5-coder` en el servidor Ollama, configurar el endpoint remoto y registrar las evidencias de una ejecución real antes de considerar la migración completa.

---
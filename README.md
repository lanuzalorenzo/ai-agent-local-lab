<img src="assets/iconos/ia-local.svg" width="64" alt="Icono del laboratorio de IA local">

# Laboratorio y Portfolio de Aprendizaje en IA Local

Laboratorio personal y bitácora técnica de **IA local aplicada a desarrollo y seguridad**. Documenta las decisiones de arquitectura, la resolución de incidentes, el despliegue bare-metal (Ubuntu Server + Ollama), la integración de asistentes y la hoja de ruta (RAG, cuantización, agentes locales, continuidad de sesiones y evaluación de seguridad con LLM).

## Propósito del repositorio

| Objetivo | Qué deja en el repositorio |
|---|---|
| Memoria técnica y reinstalabilidad | Procedimientos y resolución de problemas para replicar el entorno de forma reproducible |
| Bitácora de decisiones | El *por qué* de cada elección: sistema headless, red declarativa, consumo de RAM/VRAM y modelos evaluados |
| Portfolio de aprendizaje | Patrones con agentes, continuidad de sesiones, evaluación de salidas y seguridad de funciones con LLM; también GGUF, aceleración hardware, RAG local y privacidad |

## Alcance

**Incluye:** inferencia local con Ollama, clientes de desarrollo (Continue, OpenCode), flujos híbridos local/cloud, patrones de continuidad entre sesiones, evaluación de calidad y pruebas de seguridad de funciones con LLM.

**No incluye:** rankings de modelos, noticias de IA, tutoriales genéricos de prompting ni comparativas de rendimiento sin medición propia. El eje sigue siendo **local-first**: el cloud aparece como complemento justificado, no como tema principal.

## Descripción del escenario y objetivo de seguridad

**Escenario:** Servidor dedicado bare-metal (Ubuntu Server headless) ejecutando modelos de lenguaje locales con Ollama (Qwen 2.5 Coder 7B como modelo operativo; Llama 3 y Mistral evaluados inicialmente) administrado remotamente vía SSH desde equipo cliente, con soporte para integración en clientes de desarrollo (VS Code + Continue).

**Objetivo:** Documentar la configuración, la resolución de bloqueos de conectividad, la optimización de recursos de cómputo y las comprobaciones operativas para disponer de un asistente de IA privado y auditable.

**Alcance:** Instalación del sistema base headless, pila de red Netplan/NetworkManager, OpenSSH, runtime de Ollama, evaluación de modelos interactivos y arquitectura de clientes.

> [!NOTE]
> La ejecución local garantiza soberanía de datos sobre el cómputo del modelo, pero exige verificar la exposición de puertos de red, políticas de firewall y la configuración del cliente consumidor para evitar fugas inadvertidas.

## Arquitectura y componentes utilizados

![Arquitectura local: el equipo cliente usa VS Code con Continue y OpenCode; ambos consumen la inferencia de Ollama por HTTP en el puerto 11434 y administran el servidor por SSH. Dentro del servidor headless, Ollama sirve el modelo qwen2.5-coder:7b y el puerto queda limitado a la red de laboratorio](docs/arquitectura-local.svg)

| Componente | Función | Estado documentado |
|---|---|---|
| Ubuntu Server (Headless) | Sistema operativo bare-metal optimizado (CLI puro) para maximizar VRAM y RAM dedicadas al cómputo de LLMs | Guía completa en [`docs/guias/server-deployment-ubuntu-ollama.md`](docs/guias/server-deployment-ubuntu-ollama.md) |
| Red (Netplan + NetworkManager) | Pila de red en dos fases: Ethernet declarativo vía Netplan y posterior gestión Wi-Fi con `nmtui` | Documentado en la guía de despliegue |
| OpenSSH | Canal de administración remota segura desde el equipo cliente | Verificado y documentado |
| Ollama | Runtime para servir y ejecutar modelos de lenguaje en el puerto 11434 | Servicio systemd gestionado; instalación vía script oficial |
| Modelos de Inferencia | Pesos de modelos locales; `qwen2.5-coder:7b` es el modelo operativo. Llama 3 y Mistral se evaluaron inicialmente | Bucle interactivo evaluado; modelo operativo definido en `config/Modelfile.portfolio-agent` |
| GPU NVIDIA y driver | Aceleración de inferencia cuando runtime y hardware son compatibles | Comprobación orientativa documentada en `docs/guias/gpu-setup.md` |
| VS Code + Continue | Interfaz cliente que puede conectarse al runtime local | Configuración de cliente y asistente |
| Scripts | Instalación, ejecución del laboratorio de robustez, diagnóstico y ejecución interactiva | `scripts/instalacion/`, `scripts/robustez/`, `scripts/utilidades/`; requieren revisión y permisos adecuados |
| Unidad systemd | Referencia de servicio | `config/ollama.service` no está validada como reemplazo de la unidad creada por el instalador |

Flujo de trabajo: el servidor ejecuta Ubuntu Server sin interfaz gráfica. Desde el equipo principal se administra el servidor vía SSH. Ollama ejecuta el daemon y sirve el modelo operativo (`qwen2.5-coder:7b`) en el puerto 11434. El cliente de desarrollo (VS Code / Continue) o la consola interactiva consumen la inferencia localmente.

## Seguridad del laboratorio

| Control | Implementación | Límite |
|---|---|---|
| Exposición de Ollama | Escucha limitada a la red de laboratorio; no se publica en Internet | Requiere firewall y verificación con `ss -lntp` |
| Acceso remoto | SSH para administración; proxy con TLS si cruza redes no confiables | No se incluye configuración de proxy |
| Claves de API cloud | Variables de entorno (`{env:NVIDIA_API_KEY}`) | No se versionan claves |
| Datos de contexto | Código de laboratorio y datos sintéticos | No usar prompts privados ni datos de clientes |
| Prompts privados | Fuera del repositorio y del contexto cloud | No se referencian rutas privadas |
| Modelos | Descarga desde fuentes oficiales; licencia revisada | La procedencia debe verificarse en cada actualización |
| Logs | Tratados como potencialmente sensibles | No se publican logs con prompts |

Checklist antes de usar el laboratorio:

- [ ] Ollama no escucha en `0.0.0.0` sin firewall.
- [ ] El puerto `11434` no está expuesto a Internet.
- [ ] La clave de API cloud está en el entorno, no en `opencode.json`.
- [ ] El contexto enviado al cloud no contiene secretos ni datos personales.
- [ ] El modelo local y su licencia están identificados.

## Implementación de controles y seguridad

| Aspecto | Tratamiento en este repositorio | Límite |
|---|---|---|
| Cambios de sistema | El script de instalación requiere privilegios y puede instalar software y habilitar un servicio | Revisar el script y el instalador remoto antes de ejecutarlos |
| Desinstalación | El script ya no elimina instalaciones previas ni datos automáticamente | Resolver conflictos de instalaciones manualmente y con alcance acotado |
| Datos de entrada | Se recomienda usar código y prompts no sensibles en las demos | No se versionan controles de acceso, retención ni configuración completa de Continue |
| Exposición del servicio | El repositorio no configura ni verifica el alcance de escucha de la API | Comprobar endpoint, interfaz de red y conectividad antes de usar datos sensibles |
| Evidencias | Los ejemplos distinguen instrucciones de resultados realmente observados | Las evidencias de ejecución (robustez de prompts) están en `docs/evidencias/`; los ejemplos no son ejecuciones reproducibles automatizadas |

## Validación o pruebas documentadas

| Comprobación | Método | Criterio | Estado en este repositorio |
|---|---|---|---|
| GPU visible para el sistema | `nvidia-smi` | El comando identifica una GPU compatible | Procedimiento documentado; no consta aquí una ejecución |
| Estado del servicio | `systemctl status ollama` y `journalctl` | Servicio activo y logs pertinentes | Procedimiento documentado; no consta aquí una ejecución |
| Uso de GPU por Ollama | Revisar logs durante una inferencia y observar carga con `nvidia-smi` | Evidencia coincidente durante la misma prueba | No verificado en este repositorio |
| Integración con Continue | Enviar una petición de prueba sin datos sensibles | El cliente responde mediante el endpoint esperado | Configuración y resultado no versionados |

Consulta la [bitácora técnica y hoja de ruta](docs/referencia/bitacora-decisiones-aprendizaje.md), la [integración de Continue con Ollama remoto y contexto 16K](docs/guias/continue-remote-ollama-setup.md), el [despliegue de servidor Ubuntu Server](docs/guias/server-deployment-ubuntu-ollama.md), la [configuración de GPU](docs/guias/gpu-setup.md), la [arquitectura del laboratorio](docs/arquitectura/architecture.md), la [guía de diagnóstico](docs/guias/troubleshooting.md) y el [caso de estudio de OpenCode](docs/referencia/CASE_STUDY_OPENCODE_MIGRATION.md).

Documentos aplicados:

| Documento | Qué aporta |
|---|---|
| [Continuidad de sesiones con OpenCode](docs/guias/opencode-session-continuity.md) | Comandos, briefs y estado en archivos |
| [Evaluación y seguridad de una función con LLM](docs/referencia/ai-security-evaluation.md) | Conjunto dorado, inyección, métricas y CI |
| [Robustez de prompts frente a perturbaciones de entrada](docs/referencia/prompt-robustness-testing.md) | Cargas canario, familias de transformación, matriz de intensidad y métricas de evasión |
| [Evidencia del instrumento](docs/evidencias/2026-10-22-robustez-instrumento/README.md) | 113 casos congelados, 15 transformaciones activas y un control negativo; sin medición de modelo |
| [Ejecución con modelo](docs/evidencias/2026-10-22-robustez-ejecucion-v1/README.md) | `qwen2.5:3b`, N0 y N1; la inyección directa funciona sin transformar |
| [Línea base con el instrumento corregido](docs/evidencias/2026-10-22-robustez-ejecucion-v2/README.md) | Control negativo 3/3 válido; la obediencia en N0 se reproduce en 0,50 |
| [Prompt v2 endurecido](docs/evidencias/2026-10-26-robustez-prompt-v2/README.md) | 15 inferencias en N0: misma obediencia (0,50) y mismos canarios; la defensa no puede vivir en el prompt |
| [Fase de ejecución](docs/referencia/prompt-robustness-testing.md#13-fase-de-ejecución) | `scripts/robustez/run_robustness_lab.sh` instala, ejecuta y restaura el equipo |
| [Inferencia local frente a cloud](docs/guias/local-vs-cloud.md) | Criterios de decisión y errores frecuentes |

## Lecciones aprendidas y límites

- «Local» describe dónde se ejecuta Ollama, no prueba que todos los componentes del flujo sean locales ni que la configuración sea privada.
- La presencia de una GPU y una respuesta del modelo no bastan para demostrar que Ollama usó CUDA; hay que observar la inferencia y sus evidencias.
- La instalación desde un script remoto implica confiar en el proveedor y en el contenido recibido en ese momento. La instalación no está fijada a una versión.
- La unidad incluida en `system/` es una referencia no verificada; no debe copiarse encima de la unidad instalada sin revisar usuario, permisos, rutas y acceso al hardware.
- Los ejemplos son material ilustrativo/documental, no mediciones de rendimiento ni registros de una sesión demostrada.

El detalle operativo está en [`docs/`](docs/) (ver [`docs/README.md`](docs/README.md) para navegación); los ejemplos de interacción, en [`examples/`](examples/). Licencia: MIT.

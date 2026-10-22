# Laboratorio y Portfolio de Aprendizaje en IA Local

Laboratorio personal y bitácora técnica de **IA local aplicada a desarrollo y seguridad**. Documenta paso a paso las decisiones de arquitectura, la resolución de incidentes, el despliegue bare-metal (Ubuntu Server + Ollama), la integración de asistentes y la hoja de ruta para futuras ampliaciones (RAG, cuantización, agentes locales, continuidad de sesiones y evaluación y seguridad de funciones con LLM).

## Propósito del Repositorio
1. **Memoria Técnica y Reinstalabilidad:** Servir como guía exacta de referencia, procedimientos y resolución de problemas para reinstalar o replicar el entorno de IA de forma reproducible.
2. **Bitácora de Decisiones y Análisis:** Registrar el *por qué* de cada decisión tecnológica (sistemas operativos headless, gestión de red declarativa, consumo de RAM/VRAM, modelos evaluados).
3. **Portfolio de Aprendizaje en IA Local Aplicada:** Explorar patrones de trabajo con agentes, continuidad de sesiones, evaluación de salidas y seguridad de funciones con LLM, además de cuantizaciones GGUF, aceleración hardware, RAG local y privacidad de datos.

## Alcance

**Incluye:** inferencia local con Ollama, clientes de desarrollo (Continue, OpenCode), flujos híbridos local/cloud, patrones de continuidad entre sesiones, evaluación de calidad y pruebas de seguridad de funciones con LLM.

**No incluye:** rankings de modelos, noticias de IA, tutoriales genéricos de prompting ni comparativas de rendimiento sin medición propia. El eje sigue siendo **local-first**: el cloud aparece como complemento justificado, no como tema principal.

## Descripción del escenario y objetivo de seguridad

**Escenario:** Servidor dedicado bare-metal (Ubuntu Server headless) ejecutando modelos de lenguaje locales con Ollama (Qwen 2.5 Coder 7B como modelo operativo; Llama 3 y Mistral evaluados inicialmente) administrado remotamente vía SSH desde equipo cliente (XPS), con soporte para integración en clientes de desarrollo (VS Code + Continue).

**Objetivo:** Documentar la configuración, resolución de bloqueos de conectividad, optimización de recursos de cómputo y comprobaciones operativas para disponer de un asistente de IA privado, auditable y escalable.

**Alcance:** Instalación del sistema base headless, pila de red Netplan/NetworkManager, OpenSSH, runtime de Ollama, evaluación de modelos interactivos y arquitectura de clientes.

> [!NOTE]
> La ejecución local garantiza soberanía de datos sobre el cómputo del modelo, pero exige verificar la exposición de puertos de red, políticas de firewall y la configuración del cliente consumidor para evitar fugas inadvertidas.

## Arquitectura y componentes utilizados

| Componente | Función | Estado documentado |
|---|---|---|
| Ubuntu Server (Headless) | Sistema operativo bare-metal optimizado (CLI puro) para maximizar VRAM y RAM dedicadas al cómputo de LLMs | Guía completa en [`docs/server-deployment-ubuntu-ollama.md`](docs/server-deployment-ubuntu-ollama.md) |
| Red (Netplan + NetworkManager) | Pila de red en dos fases: Ethernet declarativo vía Netplan y posterior gestión Wi-Fi con `nmtui` | Documentado en la guía de despliegue |
| OpenSSH | Canal de administración remota segura desde el equipo cliente (XPS) | Verificado y documentado |
| Ollama | Runtime para servir y ejecutar modelos de lenguaje en el puerto 11434 | Servicio systemd gestionado; instalación vía script oficial |
| Modelos de Inferencia | Pesos de modelos locales; `qwen2.5-coder:7b` es el modelo operativo. Llama 3 y Mistral se evaluaron inicialmente | Bucle interactivo evaluado; modelo operativo definido en `system/Modelfile.portfolio-agent` |
| GPU NVIDIA y driver | Aceleración de inferencia cuando runtime y hardware son compatibles | Comprobación orientativa documentada en `docs/gpu-setup.md` |
| VS Code + Continue | Interfaz cliente que puede conectarse al runtime local | Configuración de cliente y asistente |
| Scripts | Instalación, ejecución del laboratorio de robustez, diagnóstico y ejecución interactiva | `scripts/`; requieren revisión y permisos adecuados |
| Unidad systemd | Referencia de servicio | `system/ollama.service` no está validada como reemplazo de la unidad creada por el instalador |

Flujo de trabajo: el servidor ejecuta Ubuntu Server sin interfaz gráfica. Desde el equipo principal (XPS) se administra el servidor vía SSH. Ollama ejecuta el daemon y sirve el modelo operativo (`qwen2.5-coder:7b`) en el puerto 11434. El cliente de desarrollo (VS Code / Continue) o la consola interactiva consumen la inferencia localmente.

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
| Evidencias | Los ejemplos distinguen instrucciones de resultados realmente observados | No se incluyen registros de una ejecución reproducible en este repositorio |

## Validación o pruebas documentadas

| Comprobación | Método | Criterio | Estado en este repositorio |
|---|---|---|---|
| GPU visible para el sistema | `nvidia-smi` | El comando identifica una GPU compatible | Procedimiento documentado; no consta aquí una ejecución |
| Estado del servicio | `systemctl status ollama` y `journalctl` | Servicio activo y logs pertinentes | Procedimiento documentado; no consta aquí una ejecución |
| Uso de GPU por Ollama | Revisar logs durante una inferencia y observar carga con `nvidia-smi` | Evidencia coincidente durante la misma prueba | No verificado en este repositorio |
| Integración con Continue | Enviar una petición de prueba sin datos sensibles | El cliente responde mediante el endpoint esperado | Configuración y resultado no versionados |

Consulta la [bitácora técnica y hoja de ruta](docs/bitacora-decisiones-aprendizaje.md), la [integración de Continue con Ollama remoto y contexto 16K](docs/continue-remote-ollama-setup.md), el [despliegue de servidor Ubuntu Server](docs/server-deployment-ubuntu-ollama.md), la [configuración de GPU](docs/gpu-setup.md), la [arquitectura del laboratorio](docs/architecture.md), la [guía de diagnóstico](docs/troubleshooting.md) y el [caso de estudio de OpenCode](CASE_STUDY_OPENCODE_MIGRATION.md).

Documentos aplicados:

- [Continuidad de sesiones con OpenCode](docs/opencode-session-continuity.md): comandos, briefs y estado en archivos.
- [Evaluación y seguridad de una función con LLM](docs/ai-security-evaluation.md): conjunto dorado, inyección, métricas y CI.
- [Robustez de prompts frente a perturbaciones de entrada](docs/prompt-robustness-testing.md): cargas canario, familias de transformación, matriz de intensidad y métricas de evasión.
  - [Evidencia del instrumento](docs/evidencias/2026-10-22-robustez-prompt/README.md): 128 casos congelados, 19 transformaciones validadas; sin medición de modelo.
  - [Fase de ejecución](docs/prompt-robustness-testing.md#13-fase-de-ejecución): `scripts/run_robustness_lab.sh` instala, ejecuta y restaura el equipo.
- [Inferencia local frente a cloud](docs/local-vs-cloud.md): criterios de decisión y errores frecuentes.

## Lecciones aprendidas y límites

- «Local» describe dónde se ejecuta Ollama, no prueba que todos los componentes del flujo sean locales ni que la configuración sea privada.
- La presencia de una GPU y una respuesta del modelo no bastan para demostrar que Ollama usó CUDA; hay que observar la inferencia y sus evidencias.
- La instalación desde un script remoto implica confiar en el proveedor y en el contenido recibido en ese momento. La instalación no está fijada a una versión.
- La unidad incluida en `system/` es una referencia no verificada; no debe copiarse encima de la unidad instalada sin revisar usuario, permisos, rutas y acceso al hardware.
- Los ejemplos son material ilustrativo/documental, no mediciones de rendimiento ni registros de una sesión demostrada.

El detalle operativo está en [`docs/`](docs/); los ejemplos de interacción, en [`examples/`](examples/). Licencia: MIT.

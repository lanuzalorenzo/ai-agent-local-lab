<img src="assets/iconos/ia-local.svg" width="64" alt="Icono del laboratorio de IA local">

# Laboratorio y portfolio de aprendizaje en IA local

Laboratorio personal de **aprendizaje en IA**. Probamos herramientas y formas de trabajar con agentes, comparamos alternativas y contamos lo que pasa. El punto de partida fue la IA local, por privacidad y por límites de uso. Ahora el foco es aprender a elegir: qué herramienta, qué modelo y qué datos pueden salir de la red.

> **Estado del repositorio (2026-10-30).**
> - **Validado:** el instrumento de la prueba de robustez, y el uso de OpenCode en esta máquina.
> - **Parcial:** tres pasadas de robustez sobre `qwen2.5:3b`, y la integración de `qwen2.5-coder:7b` con Continue, probada por el autor pero sin registro reproducible.
> - **Diseño:** firewall y TLS, evaluación de funciones con LLM, RAG y equipo de agentes.
> - **Pendiente:** la fase 1 de la [hoja de ruta de seguridad](docs/referencia/hoja-de-ruta-seguridad-asistentes.md) (modelo `portfolio-agent` con digest fijado, y firewall) y los tres experimentos de seguridad de asistentes.
>
> El detalle y los límites de cada evidencia están en [`docs/evidencias/`](docs/evidencias/).

## Propósito

| Objetivo | Qué queda en el repositorio |
|---|---|
| Memoria técnica | Procedimientos y solución de problemas para reproducir el entorno |
| Bitácora de decisiones | El porqué de cada elección: servidor sin escritorio, red, consumo de memoria y modelos probados |
| Portfolio de aprendizaje | Patrones con agentes, continuidad entre sesiones y la primera medición de robustez de prompts. La seguridad de funciones con LLM y el RAG local están en la hoja de ruta |

## Alcance

**Incluye:** inferencia local con Ollama, clientes de desarrollo (Continue y OpenCode), un reparto entre modelo local y remoto, continuidad entre sesiones y un marco para evaluar salidas.

**Está en la hoja de ruta, sin evidencia todavía:** RAG local, cuantización, agentes locales y pruebas de seguridad de funciones con LLM.

**No incluye:** rankings de modelos, noticias de IA, tutoriales de prompting sin prueba propia, ni comparativas de rendimiento sin medición propia. El eje es la **inferencia local y la seguridad**: los datos sensibles se quedan en local. El trabajo diario usa un proveedor remoto, con criterios claros sobre qué datos pueden salir.

## El escenario

Un servidor sin escritorio (Ubuntu Server) ejecuta modelos con Ollama. Lo administras por SSH desde tu equipo, y tu editor (VS Code con Continue, u OpenCode) usa el modelo a través de la red.

- **Modelo operativo:** `qwen2.5-coder:7b`. También se probaron Llama 3 y Mistral al inicio, sin dejar registro.
- **Objetivo:** dejar documentado el montaje, la red y las comprobaciones, para tener un asistente de IA privado y que se pueda auditar.

> **Ojo:** que el modelo corra en local garantiza que los datos no salen al proveedor del modelo. No garantiza que no haya fugas: hay que comprobar los puertos abiertos, el firewall y la configuración del cliente.

![Arquitectura local prevista: el equipo cliente usa VS Code con Continue y OpenCode; ambos hablan con Ollama por HTTP en el puerto 11434 y administran el servidor por SSH. El puerto se prevé limitado a la red de laboratorio; la configuración de red no se ha verificado en este repositorio](docs/arquitectura-local.svg)

| Componente | Qué hace | Estado |
|---|---|---|
| Ubuntu Server | Sistema sin escritorio, para dedicar la memoria al modelo | Runbook en [`docs/guias/server-deployment-ubuntu-ollama.md`](docs/guias/server-deployment-ubuntu-ollama.md) |
| Red (Netplan y NetworkManager) | Cable con Netplan y Wi-Fi con `nmtui` | Runbook; sin ejecución registrada |
| OpenSSH | Administración remota desde tu equipo | Runbook; sin endurecimiento ni conexión real registrados |
| Ollama | Sirve los modelos en el puerto 11434 | Runbook; no verificado en este repositorio |
| Modelos | `qwen2.5-coder:7b` es el operativo | Prueba del autor con Continue, registrada como Parcial |
| GPU NVIDIA y driver | Aceleración, si el hardware y el runtime son compatibles | Runbook; sin ejecución registrada |
| VS Code con Continue | Interfaz cliente | Runbook; la configuración no está en el repositorio |
| Scripts | Instalación, prueba de robustez, diagnóstico y sesión interactiva | En `scripts/`; revísalos antes de ejecutarlos |
| Unidad de systemd | Referencia del servicio | `config/ollama.service` no está validada como sustituto de la que instala el instalador |

## Seguridad

| Control | Qué se hace | Límite |
|---|---|---|
| Exposición de Ollama | Escucha solo en la red de laboratorio, sin publicarse en Internet | Hay que poner firewall y comprobar la escucha con `ss -lntp`. No verificado aquí |
| Acceso remoto | SSH para administrar; proxy con TLS si cruza redes no confiables | No hay configuración de proxy ni endurecimiento de SSH |
| Claves de API | En variables de entorno o con `/connect` en OpenCode | No se versionan |
| Datos de contexto | Código de laboratorio y datos inventados | Nada de prompts privados ni datos de clientes |
| Modelos | Descarga desde fuentes oficiales | Hay que registrar la licencia de cada modelo |
| Logs | Se tratan como sensibles | No se publican logs con prompts |

Antes de usar el laboratorio, comprueba:

- [ ] Ollama no escucha en `0.0.0.0` sin firewall.
- [ ] El puerto `11434` no está abierto a Internet.
- [ ] La clave de API está en el entorno, no en `opencode.json`.
- [ ] El contexto enviado a un proveedor remoto no contiene secretos ni datos personales.
- [ ] El modelo local y su licencia están identificados.

## Validación

| Comprobación | Cómo | Estado |
|---|---|---|
| GPU visible para el sistema | `nvidia-smi` | Procedimiento documentado; sin ejecución registrada |
| Estado del servicio | `systemctl status ollama` y `journalctl` | Procedimiento documentado; sin ejecución registrada |
| Uso de GPU por Ollama | Logs y `nvidia-smi` durante una inferencia | No verificado |
| Integración con Continue | Una petición de prueba sin datos sensibles | Prueba del autor registrada como Parcial |

## Documentos

La documentación está en [`docs/`](docs/), y su índice en [`docs/README.md`](docs/README.md).

| Documento | Qué aporta |
|---|---|
| [Bitácora de decisiones](docs/referencia/bitacora-decisiones-aprendizaje.md) | Decisiones, problemas, causas y la hoja de ruta |
| [Hoja de ruta de seguridad de asistentes](docs/referencia/hoja-de-ruta-seguridad-asistentes.md) | Qué datos salen, qué obedece el asistente y qué puede tocar. Fases y criterios de salida |
| [Despliegue en Ubuntu Server](docs/guias/server-deployment-ubuntu-ollama.md) | Servidor sin escritorio, red, SSH y Ollama |
| [Continue con Ollama en otro equipo](docs/guias/continue-remote-ollama-setup.md) | Configuración del cliente y contexto de 16K |
| [Comprobación de la GPU](docs/guias/gpu-setup.md) | Cómo saber si el sistema ve la GPU y si Ollama la usa |
| [Diagnóstico](docs/guias/troubleshooting.md) | Comprobaciones para los problemas más frecuentes |
| [Inferencia local frente a cloud](docs/guias/local-vs-cloud.md) | Criterios para decidir dónde se ejecuta cada tarea |
| [OpenCode desde cero](docs/guias/opencode-desde-cero.md) | Qué es OpenCode, por qué empezar con un modelo local y la primera sesión |
| [AGENTS.md: qué se publica y qué no](docs/guias/agents-md-publico-privado.md) | Cómo organizar las instrucciones de un proyecto y el filtro antes de publicarlas |
| [Continuidad entre sesiones](docs/guias/opencode-session-continuity.md) | Comandos, resúmenes de sesión y estado en archivos |
| [Evaluación de una función con LLM](docs/referencia/ai-security-evaluation.md) | Conjunto de casos, inyección, métricas y CI |
| [Robustez de prompts](docs/referencia/prompt-robustness-testing.md) | Canarios, familias de disfraces, niveles y métricas |
| [Caso de estudio de OpenCode](docs/referencia/CASE_STUDY_OPENCODE_MIGRATION.md) | Los dos flujos de trabajo y por qué se eligieron |

### Evidencias

| Evidencia | Qué registra |
|---|---|
| [Instrumento de robustez](docs/evidencias/2026-10-22-robustez-instrumento/README.md) | 113 casos congelados, 15 transformaciones activas y un control negativo. Sin medición de modelo |
| [Ejecución con modelo](docs/evidencias/2026-10-22-robustez-ejecucion-v1/README.md) | `qwen2.5:3b` con los niveles N0 y N1. La orden directa funciona sin disfrazarla |
| [Línea base con el instrumento corregido](docs/evidencias/2026-10-22-robustez-ejecucion-v2/README.md) | Un caso de control y tres repeticiones válidas. La obediencia en N0 se repite en 0,50 |
| [Prompt v2](docs/evidencias/2026-10-26-robustez-prompt-v2/README.md) | 15 inferencias en N0 con el prompt endurecido: misma obediencia (0,50). La defensa no puede estar solo en el prompt |
| [Modelo 7B con Continue](docs/evidencias/2026-10-30-inferencia-7b-continue/README.md) | Integración probada por el autor, sin registro reproducible. No es un PASS |
| [Uso de OpenCode](docs/evidencias/2026-10-30-opencode-uso-real/README.md) | Uso validado en esta máquina. No valida precios ni una instalación limpia |
| [Fase de ejecución](docs/referencia/prompt-robustness-testing.md#13-fase-de-ejecución) | `scripts/robustez/run_robustness_lab.sh` instala, ejecuta y restaura el equipo |

## Lo que hemos aprendido

- «Local» describe dónde corre Ollama. No demuestra que todo el flujo sea local ni que la configuración sea privada.
- Ver una GPU y recibir una respuesta no basta para saber que Ollama usó CUDA. Hay que observar la inferencia.
- Instalar desde un script remoto implica confiar en el proveedor y en lo que se descargue en ese momento. La instalación no está fijada a una versión.
- La unidad de `config/` es una referencia sin verificar. No la copies sobre la que está instalada sin revisar usuario, permisos, rutas y acceso a la GPU.
- Los ejemplos son material ilustrativo. No son mediciones de rendimiento ni registros de una sesión comprobada.

Licencia: MIT.

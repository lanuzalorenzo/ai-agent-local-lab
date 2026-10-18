# Laboratorio y Portfolio de Aprendizaje en IA Local

Laboratorio personal y bitácora técnica de aprendizaje práctico en Inteligencia Artificial y LLMs ejecutados on-premise. El repositorio documenta paso a paso las decisiones de arquitectura de sistemas, resolución de incidentes, despliegue bare-metal (Ubuntu Server + Ollama), integración de asistentes y la hoja de ruta para futuras ampliaciones (RAG, cuantización, agentes locales y seguridad de inferencia).

## Propósito del Repositorio
1. **Memoria Técnica y Reinstalabilidad:** Servir como guía exacta de referencia, procedimientos y resolución de problemas para reinstalar o replicar el entorno de IA de forma reproducible.
2. **Bitácora de Decisiones y Análisis:** Registrar el *por qué* de cada decisión tecnológica (sistemas operativos headless, gestión de red declarativa, consumo de RAM/VRAM, modelos evaluados).
3. **Portfolio de Aprendizaje en IA:** Evolucionar como un espacio dinámico para explorar nuevos debates técnicos: cuantizaciones GGUF, aceleración hardware, RAG local seguro, agentes autónomos y privacidad de datos.

## Descripción del escenario y objetivo de seguridad

**Escenario:** Servidor dedicado bare-metal (Ubuntu Server headless) ejecutando modelos de lenguaje locales con Ollama (Llama 3, Mistral) administrado remotamente vía SSH desde equipo cliente, con soporte para integración en clientes de desarrollo (VS Code + Continue).

**Objetivo:** Documentar la configuración, resolución de bloqueos de conectividad, optimización de recursos de cómputo y comprobaciones operativas para disponer de un asistente de IA privado, auditable y escalable.

**Alcance:** Instalación del sistema base headless, pila de red Netplan/NetworkManager, OpenSSH, runtime de Ollama, evaluación de modelos interactivos y arquitectura de clientes.

> [!NOTE]
> La ejecución local garantiza soberanía de datos sobre el cómputo del modelo, pero exige verificar la exposición de puertos de red, políticas de firewall y la configuración del cliente consumidor para evitar fugas inadvertidas.

## Arquitectura y componentes utilizados

| Componente | Función | Estado documentado |
|---|---|---|
| Ubuntu Server (Headless) | Sistema operativo bare-metal optimizado (CLI puro) para maximizar VRAM y RAM dedicadas al cómputo de LLMs | Guía completa en [`docs/server-deployment-ubuntu-ollama.md`](docs/server-deployment-ubuntu-ollama.md) |
| Red (Netplan + NetworkManager) | Pila de red en dos fases: Ethernet declarativo vía Netplan y posterior gestión Wi-Fi con `nmtui` | Documentado en la guía de despliegue |
| OpenSSH | Canal de administración remota segura desde el equipo cliente | Verificado y documentado |
| Ollama | Runtime para servir y ejecutar modelos de lenguaje en el puerto 11434 | Servicio systemd gestionado; instalación vía script oficial |
| Modelos de Inferencia | Pesos de modelos locales (Llama 3, Mistral) para ejecución offline y privada | Bucle interactivo evaluado |
| GPU NVIDIA y driver | Aceleración de inferencia cuando runtime y hardware son compatibles | Comprobación orientativa documentada en `docs/gpu-setup.md` |
| VS Code + Continue | Interfaz cliente que puede conectarse al runtime local | Configuración de cliente y asistente |
| Scripts | Instalación, diagnóstico y ejecución interactiva | `scripts/`; requieren revisión y permisos adecuados |
| Unidad systemd | Referencia de servicio | `system/ollama.service` no está validada como reemplazo de la unidad creada por el instalador |

Flujo de trabajo: el servidor ejecuta Ubuntu Server sin interfaz gráfica. Desde el equipo principal se administra el servidor vía SSH. Ollama ejecuta el daemon y sirve los modelos (Llama 3, Mistral) en el puerto 11434. El cliente de desarrollo (VS Code / Continue) o la consola interactiva consumen la inferencia localmente.

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

Consulta la [bitácora técnica y hoja de ruta](docs/bitacora-decisiones-aprendizaje.md), el [despliegue de servidor Ubuntu Server](docs/server-deployment-ubuntu-ollama.md), la [configuración de GPU](docs/gpu-setup.md), la [arquitectura del laboratorio](docs/architecture.md) y la [guía de diagnóstico](docs/troubleshooting.md).

## Lecciones aprendidas y límites

- «Local» describe dónde se ejecuta Ollama, no prueba que todos los componentes del flujo sean locales ni que la configuración sea privada.
- La presencia de una GPU y una respuesta del modelo no bastan para demostrar que Ollama usó CUDA; hay que observar la inferencia y sus evidencias.
- La instalación desde un script remoto implica confiar en el proveedor y en el contenido recibido en ese momento. La instalación no está fijada a una versión.
- La unidad incluida en `system/` es una referencia no verificada; no debe copiarse encima de la unidad instalada sin revisar usuario, permisos, rutas y acceso al hardware.
- Los ejemplos son material ilustrativo/documental, no mediciones de rendimiento ni registros de una sesión demostrada.

El detalle operativo está en [`docs/`](docs/); los ejemplos de interacción, en [`examples/`](examples/). Licencia: MIT.

# Laboratorio de agente de IA local

Laboratorio personal para explorar un flujo de asistencia al desarrollo con Ollama, VS Code y Continue. El repositorio reúne documentación, scripts de apoyo y ejemplos; no es una distribución lista para producción ni acredita por sí solo que cada procedimiento se haya ejecutado.

## Descripción del escenario y objetivo de seguridad

**Escenario:** ejecutar un modelo de lenguaje en un equipo Ubuntu con GPU NVIDIA e integrarlo en el entorno de desarrollo mediante VS Code y Continue.

**Objetivo:** documentar la configuración y las comprobaciones necesarias para evaluar un asistente local, haciendo visibles sus dependencias, límites y riesgos operativos.

**Alcance:** instalación y diagnóstico local de Ollama, aceleración NVIDIA cuando esté disponible e integración de cliente. No cubre entrenamiento, ajuste fino, despliegue remoto ni controles de producción.

> [!NOTE]
> La ejecución local no garantiza por sí sola la confidencialidad. Comprueba la configuración del cliente, el endpoint utilizado y el tráfico de red antes de introducir código o datos sensibles. No guardes secretos ni información de terceros en ejemplos, prompts o registros.

## Arquitectura y componentes utilizados

| Componente | Función | Estado documentado |
|---|---|---|
| Ubuntu Server (Headless) | Sistema operativo bare-metal optimizado (CLI puro) para maximizar VRAM y RAM dedicadas al cómputo de LLMs | Guía completa en [`docs/server-deployment-ubuntu-ollama.md`](docs/server-deployment-ubuntu-ollama.md) |
| Red (Netplan + NetworkManager) | Pila de red en dos fases: Ethernet declarativo vía Netplan y posterior gestión Wi-Fi con `nmtui` | Documentado en la guía de despliegue |
| OpenSSH | Canal de administración remota segura desde el equipo cliente (XPS) | Verificado y documentado |
| Ollama | Runtime para servir y ejecutar modelos de lenguaje en el puerto 11434 | Servicio systemd gestionado; instalación vía script oficial |
| Modelos de Inferencia | Pesos de modelos locales (Llama 3, Mistral) para ejecución offline y privada | Bucle interactivo evaluado |
| GPU NVIDIA y driver | Aceleración de inferencia cuando runtime y hardware son compatibles | Comprobación orientativa documentada en `docs/gpu-setup.md` |
| VS Code + Continue | Interfaz cliente que puede conectarse al runtime local | Configuración de cliente y asistente |
| Scripts | Instalación, diagnóstico y ejecución interactiva | `scripts/`; requieren revisión y permisos adecuados |
| Unidad systemd | Referencia de servicio | `system/ollama.service` no está validada como reemplazo de la unidad creada por el instalador |

Flujo de trabajo: el servidor ejecuta Ubuntu Server sin interfaz gráfica. Desde el equipo principal (XPS) se administra el servidor vía SSH. Ollama ejecuta el daemon y sirve los modelos (Llama 3, Mistral) en el puerto 11434. El cliente de desarrollo (VS Code / Continue) o la consola interactiva consumen la inferencia localmente.

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

Los procedimientos están descritos, pero no se presentan como pruebas superadas. Consulta [despliegue de servidor Ubuntu Server](docs/server-deployment-ubuntu-ollama.md), [configuración de GPU](docs/gpu-setup.md), [arquitectura](docs/architecture.md) y [diagnóstico](docs/troubleshooting.md).

## Lecciones aprendidas y límites

- «Local» describe dónde se ejecuta Ollama, no prueba que todos los componentes del flujo sean locales ni que la configuración sea privada.
- La presencia de una GPU y una respuesta del modelo no bastan para demostrar que Ollama usó CUDA; hay que observar la inferencia y sus evidencias.
- La instalación desde un script remoto implica confiar en el proveedor y en el contenido recibido en ese momento. La instalación no está fijada a una versión.
- La unidad incluida en `system/` es una referencia no verificada; no debe copiarse encima de la unidad instalada sin revisar usuario, permisos, rutas y acceso al hardware.
- Los ejemplos son material ilustrativo/documental, no mediciones de rendimiento ni registros de una sesión demostrada.

El detalle operativo está en [`docs/`](docs/); los ejemplos de interacción, en [`examples/`](examples/). Licencia: MIT.

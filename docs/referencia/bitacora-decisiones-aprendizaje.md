# Bitácora de Aprendizaje, Decisiones Técnicas y Evolución de IA Local

Este documento registra cronológicamente las fases de investigación, decisiones arquitectónicas, problemas encontrados, análisis causa-raíz y soluciones implementadas en el laboratorio. Su propósito es servir como memoria técnica verificable, guía de reinstalación o recuperación ante desastres y base de conocimiento para debatir y expandir capacidades futuras.

---

## Índice de Entradas
1. [Entrada 01: Aprovisionamiento Bare-Metal y Headless con Ubuntu Server](#entrada-01-aprovisionamiento-bare-metal-y-headless-con-ubuntu-server)
2. [Entrada 02: Incidente de Conectividad en Instalación Mínima y Resolución Netplan](#entrada-02-incidente-de-conectividad-en-instalación-mínima-y-resolución-netplan)
3. [Entrada 03: Despliegue de Ollama, Inferencia CLI y Gestión Remota SSH](#entrada-03-despliegue-de-ollama-inferencia-cli-y-gestión-remota-ssh)
4. [Entrada 04: Hoja de Ruta y Ejes de Aprendizaje Futuros](#entrada-04-hoja-de-ruta-y-ejes-de-aprendizaje-futuros)
5. [Entrada 05: Optimización y Ajuste de Arquitectura de Contexto (`portfolio-agent` + Continue)](#entrada-05-optimización-y-ajuste-de-arquitectura-de-contexto-portfolio-agent--continue)
6. [Entrada 06: Elección de Almacén Vectorial para el RAG Local](#entrada-06-elección-de-almacén-vectorial-para-el-rag-local)
7. [Entrada 07: Cifras de VRAM de terceros: la aritmética primero](#entrada-07-cifras-de-vram-de-terceros-la-aritmética-primero)

---

## Entrada 01: Aprovisionamiento Bare-Metal y Headless con Ubuntu Server

- **Fecha:** Octubre 2026
- **Contexto:** Se requiere un entorno local dedicado a inferencia de LLMs (Ollama) sin depender de APIs cloud de terceros ni exponer datos sensibles o código fuente.
- **Decisión de Arquitectura:** 
  - Desplegar **Ubuntu Server (Headless / CLI pura)** en máquina bare-metal física en lugar de una distribución de escritorio (Desktop con GNOME/KDE) o máquina virtual con virtualización de GPU compleja.
- **Justificación Técnica:**
  - **Eficiencia de memoria (RAM / VRAM):** Un entorno de escritorio tradicional reserva entre 1.5 GB y 3.5 GB de RAM para el gestor de ventanas (Wayland/X11), renderizado gráfico y servicios auxiliares. En un servidor headless, esos recursos quedan disponibles para alojar los tensores y matrices del modelo de lenguaje en memoria.
  - **Superficie de ataque reducida:** Al prescindir de paquetes de escritorio y navegadores en el servidor, se reduce la superficie de exposición y la complejidad de parches del sistema operativo.
  - **Gobernanza por `systemd`:** Ollama corre como daemon desatendido en background, facilitando reinicios automáticos y telemetría de logs con `journalctl`.

---

## Entrada 02: Incidente de Conectividad en Instalación Mínima y Resolución Netplan

- **Problema:** Tras la instalación mínima de Ubuntu Server, el equipo no tenía conectividad a la red local ni a internet. No estaban disponibles `nmtui`, `NetworkManager` ni asistentes Wi-Fi interactivos.
- **Causa raíz:** El instalador minimalista configura solo la pila básica con `systemd-networkd` sin paquetes de conectividad de usuario. Sin conexión, no era posible ejecutar `apt install network-manager`.
- **Estrategia en dos fases:**
  1. **Fase 1 (Ethernet + Netplan):** Conexión por cable al router/switch. Edición declarativa en `/etc/netplan/01-netcfg.yaml`:
     ```yaml
     network:
       version: 2
       renderer: networkd
       ethernets:
         enp3s0:
           dhcp4: true
     ```
     Aplicación con `sudo netplan apply`. Validación con `ip a` y resolución DNS.
  2. **Fase 2 (Wi-Fi persistente):** Con APT accesible, instalación de `network-manager`:
     ```bash
     sudo apt update && sudo apt install network-manager -y
     ```
     Configuración inalámbrica con `sudo nmtui`, permitiendo ubicar el servidor en cualquier punto de la red local.

---

## Entrada 03: Despliegue de Ollama, Inferencia CLI y Gestión Remota SSH

- **Configuración de OpenSSH:**
  - El servidor se gestiona remotamente desde el equipo de desarrollo principal mediante clave o sesión SSH:
    ```bash
    ssh usuario@IP_DEL_SERVIDOR
    ```
- **Instalación del Runtime Ollama:**
  - Ejecución del script oficial de despliegue:
    ```bash
    curl -fsSL https://ollama.com/install.sh | sh
    ```
  - Verificación del socket de escucha en `127.0.0.1:11434` o interfaz asignada.
- **Modelos Evaluados e Inferencia Inicial:**
  - Descarga y ejecución interactiva de `llama3`:
    ```bash
    ollama run llama3
    ```
  - Evaluación cualitativa de tiempos de respuesta, latencia del primer token (TTFT) y consumo en CPU/GPU.
  - Extensión a modelos de razonamiento y codificación como `mistral` / `codellama`.
  - **Modelo operativo actual:** `qwen2.5-coder:7b`, elegido por su rendimiento en código y su integración con el `Modelfile` del laboratorio.

---

## Entrada 05: Optimización y Ajuste de Arquitectura de Contexto (`portfolio-agent` + Continue)

- **Fecha:** Octubre 2026
- **Contexto:** Al integrar Continue en VS Code desde el equipo cliente contra el servidor bare-metal dedicado (`http://ollama.lab.local:11434`), se evaluó el uso de modelos especializados y la inyección de prompts maestros extensos.

### 1. Diagnóstico del Problema Inicial
- **Cuello de botella en procesamiento de prompt:** Un prompt de sistema de ~1.500 tokens fijado en el `Modelfile` obligaba al modelo a recomputar toda la secuencia en cada llamada, aumentando la latencia del primer token (TTFT) y haciendo la interacción lentísima.
- **Límite de ventana de contexto en cliente y servidor:** Al adjuntar archivos extensos (ej. un prompt privado de ~18.8 KB) mediante `@file` desde Continue, el sistema arrojaba `File exceeds model's context length`. El límite por defecto era **2.048 tokens** en el runtime de Ollama y en la configuración local de Continue.

### 2. Acciones y Soluciones Aplicadas

#### A. Reestructuración del `Modelfile` en el Servidor Remoto
- **Prompt de Sistema Ligero:** Se sustituyó el prompt masivo por un bloque `SYSTEM` conciso que define únicamente el rol principal (*Lead Cloud Security Architect, DevSecOps & .NET Architect*), la orientación hacia *Security by Design*, el principio de *Rumbo Fijo* y el activo de referencia `lab-api-local-azure`.
- **Ampliación de Ventana de Contexto (`num_ctx`):** Se añadió la directiva `PARAMETER num_ctx 16384` en [`system/Modelfile.portfolio-agent`](../../config/Modelfile.portfolio-agent) para permitir la inyección de documentos extensos bajo demanda sin saturar la memoria inicial:

```dockerfile
FROM qwen2.5-coder:7b

SYSTEM """
Actúa como Lead Cloud Security Architect, Especialista Senior en DevSecOps y Arquitecto de Software .NET. 
Tu objetivo es ayudar en el desarrollo del portfolio técnico y de ciberseguridad, priorizando siempre la seguridad por diseño (Security by Design), el principio de Rumbo Fijo y el activo de referencia lab-api-local-azure. 
Consulta siempre los archivos locales y el AGENTS.md del repositorio para mantener la coherencia.
"""

PARAMETER num_ctx 16384
PARAMETER stop <|im_end|>
PARAMETER stop <|endoftext|>
PARAMETER temperature 0.2
PARAMETER top_p 0.9
```

#### B. Sincronización de Configuración en Cliente (`config.yaml` de Continue)
- Se configuró explícitamente el parámetro `contextLength: 16384` en la definición del modelo en Continue para sincronizar el límite del cliente con el servidor remoto y evitar bloqueos preventivos al cargar ficheros:

```yaml
models:
  - name: Portfolio Agent
    provider: ollama
    model: portfolio-agent
    apiBase: http://ollama.lab.local:11434
    contextLength: 16384
```

### 3. Resultados y Patrón de Trabajo Establecido
1. **Inferencia rápida:** El agente responde sin reprocesar un prompt de sistema largo en cada llamada.
2. **Carga contextual bajo demanda:** Buena práctica de referenciar dinámicamente los archivos del workspace (`@AGENTS.md`, `@file`, `@folder` o `@workspace`) según la tarea.
3. **Soporte de ficheros grandes:** Capacidad de adjuntar archivos de contexto de hasta 16K tokens sin errores de desbordamiento de ventana.

---

## Entrada 04: Hoja de Ruta y Ejes de Aprendizaje Futuros

Este laboratorio evoluciona como portfolio de aprendizaje de Inteligencia Artificial aplicada:

### Eje 1: Aceleración Hardware y Compilaciones Cuantizadas
- [ ] Validación de drivers CUDA y NVIDIA Container Toolkit si se incorpora GPU dedicada.
- [ ] Medición de impacto de cuantizaciones GGUF (Q4_K_M vs Q5_K_M vs Q8_0) en ratio precisión vs consumo de VRAM.

### Eje 2: Arquitectura de Red y Exposición Segura
- [ ] Configuración de escucha de Ollama (`OLLAMA_HOST=0.0.0.0:11434`) con restricción estricta por firewall (`ufw`) o túnel SSH / VPN WireGuard para que solo el equipo cliente autorizado pueda invocar la API.
- [ ] Implementación de proxy inverso TLS con NGINX o Caddy con autenticación por token/mTLS.

### Eje 3: Integración de Clientes y Asistentes de Desarrollo
- [x] Configuración del cliente Continue en VS Code apuntando al servidor Ollama dedicado (contexto 16K sincronizado).
- [ ] Evaluación de contexto de código completo (*codebase embeddings*) y autocompletado en tiempo real.

### Eje 4: RAG Local (Retrieval-Augmented Generation) y Agentes Autónomos
- [ ] Construcción de un pipeline RAG local con base de datos vectorial embebida (ChromaDB / Qdrant) para consultar documentación técnica y apuntes privados de ciberseguridad sin fuga de datos. Criterio de motor en la [Entrada 06](#entrada-06-elección-de-almacén-vectorial-para-el-rag-local).
- [ ] Experimentación con frameworks de agentes locales (LangChain, LlamaIndex o AutoGen) conectados al modelo servido en Ollama.

### Eje 5: Evaluación y Robustez de LLM
- [ ] Construir el conjunto dorado mínimo (20–50 casos) descrito en [`ai-security-evaluation.md`](ai-security-evaluation.md) y automatizarlo en CI.
- [x] Implementar la matriz de perturbación de [`prompt-robustness-testing.md`](prompt-robustness-testing.md): canarios C0–C4, familias F1–F4 y niveles N0–N3.
- [x] Ejecutar la matriz en el equipo Ubuntu con [`run_robustness_lab.sh`](../../scripts/robustez/run_robustness_lab.sh) y registrar la huella del entorno junto a los resultados.
- [x] Primera ejecución (2026-10-22, `qwen2.5:3b`, N0 y N1): obediencia en el control del 50 %, inyección directa funcional sin transformación.
- [x] Añadir el control negativo C0 y excluir las cuatro transformaciones que el modelo no decodifica: medían ilegibilidad, no resistencia.
- [x] Segunda pasada, solo N0 (2026-10-22, prompt `v1`): control negativo 3/3 con JSON válido; obediencia 0,50, idéntica a la primera.
- [x] Versionar el prompt de sistema y registrar su huella en cada ejecución.
- [ ] Completar la corrección del instrumento: comprobación de decodificación (reactiva F3) y detector de C3 separado del formato.
- [ ] Endurecer el prompt de sistema hasta que N0 dé cero y repetir N1; solo entonces la cifra de robustez significa algo.
- [ ] Separar en cada ejecución el fallo del filtro (evasión) del fallo del modelo (obediencia); sin ese desglose no se sabe qué corregir.
- [ ] Usar la misma matriz para comparar modelos locales con una **puntuación por tarea**, no un ranking general: el resultado solo es válido para el prompt y la tarea evaluados.
- [ ] Medir el factor de expansión de tokens de cada transformación: una mitigación que multiplica el coste por diez es un problema de consumo, no solo de filtrado.

---

## Entrada 06: Elección de Almacén Vectorial para el RAG Local

- **Fecha:** Octubre 2026
- **Estado:** Diseño. No se ha medido nada y la decisión no está tomada.
- **Contexto:** El eje 4 de la hoja de ruta fija un pipeline RAG sobre documentación técnica y apuntes privados. La primera decisión no es qué modelo genera la respuesta, sino dónde viven los vectores. Hay dos familias: base embebida (ChromaDB, Qdrant en local) o PostgreSQL con la extensión `pgvector`.
- **Decisión de Arquitectura:** ninguna todavía. Se deja escrito el criterio para no elegir por costumbre ni por lo que se lea en una comparativa ajena.

**Criterios que separan las dos opciones:**

| Criterio | Base embebida | PostgreSQL + `pgvector` |
|---|---|---|
| Superficie operativa | Una librería; sin servicio ni puerto | Servicio propio, con backups, parches y autenticación |
| Consulta híbrida (texto + vector) | Limitada o a mano | SQL completo y búsqueda léxica en la misma consulta |
| Consistencia con metadatos | Copia aparte que puede desincronizarse | Transacciones con el resto de los datos |
| Corpus pequeño (< 50 000 fragmentos) | Suficiente | Sobredimensionado |
| Varios consumidores a la vez | Punto débil | Resuelto de origen |
| Huella en el servidor headless | Menor; se carga al consultar | Un proceso más, siempre en memoria |
| Cliente .NET | Menos opciones maduras | Proveedor de EF Core con tipos vectoriales |

**Criterio de decisión propuesto:** si el corpus es pequeño y el único consumidor es el agente del laboratorio, base embebida. Menos superficie, copia de seguridad de un directorio y ningún puerto que cerrar. Si aparece metadata relacional que consultar junto al vector, búsqueda híbrida o un segundo cliente, PostgreSQL. Migrar después de tener los índices construidos es reindexar, no mover un archivo.

**Riesgo de método:** el motor influye menos que el modelo de embeddings y el troceado de los documentos. Sin conjunto dorado no se puede afirmar que una opción recupera mejor; se compara con el mismo instrumento del eje 5, sobre las mismas preguntas y el mismo corpus.

**Nota:** `pgvector` no es un complemento de un motor que ya exista en el laboratorio; exige desplegar PostgreSQL, que hoy no está instalado.

**Pendiente:**
- Fijar tamaño de corpus y número de consumidores antes de la primera prueba.
- Elegir el modelo de embeddings y documentar su dimensión y su coste en tokens.
- Medir recuperación (recall sobre las preguntas del conjunto dorado) antes de comparar motores.

---

## Entrada 07: Cifras de VRAM de terceros: la aritmética primero

- **Fecha:** Octubre 2026
- **Estado:** Observación sin medir. El cálculo justifica el escepticismo; la comprobación en hardware sigue pendiente.
- **Contexto:** Es habitual encontrar la afirmación de que un modelo de unos 27 000 millones de parámetros "con cuantización ligera" cabe en menos de 10 GB de VRAM y corre entero en la gráfica. Antes de repetirla o de planificar compras con ella, conviene hacer la cuenta.

**El cálculo que no se puede esquivar:** el peso de los parámetros en memoria es proporcional a los bits por peso.

| Cuantización (bits por peso aprox.) | Peso de 27 B | ¿Cabe en 10 GB? |
|---|---:|---|
| FP16 (16) | ~54 GB | No |
| Q8 (8,5) | ~28 GB | No |
| Q5_K_M (5,7) | ~19 GB | No |
| Q4_K_M (4,8) | ~16 GB | No |
| Q3_K_M (3,9) | ~13 GB | No |
| Q2_K (3,1) | ~10,5 GB | Al límite, y sin caché |

Y a eso se suma la caché del contexto (KV cache), que con ventanas largas puede ocupar varios GB más. Conclusión: un 27 B en menos de 10 GB exige bajar de 3 bits por peso, que no es "cuantización ligera", o bien apoyarse en RAM del sistema con *offload* parcial, que es otra cosa.

**Excepción legítima que no se debe confundir:** los modelos de mezcla de expertos (MoE) activan pocos parámetros por token, pero necesitan todos los pesos residentes para no degradarse. Si parte de los expertos vive en RAM, el modelo "funciona", pero no "corre entero en la gráfica" ni a la velocidad que sugiere el anuncio.

**Regla reutilizable:** antes de aceptar una cifra de VRAM, dividir parámetros entre bits por peso y sumar contexto. Si el resultado no cuadra con lo anunciado, el número es del anuncio, no del modelo.

**Lo que sí es cierto y sostiene el caso local:** un modelo servido en local no está sujeto a las políticas de rechazo del proveedor, y eso importa en auditoría de laboratorios propios. Pero no rechazar no es lo mismo que acertar: la validez del análisis se demuestra ejecutando las pruebas, no leyendo la respuesta.

**Pendiente:**
- Verificar el tamaño real de cada archivo GGUF descargado frente al cálculo (el tamaño en disco es la comprobación más rápida).
- Medir VRAM real con `nvidia-smi` durante la inferencia, no al cargar el modelo.



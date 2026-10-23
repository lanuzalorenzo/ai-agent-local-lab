# Bitácora de Aprendizaje, Decisiones Técnicas y Evolución de IA Local

Este documento registra cronológicamente las fases de investigación, decisiones arquitectónicas, problemas encontrados, análisis causa-raíz y soluciones implementadas en el laboratorio. Su propósito es servir como memoria técnica verificable, guía de reinstalación o recuperación ante desastres y base de conocimiento para debatir y expandir capacidades futuras.

---

## Índice de Entradas
1. [Entrada 01: Aprovisionamiento Bare-Metal y Headless con Ubuntu Server](#entrada-01-aprovisionamiento-bare-metal-y-headless-con-ubuntu-server)
2. [Entrada 02: Incidente de Conectividad en Instalación Mínima y Resolución Netplan](#entrada-02-incidente-de-conectividad-en-instalación-mínima-y-resolución-netplan)
3. [Entrada 03: Despliegue de Ollama, Inferencia CLI y Gestión Remota SSH](#entrada-03-despliegue-de-ollama-inferencia-cli-y-gestión-remota-ssh)
4. [Entrada 04: Hoja de Ruta y Ejes de Aprendizaje Futuros](#entrada-04-hoja-de-ruta-y-ejes-de-aprendizaje-futuros)
5. [Entrada 05: Optimización y Ajuste de Arquitectura de Contexto (`portfolio-agent` + Continue)](#entrada-05-optimización-y-ajuste-de-arquitectura-de-contexto-portfolio-agent--continue)

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
- [ ] Construcción de un pipeline RAG local con base de datos vectorial embebida (ChromaDB / Qdrant) para consultar documentación técnica y apuntes privados de ciberseguridad sin fuga de datos.
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


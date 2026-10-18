# Bitácora de Aprendizaje, Decisiones Técnicas y Evolución de IA Local

Este documento registra cronológicamente las fases de investigación, decisiones arquitectónicas, problemas encontrados, análisis causa-raíz y soluciones implementadas en el laboratorio. Su propósito es servir como memoria técnica verificable, guía de reinstalación/recuperación ante desastres (DR) y base de conocimiento para debatir y expandir capacidades futuras.

---

## Índice de Entradas
1. [Entrada 01: Aprovisionamiento Bare-Metal y Headless con Ubuntu Server](#entrada-01-aprovisionamiento-bare-metal-y-headless-con-ubuntu-server)
2. [Entrada 02: Incidente de Conectividad en Instalación Mínima y Resolución Netplan](#entrada-02-incidente-de-conectividad-en-instalación-mínima-y-resolución-netplan)
3. [Entrada 03: Despliegue de Ollama, Inferencia CLI y Gestión Remota SSH](#entrada-03-despliegue-de-ollama-inferencia-cli-y-gestión-remota-ssh)
4. [Entrada 04: Hoja de Ruta y Ejes de Aprendizaje Futuros](#entrada-04-hoja-de-ruta-y-ejes-de-aprendizaje-futuros)

---

## Entrada 01: Aprovisionamiento Bare-Metal y Headless con Ubuntu Server

- **Fecha:** Octubre 2026
- **Contexto:** Se requiere un entorno local dedicado a inferencia de LLMs (Ollama) sin depender de APIs cloud de terceros ni exponer datos sensibles o código fuente.
- **Decisión de Arquitectura:** 
  - Desplegar **Ubuntu Server (Headless / CLI pura)** en máquina bare-metal física en lugar de una distribución de escritorio (Desktop con GNOME/KDE) o máquina virtual con virtualización de GPU compleja.
- **Justificación Técnica:**
  - **Eficiencia de memoria (RAM / VRAM):** Un entorno de escritorio tradicional reserva entre 1.5 GB y 3.5 GB de RAM para el gestor de ventanas (Wayland/X11), renderizado gráfico y servicios auxiliares. En un servidor headless, esos recursos quedan libres al 100% para alojar los tensores y matrices del modelo de lenguaje en memoria.
  - **Superficie de ataque mínima:** Al prescindir de paquetes de escritorio y navegadores en el servidor, se reduce la superficie de exposición y la complejidad de parches del sistema operativo.
  - **Gobernanza por `systemd`:** Ollama corre como daemon desatendido en background, facilitando reinicios automáticos y telemetría de logs con `journalctl`.

---

## Entrada 02: Incidente de Conectividad en Instalación Mínima y Resolución Netplan

- **Problema Detectado:**
  - Tras completar la instalación mínima limpia de Ubuntu Server, el equipo carecía de conectividad a la red local y a internet. No se disponía de herramientas de usuario habituales como `nmtui`, `NetworkManager` o comandos de asistencia Wi-Fi interactiva.
- **Análisis de Causa-Raíz:**
  - El instalador minimalista de Ubuntu Server configura únicamente la pila básica con `systemd-networkd` sin paquetes de conectividad de usuario. Sin conexión previa, no era posible ejecutar `apt install network-manager`.
- **Estrategia en Dos Fases Implementada:**
  1. **Fase 1 (Enlace Físico Ethernet + Netplan):**
     - Conexión por cable al router/switch.
     - Edición declarativa de la configuración en `/etc/netplan/01-netcfg.yaml`:
       ```yaml
       network:
         version: 2
         renderer: networkd
         ethernets:
           enp3s0:
             dhcp4: true
       ```
     - Aplicación con `sudo netplan apply`. Se validó la asignación de IP con `ip a` y conectividad con resolución DNS.
  2. **Fase 2 (Gestión Wi-Fi Persistente):**
     - Con el repositorio APT accesible, se instaló `network-manager`:
       ```bash
       sudo apt update && sudo apt install network-manager -y
       ```
     - Configuración inalámbrica mediante consola interactiva con `sudo nmtui`, permitiendo ubicar el servidor físicamente en cualquier punto de la red local.

---

## Entrada 03: Despliegue de Ollama, Inferencia CLI y Gestión Remota SSH

- **Configuración de OpenSSH:**
  - El servidor se gestiona remotamente desde el equipo de desarrollo principal (XPS) mediante clave o sesión SSH:
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
  - Evaluación cualitativa de tiempos de respuesta, latencia del primer token (TTFT - Time To First Token) y consumo en CPU/GPU.
  - Extensión a modelos de razonamiento y codificación como `mistral` / `codellama`.

---

## Entrada 04: Hoja de Ruta y Ejes de Aprendizaje Futuros

Este laboratorio está concebido para evolucionar como un portfolio de aprendizaje práctico de Inteligencia Artificial aplicada:

### Eje 1: Aceleración Hardware y Compilaciones Cuantizadas
- [ ] Validación de drivers CUDA y NVIDIA Container Toolkit si se incorpora GPU dedicada.
- [ ] Medición de impacto de cuantizaciones GGUF (Q4_K_M vs Q5_K_M vs Q8_0) en ratio precisión vs consumo de VRAM.

### Eje 2: Arquitectura de Red y Exposición Segura
- [ ] Configuración de escucha de Ollama (`OLLAMA_HOST=0.0.0.0:11434`) con restricción estricta por firewall (`ufw`) o túnel SSH / VPN WireGuard para que solo el cliente XPS pueda invocar la API.
- [ ] Implementación de proxy inverso TLS con NGINX o Caddy con autenticación por token/mTLS.

### Eje 3: Integración de Clientes y Asistentes de Desarrollo
- [ ] Configuración del cliente Continue en VS Code apuntando al servidor Ollama dedicado.
- [ ] Evaluación de contexto de código completo (*codebase embeddings*) y autocompletado en tiempo real.

### Eje 4: RAG Local (Retrieval-Augmented Generation) y Agentes Autónomos
- [ ] Construcción de un pipeline RAG local con base de datos vectorial embebida (ChromaDB / Qdrant) para consultar documentación técnica y apuntes privados de ciberseguridad sin fuga de datos.
- [ ] Experimentación con frameworks de agentes locales (LangChain, LlamaIndex o AutoGen) conectados al modelo servido en Ollama.

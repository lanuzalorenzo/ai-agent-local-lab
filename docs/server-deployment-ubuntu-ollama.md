# Despliegue de Servidor de IA Local con Ubuntu Server y Ollama

> **En fácil:** montas un ordenador solo para que corra la IA en tu casa. Sin pantalla, sin ratón, solo red. Lo controlas desde tu portátil por SSH y los datos nunca salen de tu red.

Guía técnica de arquitectura, instalación y resolución de conectividad para el despliegue de un servidor bare-metal dedicado (Ubuntu Server) orientado a la inferencia de Modelos de Lenguaje de Gran Tamaño (LLMs) con Ollama, administrado remotamente vía SSH desde un equipo cliente.

---

## 1. Descripción del Escenario y Justificación Técnica

### Selección de Ubuntu Server (Headless)
- **Recursos para el modelo:** Instalación CLI pura (sin entorno de escritorio ni gestor de ventanas tipo GNOME o Wayland) para dedicar la RAM y VRAM al cómputo y carga de tensores de los modelos de lenguaje.
- **Estabilidad y superficie de ataque reducida:** Infraestructura minimalista gobernada por `systemd`, eliminando procesos innecesarios y reduciendo la exposición de servicios auxiliares.
- **Topología de trabajo:**
  - **Servidor bare-metal:** Ubuntu Server ejecutando el daemon de `ollama` en el puerto 11434.
  - **Cliente de administración:** Equipo principal conectado mediante SSH seguro (OpenSSH) y clientes de inferencia local.

```mermaid
flowchart LR
    subgraph Client["Cliente Principal"]
        SSH[OpenSSH Client]
        VSCode[VS Code / Continue]
    end

    subgraph Server["Servidor Headless (Ubuntu Server)"]
        Net[Netplan / systemd-networkd / NetworkManager]
        SSHD[OpenSSH Server :22]
        Ollama[Ollama Runtime :11434]
        LLM[(Modelo operativo: Qwen 2.5 Coder 7B)]
    end

    SSH -->|Gestión remota SSH| SSHD
    VSCode -.->|API REST :11434| Ollama
    Ollama --> LLM
```

---

## 2. Diagnóstico y Resolución de Conectividad en Servidor Mínimo

En una instalación limpia de Ubuntu Server (versión headless mínima) no vienen preinstaladas utilidades interactivas de gestión Wi-Fi como `nmtui`, `NetworkManager` ni `dhclient`. Para resolver el arranque inicial de red se aplicó una estrategia en dos fases:

### Fase 1: Conectividad Declarativa Ethernet con Netplan
Se conecta el servidor por cable y se define la configuración declarativa mediante Netplan y `systemd-networkd` para obtener salida a repositorios:

1. Edición de `/etc/netplan/01-netcfg.yaml` (o archivo correspondiente según el instalador):
   ```yaml
   network:
     version: 2
     renderer: networkd
     ethernets:
       enp3s0:
         dhcp4: true
   ```
2. Aplicación de la configuración:
   ```bash
   sudo netplan apply
   ```

### Fase 2: Aprovisionamiento de Gestión Inalámbrica
Una vez garantizado el acceso a internet por Ethernet, se instalan las herramientas para dar flexibilidad física al servidor sin perder la administración remota:

```bash
sudo apt update && sudo apt install network-manager -y
sudo nmtui
```
Con `nmtui` se conecta la interfaz inalámbrica a la red local y se guarda el perfil de red.

---

## 3. Acceso Remoto Seguro (OpenSSH)

1. **Verificación del servicio SSH:**
   ```bash
   sudo systemctl status ssh
   ```
2. **Obtención de la IP asignada en la red local:**
   ```bash
   ip a
   ```
3. **Conexión remota desde el equipo cliente:**
   ```bash
   ssh usuario@IP_DEL_SERVIDOR
   ```

---

## 4. Instalación y Despliegue del Motor Ollama

1. **Instalación del Runtime oficial:**
   ```bash
   curl -fsSL https://ollama.com/install.sh | sh
   ```
2. **Verificación del estado del daemon:**
   ```bash
   sudo systemctl status ollama
   ```
   *El servicio queda registrado como servicio de sistema en systemd, escuchando por defecto en el puerto local 11434.*

---

## 5. Descarga e Inferencia de Modelos de IA

1. **Descarga de pesos y ejecución interactiva:**
   ```bash
   ollama run qwen2.5-coder:7b
   ```
2. **Validación de inferencia y consumo de recursos:**
   - Comprobación de tiempos de respuesta por token (tokens/segundo).
   - Verificación de uso de memoria y procesador mediante herramientas de monitorización (`top`, `htop`, o `nvidia-smi` si dispone de GPU dedicada).
   - Evaluación adicional con modelos complementarios (por ejemplo, `llama3` o `mistral`), conservando `qwen2.5-coder:7b` como modelo operativo del laboratorio.

---

## 6. Stack Tecnológico

| Capa | Componente / Tecnología | Propósito |
|---|---|---|
| **Sistema Operativo** | Ubuntu Server (Headless / CLI) | Base mínima optimizada para cómputo |
| **Pila de Red** | Netplan / systemd-networkd / NetworkManager | Bootstrap por cable y enlace Wi-Fi |
| **Administración** | OpenSSH | Gestión remota segura sin interfaz gráfica |
| **Motor de Inferencia** | Ollama | Servidor y runtime de modelos locales |
| **Modelos Evaluados** | Qwen 2.5 Coder 7B (operativo); Llama 3 y Mistral evaluados inicialmente | Inferencia offline privada |

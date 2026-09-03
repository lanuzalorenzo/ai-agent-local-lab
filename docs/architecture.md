# 🧩 Arquitectura del Agente IA Local  
Diseño técnico del laboratorio de agente de IA ejecutado en GPU NVIDIA con Ollama

Este documento describe la arquitectura completa del sistema, incluyendo componentes,
interacciones, dependencias y flujo de ejecución del agente local.

---

## 🏛️ Visión general

El laboratorio está compuesto por:

- **Ollama** como servidor LLM local  
- **GPU NVIDIA** para aceleración CUDA  
- **VS Code + Continue** como interfaz de desarrollo  
- **Scripts** para instalación, verificación y ejecución  
- **Systemd** para ejecución persistente  
- **Documentación técnica** para reproducibilidad  

---

## 🧠 Componentes principales

### 1. Ollama (runtime LLM)
- Ejecuta modelos localmente  
- Expone una API HTTP  
- Gestiona carga de modelos y memoria  
- Usa CUDA cuando está disponible  

Ubicación del servicio:

```
/usr/share/ollama
/usr/bin/ollama
/etc/systemd/system/ollama.service
```

---

### 2. GPU NVIDIA + CUDA
- Acelera inferencia de modelos  
- Reduce latencia  
- Permite ejecutar modelos más grandes  
- Monitorización con `nvidia-smi`  

---

### 3. VS Code + Continue
- Interfaz del agente  
- Lectura de repositorios  
- Generación de planes  
- Análisis de código  
- Chat técnico con el modelo local  

---

### 4. Scripts del proyecto

#### `install_ollama.sh`
Instala Ollama de forma limpia y sin Snap.

#### `gpu_check.sh`
Verifica estado de GPU y logs del servicio.

#### `run_agent.sh`
Lanza el modelo y muestra logs recientes.

---

### 5. Servicio systemd

Archivo:

```
system/ollama.service
```

Funciones:

- Iniciar Ollama al arrancar  
- Reiniciar automáticamente si falla  
- Gestionar logs y estado del servicio  

---

## 🔄 Flujo de ejecución del agente

1. **El usuario abre VS Code**  
2. **Continue se conecta a Ollama**  
3. **Ollama carga el modelo en GPU**  
4. **El usuario envía una petición**  
5. **El modelo responde usando CUDA**  
6. **Continue muestra la respuesta**  
7. **Logs y estado se monitorizan con scripts**  

---

## 🗂️ Estructura del proyecto

```
ai-agent-local-lab/
├── scripts/          # Instalación, verificación y ejecución
├── docs/             # Documentación técnica
├── examples/         # Sesiones reales del agente
├── system/           # Servicio systemd
└── README.md         # Documento principal del proyecto
```

---

## 📡 Interacciones entre componentes

```
[VS Code] → Continue → Ollama → GPU CUDA
```

- Continue envía peticiones HTTP  
- Ollama procesa la entrada  
- CUDA acelera la inferencia  
- Ollama devuelve la respuesta  
- Continue la muestra en VS Code  

---

## 🧱 Diseño modular

El laboratorio está diseñado para ser:

- **Reproducible**  
- **Extensible**  
- **Documentado**  
- **Fácil de mantener**  
- **Compatible con futuros modelos**  

---

## ✔️ Conclusión

Esta arquitectura permite ejecutar modelos LLM de forma local, rápida y eficiente,
aprovechando la GPU y manteniendo un entorno de desarrollo profesional y controlado.

---
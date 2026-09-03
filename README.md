# 🧠 AI Agent Local Lab  
Laboratorio para ejecutar un agente de IA local con **Ollama + GPU NVIDIA + VS Code (Continue)**

Este proyecto demuestra cómo montar un entorno profesional para ejecutar modelos LLM de forma **local**, **rápida** y **acelerada por GPU**, integrados directamente en el flujo de trabajo de desarrollo mediante **VS Code + Continue**.

El laboratorio está diseñado para ser:

- Reproducible  
- Documentado  
- Modular  
- Fácil de mantener  
- Ideal para portfolio técnico  
- 100% funcional en Linux (Ubuntu)

---

## 🚀 Características principales

- Ejecución local de modelos LLM con **Ollama**  
- Aceleración por **CUDA** en GPU NVIDIA  
- Integración completa con **VS Code + Continue**  
- Scripts de instalación, verificación y ejecución  
- Servicio **systemd** para ejecución persistente  
- Documentación técnica detallada  
- Ejemplos reales de sesiones del agente

---

## 🏛️ Arquitectura del laboratorio

El sistema se compone de:

- **Ollama** como servidor LLM local  
- **GPU NVIDIA** para acelerar la inferencia  
- **VS Code + Continue** como interfaz del agente  
- **Scripts** para instalación y diagnóstico  
- **Servicio systemd** para ejecución automática  
- **Documentación** para reproducibilidad  
- **Ejemplos** para portfolio y demostración

Puedes ver la arquitectura completa en:  
`docs/architecture.md`

---

## 📦 Requisitos

- Ubuntu 22.04 o superior  
- GPU NVIDIA compatible con CUDA  
- Drivers NVIDIA instalados  
- Ollama instalado desde `.deb` (no Snap)  
- VS Code + extensión Continue  

---

## 🔧 Instalación

### 1. Instalar Ollama (sin Snap)

```
curl -fsSL https://ollama.com/install.sh | sh
```

### 2. Instalar drivers NVIDIA

```
sudo ubuntu-drivers autoinstall
sudo reboot
```

### 3. Verificar GPU

```
nvidia-smi
```

### 4. Verificar que Ollama detecta CUDA

```
journalctl -u ollama -n 50 --no-pager | grep -Ei "CUDA|GPU|NVIDIA"
```

Más detalles en:  
`docs/gpu-setup.md`

---

## ⚙️ Servicio systemd

El laboratorio incluye un servicio para ejecutar Ollama automáticamente:

Archivo: `system/ollama.service`

Instalación:

```
sudo cp system/ollama.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable ollama
sudo systemctl start ollama
```

---

## 🧪 Ejemplos de uso

### Sesión del agente

Ejemplo real de interacción con Continue + Ollama + GPU:  
`examples/agent-session.md`

### Demo de lectura de código

Cómo el agente analiza un repositorio completo:  
`examples/code-reading-demo.md`

---

## 🛠️ Troubleshooting

Si algo falla, consulta:  
`docs/troubleshooting.md`

Incluye soluciones para:

- GPU no detectada  
- Ollama sin CUDA  
- Problemas con Snap  
- Continue sin conexión  
- Errores de memoria  
- Logs vacíos  

---

## 📂 Estructura del repositorio

```
ai-agent-local-lab/
├── scripts/          # Instalación, verificación y ejecución
├── docs/             # Documentación técnica
├── system/           # Servicio systemd
├── examples/         # Sesiones reales del agente
└── README.md         # Documento principal del proyecto
```

---

## 🎯 Objetivo del proyecto

Este laboratorio sirve como:

- Base para agentes locales de IA  
- Ejemplo profesional para portfolio  
- Demostración técnica para LinkedIn  
- Entorno reproducible para experimentación  
- Plataforma para integrar modelos LLM en desarrollo real

---

## 🧩 Autor

**Lorenzo Lanuza**  

---

## ✔️ Estado del proyecto

**Completamente funcional**  
Listo para publicar en GitHub y compartir en LinkedIn.

---
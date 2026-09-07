# 🧠 AI Agent Local Lab

## 🧾 Descripción
Laboratorio técnico para ejecutar un agente de inteligencia artificial de forma local utilizando Ollama, aceleración por GPU NVIDIA y la integración con VS Code mediante la extensión Continue.  
El objetivo es disponer de un entorno reproducible y estable para trabajar con modelos LLM en desarrollo real.

---

## 🎯 Objetivos del proyecto
- Ejecutar modelos LLM de forma local con aceleración por GPU.
- Integrar el agente en el flujo de trabajo de desarrollo mediante VS Code + Continue.
- Proporcionar scripts y documentación para instalación, verificación y diagnóstico.
- Ofrecer un entorno reproducible para experimentación y análisis técnico.

---

## 🏛️ Arquitectura del laboratorio
El sistema se compone de:
- **Ollama** como servidor LLM local.  
- **GPU NVIDIA** para acelerar la inferencia mediante CUDA.  
- **VS Code + Continue** como interfaz del agente.  
- **Scripts** para instalación, verificación y ejecución.  
- **Servicio systemd** para ejecución persistente.  
- **Documentación técnica** para reproducibilidad.  
- **Ejemplos reales** de sesiones del agente.

Más detalles en `docs/architecture.md`.

---

## 📦 Requisitos
- Ubuntu 22.04 o superior.  
- GPU NVIDIA compatible con CUDA.  
- Drivers NVIDIA instalados.  
- Ollama instalado desde `.deb`.  
- VS Code + extensión Continue.

---

## 🔧 Instalación
1. Instalar Ollama:
   ```bash
   curl -fsSL https://ollama.com/install.sh | sh
   ```
2. Instalar drivers NVIDIA:
   ```bash
   sudo ubuntu-drivers autoinstall
   sudo reboot
   ```
3. Verificar GPU:
   ```bash
   nvidia-smi
   ```
4. Verificar que Ollama detecta CUDA:
   ```bash
   journalctl -u ollama -n 50 --no-pager | grep -Ei "CUDA|GPU|NVIDIA"
   ```

Más detalles en `docs/gpu-setup.md`.

---

## ⚙️ Servicio systemd
Archivo: `system/ollama.service`

Instalación:
```bash
sudo cp system/ollama.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable ollama
sudo systemctl start ollama
```

---

## 🧪 Ejemplos de uso
- Sesión del agente: `examples/agent-session.md`  
- Lectura de código: `examples/code-reading-demo.md`

---

## 🛠️ Troubleshooting
Consultar `docs/troubleshooting.md` para resolver:
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
├── scripts/      # Instalación, verificación y ejecución
├── docs/         # Documentación técnica
├── system/       # Servicio systemd
├── examples/     # Sesiones reales del agente
└── README.md     # Documento principal del proyecto
```

---

## 📘 Alcance
Este laboratorio cubre:
- Instalación y configuración de Ollama con GPU.
- Integración con VS Code + Continue.
- Ejecución local de modelos LLM.
- Diagnóstico y troubleshooting del entorno.

No cubre:
- Entrenamiento de modelos.  
- Fine-tuning.  
- Despliegue en servidores remotos.  
- Integración con pipelines CI/CD.

---

## 🧩 Bitácoras
Las bitácoras del proyecto se encuentran en la carpeta `bitacora/`.

---

## ⚖️ Aviso Legal
Este laboratorio se utiliza con fines educativos y técnicos.  
No contiene información sensible ni perteneciente a ninguna organización real.  
Los ejemplos y configuraciones son demostraciones técnicas reproducibles en entornos personales.

---

## 📜 Licencia
MIT
```

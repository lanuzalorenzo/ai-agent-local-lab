# 🧠 AI Agent Local Lab  
Laboratorio de agente de IA local con Ollama + GPU NVIDIA + VS Code (Continue)

Este proyecto documenta la creación, configuración y despliegue de un agente de IA local
ejecutado íntegramente en una GPU NVIDIA (RTX 3050), utilizando Ollama como runtime y
Continue como interfaz de desarrollo en VS Code.  
Incluye instalación, troubleshooting, arquitectura, scripts y demostraciones reales.

---

## 📌 Objetivos del proyecto

- Ejecutar modelos LLM de última generación localmente con aceleración GPU.
- Integrar el runtime Ollama con VS Code (Continue) para análisis de código y asistencia.
- Documentar todo el proceso técnico: instalación, problemas, soluciones y verificación.
- Crear un laboratorio reproducible para futuros agentes, herramientas y experimentos.

---

## ⚙️ Arquitectura del sistema

- Ollama (.deb) como servidor LLM local.
- CUDA 13.2 + drivers NVIDIA para aceleración.
- RTX 3050 Laptop GPU (3.7 GiB VRAM detectada).
- VS Code + Continue como interfaz del agente.
- Systemd service para ejecución persistente.
- Scripts auxiliares para instalación, verificación y pruebas.

---

## 🚀 Instalación rápida

> Requisitos: Ubuntu 22.04+, GPU NVIDIA, drivers actualizados.

### 1. Instalar Ollama con soporte GPU

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

### 2. Verificar GPU

```bash
journalctl -u ollama -n 50 --no-pager
```

Debe aparecer una línea similar a:

```text
library=CUDA name="NVIDIA GeForce RTX 3050 Laptop GPU"
```

### 3. Probar un modelo

```bash
ollama run llama3.1:8b
```

### 4. Integración con Continue (VS Code)

- Instalar extensión Continue  
- Seleccionar modelo local  
- Ejecutar comandos como `/read .` o `/plan`

---

## 🧪 Demostración

Ejemplos incluidos en `examples/`:

- Lectura de repositorios completos  
- Generación de planes de trabajo  
- Análisis de código  
- Conversaciones técnicas con el agente local  
- Verificación de GPU en tiempo real (`nvidia-smi`)

---

## 🛠️ Estructura del repositorio

```text
ai-agent-local-lab/
├─ README.md
├─ LICENSE
├─ scripts/
│  ├─ install_ollama.sh
│  ├─ gpu_check.sh
│  └─ run_agent.sh
├─ docs/
│  ├─ architecture.md
│  ├─ troubleshooting.md
│  └─ gpu-setup.md
├─ examples/
│  ├─ agent-session.md
│  └─ code-reading-demo.md
└─ system/
   └─ ollama.service
```

---

## 📚 Documentación

- `docs/architecture.md` → arquitectura del agente  
- `docs/gpu-setup.md` → instalación y verificación CUDA  
- `docs/troubleshooting.md` → problemas comunes (Snap, PATH, hash, systemd)

---

## ⚖️ Aviso Legal

Este repositorio tiene fines educativos y de portfolio profesional.  
No contiene información sensible, confidencial ni perteneciente a ninguna empresa.  
Las configuraciones, scripts y ejemplos incluidos son demostraciones técnicas y no
representan sistemas reales de producción.  
El uso del contenido se realiza bajo la responsabilidad del usuario.

---

## 📄 Licencia

Este proyecto está bajo licencia MIT, permitiendo uso, copia, modificación y distribución
con fines personales y comerciales, siempre que se mantenga el aviso de copyright.

---

## 🧩 Contribuciones

Las contribuciones son bienvenidas: mejoras en scripts, documentación, ejemplos o nuevas
integraciones con agentes locales.

---

## 👤 Autor

**Lorenzo Lanuza Arellano**  
Laboratorio de IA local · 2026

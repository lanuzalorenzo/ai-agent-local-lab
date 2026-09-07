# 📖 Demo de lectura de código del agente IA local

## 🧾 Descripción
Ejemplo técnico de cómo el agente IA local analiza un repositorio utilizando Ollama con aceleración GPU y la extensión Continue en VS Code.  
Este documento muestra una sesión real de lectura y análisis de código realizada en el laboratorio.

---

## 🚀 Contexto de la sesión
- Entorno: VS Code + Continue  
- Modelo: `llama3.1:8b` vía Ollama  
- GPU: NVIDIA RTX 3050 Laptop GPU (CUDA)  
- Proyecto analizado: `ai-agent-local-lab`

---

## 💬 Petición del usuario
El usuario solicita al agente:

- Qué hace el proyecto  
- Qué arquitectura sigue  
- Qué mejoras técnicas recomienda  

Continue envía la petición al modelo local mediante:

```
POST http://localhost/api/generate
Model: llama3.1:8b
```

---

## 🧠 Análisis del repositorio por el agente
El modelo recorre las siguientes rutas:

- `scripts/` → instalación, verificación y ejecución  
- `docs/` → arquitectura, GPU y troubleshooting  
- `system/` → servicio `ollama.service`  
- `examples/` → sesiones de uso del agente  
- `README.md` → descripción general del laboratorio  

Salida típica del agente:

> Este repositorio define un laboratorio para ejecutar un agente de IA local sobre Ollama con aceleración GPU, integrando scripts de instalación, documentación técnica, servicio systemd y ejemplos de uso. La arquitectura es modular y orientada a reproducibilidad.

---

## 🔍 Sugerencias técnicas del agente
El modelo propone mejoras como:

- Añadir tests automatizados  
- Ampliar documentación  
- Extender ejemplos de uso  

Ejemplo de respuesta:

> Recomiendo añadir una carpeta `tests/` con scripts de validación, un diagrama de arquitectura en `docs/architecture.md` y más ejemplos de interacción en `examples/`. Esto hará el laboratorio más profesional y fácil de entender para terceros.

---

## ⚙️ Verificación de rendimiento durante la lectura
Monitorización de GPU:

```bash
nvidia-smi
```

Salida típica:

```
llama3.1:8b   2800MiB / 4096MiB
```

Esto confirma que la lectura y análisis se ejecutan con aceleración CUDA.

---

## 📜 Logs del servicio durante la demo
```bash
journalctl -u ollama -n 30 --no-pager
```

Ejemplo de logs:

```
model loaded: llama3.1:8b
request: code analysis
response generated in 1.4s
library=CUDA
name="NVIDIA GeForce RTX 3050 Laptop GPU"
```

---

## ✔️ Conclusión
Esta demo muestra cómo el agente IA local:

- entiende la estructura de un repositorio  
- explica la arquitectura del proyecto  
- propone mejoras técnicas razonables  
- aprovecha la GPU para acelerar la inferencia  

Sirve como referencia clara para mostrar el valor real de un agente IA local integrado en el flujo de trabajo de desarrollo.

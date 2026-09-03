# 📖 Demo de lectura de código del agente IA local  
Ejemplo de cómo el agente analiza un repositorio usando Ollama + GPU + VS Code (Continue)

Este documento muestra una sesión de lectura y análisis de código realizada por el agente
local configurado en este laboratorio. El objetivo es enseñar cómo el modelo entiende la
estructura de un proyecto y propone mejoras técnicas.

---

## 🚀 Contexto de la sesión

Entorno:

- VS Code con la extensión Continue  
- Modelo local: `llama3.1:8b` vía Ollama  
- GPU: NVIDIA RTX 3050 Laptop GPU (CUDA)  
- Proyecto abierto: `ai-agent-local-lab`  

---

## 💬 Petición del usuario

El usuario pide al agente:

> “Lee este repositorio y explícame:
> 1. Qué hace el proyecto  
> 2. Qué arquitectura sigue  
> 3. Qué mejorarías a nivel técnico”

Continue envía la petición al modelo local:

```
POST http://localhost:11434/api/generate
Model: llama3.1:8b
```

---

## 🧠 Análisis del repositorio por el agente

El modelo recorre:

- `scripts/` → instalación, verificación y ejecución  
- `docs/` → arquitectura, GPU y troubleshooting  
- `system/` → servicio `ollama.service`  
- `examples/` → sesiones de uso del agente  
- `README.md` → descripción general del laboratorio  

Salida típica del agente:

```
Este repositorio define un laboratorio para ejecutar un agente de IA local
sobre Ollama con aceleración GPU, integrando:

- scripts de instalación y verificación
- documentación técnica detallada
- servicio systemd para ejecución persistente
- ejemplos de uso del agente

La arquitectura es modular y orientada a reproducibilidad.
```

---

## 🔍 Sugerencias técnicas del agente

El modelo propone mejoras como:

- **Añadir tests automatizados**  
- **Mejorar documentación**  
- **Extender ejemplos**  

Ejemplo de respuesta:

```
Recomiendo añadir:

- una carpeta `tests/` con scripts de validación
- un diagrama de arquitectura en `docs/architecture.md`
- más ejemplos de interacción en `examples/`

Esto hará el laboratorio más profesional y fácil de entender para terceros.
```

---

## ⚙️ Verificación de rendimiento durante la lectura

Mientras el agente analiza el código, se puede monitorizar la GPU:

```
nvidia-smi
```

Salida típica:

```
llama3.1:8b   2800MiB / 4096MiB
```

Esto confirma que la lectura y análisis de código se están ejecutando con
aceleración CUDA.

---

## 📜 Logs del servicio durante la demo

```
journalctl -u ollama -n 30 --no-pager
```

Ejemplo de logs:

```
model loaded: llama3.1:8b
request: code analysis
response generated in 1.4s
library=CUDA name="NVIDIA GeForce RTX 3050 Laptop GPU"
```

---

## ✔️ Conclusión

Este ejemplo demuestra cómo el agente:

- entiende la estructura de un repositorio  
- explica la arquitectura del proyecto  
- propone mejoras técnicas razonables  
- aprovecha la GPU para acelerar la inferencia  

Este archivo sirve como demo clara para tu portfolio y como referencia para
mostrar el valor real de un agente IA local integrado en el flujo de trabajo
de desarrollo.

---

Cuando me digas **“ya está”**, seguimos con el README final y dejamos tu repo listo para publicar.
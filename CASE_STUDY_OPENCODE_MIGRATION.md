# Caso de Estudio: Estrategia de Dos Flujos para Asistencia de IA — OpenCode (CLI) con Entorno Híbrido (Local + Cloud)

## 1. Visión General del Proyecto
Diseño e implementación de una estrategia de desarrollo asistido por IA basada en **dos flujos de trabajo independientes y desacoplados**, permitiendo alternar según las exigencias técnicas de privacidad, contexto y capacidad de razonamiento entre un servidor de inferencia local y modelos de alta capacidad en la nube.

---

## 2. Flujo 1: Desarrollo Privado y Edición Local (Ollama + Servidor Dedicado)
* **Propósito:** Edición de código sensible, pruebas offline, autocompletado en IDEs y tareas que requieran 100% de privacidad y control de datos.
* **Infraestructura:** Servidor local en red privada (`ollama.lab.local:11434`) ejecutando Ollama con **Qwen 2.5 Coder (7B)**.
* **Casos de uso:** 
  * Modificación de ficheros de código fuente y parches directos en el repositorio.
  * Ejecución de scripts o tareas de ciberseguridad sin exposición de datos a terceras APIs.
  * Baja latencia en respuestas locales.

---

## 3. Flujo 2: Documentación Masiva y Arquitectura (NVIDIA NIM / Cloud)
* **Propósito:** Análisis profundo de repositorios enteros, estructuración de carpetas, generación masiva de ficheros Markdown y cumplimiento estricto de formatos preestablecidos.
* **Infraestructura:** Integración de las API Keys gratuitas de **NVIDIA NIM** dentro de OpenCode, empleando modelos de gran escala (ej. **Nemotron 70B** o **DeepSeek R1**).
* **Casos de uso:**
  * Ventanas de contexto masivas ($64\text{k}+$ tokens) capaces de leer todo el árbol de directorios de un proyecto de una sola vez.
  * Razonamiento avanzado para estructurar y redactar documentación técnica y guías de arquitectura sin truncamientos.

---

## 4. Configuración Técnica de Ambos Proveedores (`opencode.json`)
La configuración unificada en el cliente permite invocar cualquiera de los dos flujos según la necesidad de la tarea:

```json
{
  "$schema": "[https://opencode.ai/config.json](https://opencode.ai/config.json)",
  "model": "nvidia/llama-3.1-nemotron-70b-instruct",
  "providers": {
    "nvidia": {
      "npm": "@ai-sdk/openai-compatible",
      "options": {
        "baseURL": "[https://integrate.api.nvidia.com/v1](https://integrate.api.nvidia.com/v1)",
        "apiKey": "TU_NVIDIA_API_KEY_AQUI"
      },
      "models": {
        "nvidia/llama-3.1-nemotron-70b-instruct": {
          "name": "Nemotron 70B (NVIDIA Cloud)"
        }
      }
    },
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "options": {
        "baseURL": "[http://ollama.lab.local:11434/v1](http://ollama.lab.local:11434/v1)"
      },
      "models": {
        "qwen2.5-coder:7b": {
          "name": "Qwen 2.5 Coder 7B (Local)"
        }
      }
    }
  }
}
```

# Caso de Estudio: Estrategia de Dos Flujos para Asistencia de IA — OpenCode (CLI) con Entorno Híbrido (Local + Cloud)

## 1. Visión General del Proyecto

Diseño de una estrategia de desarrollo asistido por IA basada en **dos flujos de
trabajo independientes y desacoplados**, para alternar según las exigencias de
privacidad, contexto y capacidad de razonamiento entre un servidor de inferencia
local y modelos de alta capacidad en la nube.

El objetivo no es “usar la IA para todo”, sino asignar cada tarea al entorno que
ofrece el mejor equilibrio entre privacidad, coste, latencia y calidad.

---

## 2. Flujo 1: Desarrollo Privado y Edición Local (Ollama + Servidor Dedicado)

- **Propósito:** edición de código sensible, pruebas offline, autocompletado en
  IDE y tareas que requieran control de datos.
- **Infraestructura:** servidor local en red privada (`http://ollama.lab.local:11434`)
  ejecutando Ollama con **Qwen 2.5 Coder (7B)**.
- **Casos de uso:**
  - Modificación de ficheros de código fuente y parches directos en el repositorio.
  - Ejecución de scripts o tareas de ciberseguridad sin exponer datos a APIs de terceros.
  - Baja latencia en respuestas locales.
- **Límites:**
  - La ventana de contexto es menor que la de los modelos cloud.
  - La calidad depende del hardware y del modelo descargado.
  - “Local” no implica automáticamente “privado”: hay que controlar la escucha
    de red, el firewall, los logs y el cliente.

---

## 3. Flujo 2: Documentación Masiva y Arquitectura (NVIDIA NIM / Cloud)

- **Propósito:** análisis de repositorios completos, estructuración de carpetas,
  generación de documentación Markdown y cumplimiento de formatos.
- **Infraestructura:** API de **NVIDIA NIM** integrada en OpenCode, con modelos de
  gran escala (por ejemplo, **Nemotron 70B** o **DeepSeek R1**).
- **Casos de uso:**
  - Ventanas de contexto amplias (64k+ tokens) para leer árboles de directorios.
  - Razonamiento avanzado para arquitectura y redacción técnica.
- **Límites:**
  - Los datos salen del entorno local; no usar con código sensible, secretos ni
    datos personales.
  - Depende de cuotas, disponibilidad y políticas del proveedor.
  - La clave de API debe gestionarse fuera del repositorio.

---

## 4. Configuración Técnica de Ambos Proveedores (`opencode.json`)

La configuración unificada permite invocar cualquiera de los dos flujos según la
necesidad de la tarea. El ejemplo es válido y usa sustitución de variables de
entorno para la clave:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "model": "nvidia/llama-3.1-nemotron-70b-instruct",
  "providers": {
    "nvidia": {
      "npm": "@ai-sdk/openai-compatible",
      "options": {
        "baseURL": "https://integrate.api.nvidia.com/v1",
        "apiKey": "{env:NVIDIA_API_KEY}"
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
        "baseURL": "http://ollama.lab.local:11434/v1"
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

> Sustituye `ollama.lab.local` por el hostname de tu red y define
> `NVIDIA_API_KEY` en el entorno. No guardes la clave en `opencode.json` ni en el
> repositorio.

---

## 5. Criterios de Selección

| Criterio | Flujo local | Flujo cloud |
|---|---|---|
| Privacidad del código | Alta, si la red y los logs están controlados | Baja: el código sale del entorno |
| Ventana de contexto | Limitada por RAM/VRAM | Amplia (64k+) |
| Coste marginal | Hardware y electricidad | Cuotas/API |
| Latencia | Baja en red local | Depende de la red y del proveedor |
| Calidad en arquitectura | Buena con modelos de código | Alta con modelos grandes |
| Datos permitidos | Código de laboratorio y datos sintéticos | Documentación pública, nunca secretos |

---

## 6. Seguridad del Laboratorio

- Ollama no debe escuchar en `0.0.0.0:11434` sin firewall.
- El puerto no se publica en Internet; el acceso remoto usa red privada y, si es
  necesario, un proxy con TLS y autenticación.
- Las claves de API se inyectan por variables de entorno y nunca se versionan.
- Los prompts privados, notas personales y datos de clientes quedan fuera del
  repositorio y del contexto enviado al cloud.
- Los modelos se descargan de fuentes oficiales; se revisa el origen y la licencia.
- Los logs de inferencia se tratan como potencialmente sensibles.

---

## 7. Estado y Validación

| Elemento | Estado |
|---|---|
| Servidor Ubuntu + Ollama | Documentado; instalación no reproducida en este repositorio |
| Modelo local Qwen 2.5 Coder 7B | Configurado en el `Modelfile` y en la guía de Continue |
| Integración con OpenCode | Configuración de ejemplo; requiere clave y hostname reales |
| Flujo cloud NVIDIA NIM | Documentado; no se incluyen claves ni ejecuciones |
| Medición de latencia/calidad | No realizada; no se presentan métricas |

---

## 8. Lecciones Aprendidas

1. Separar flujos evita enviar código sensible a la nube por comodidad.
2. La ventana de contexto es un criterio de selección, no una moda.
3. La seguridad del laboratorio depende de la red y de la gestión de claves, no
   solo de que el modelo se ejecute “en local”.
4. La documentación debe distinguir configuración, ejecución y medición.

La mecánica de continuidad entre sesiones (comandos, briefs y estado en archivos) se documenta en [`docs/opencode-session-continuity.md`](docs/opencode-session-continuity.md).

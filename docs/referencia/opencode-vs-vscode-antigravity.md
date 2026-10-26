# OpenCode vs VS Code / Google Antigravity: criterios de decisión

> **Referencia del laboratorio.** Comparativa orientada a privacidad, coste y control de contexto para elegir herramienta de agente. No es una evidencia de ejecución ni un benchmark; las afirmaciones sobre políticas de privacidad deben verificarse en las fuentes oficiales de cada proveedor.

## 1. Propósito

Decidir qué herramienta usar como agente de código en este laboratorio, sin asumir que una es mejor en todos los casos. El criterio principal es el mismo que el del laboratorio: **privacidad, control y evidencia**, no comodidad.

## 2. Qué es cada cosa

### OpenCode

- Cliente-servidor: TUI/CLI y web se conectan a un servicio compartido que posee sesiones, configuración, plugins y herramientas.
- Configuración por archivos (`opencode.json(c)`, `AGENTS.md`, comandos, skills, plugins) con descubrimiento por directorio.
- Soporta proveedores locales (Ollama) y remotos, MCP, compaction, ignore y control de contexto.
- Modo local-first posible: modelos en Ollama, sin salida a la nube.

### VS Code con Copilot / agentes

- IDE integrado con chat, autocompletado y agentes en la propia ventana de edición.
- Configuración por extensiones y settings; el contexto se gestiona dentro del editor.
- Fuerte integración con el árbol de archivos, depuración y terminal.
- Dependencia de la política de datos del proveedor del asistente (Copilot y otros).

### Google Antigravity

- Asistente de código integrado en el ecosistema de Google (Gemini).
- Orientado a productividad en el editor y a generación asistida.
- La privacidad y el tratamiento de datos dependen de los términos del servicio y de la configuración de la cuenta.

> Nota: las descripciones de VS Code y Antigravity son generales. Verificar capacidades y políticas actuales en sus documentaciones oficiales antes de tomar una decisión vinculante.

## 3. Comparativa por dimensiones

| Dimensión | OpenCode | VS Code + Copilot/agentes | Antigravity |
|---|---|---|---|
| **Privacidad de datos** | Configurable: modelos locales (Ollama) sin salida a la nube; los modelos remotos dependen del proveedor. OpenCode Go entrena con datos de la petición. | Depende del proveedor del asistente y de la configuración de la cuenta. | Depende de los términos de Google y de la configuración de la cuenta. |
| **Control de contexto** | Alto: `AGENTS.md`, `.opencodeignore`, `compaction`, `tool_output`, comandos y archivos de estado. | Medio: gestionado por el editor y la extensión; menos explícito. | Medio: gestionado por el asistente; menos explícito. |
| **Coste** | Gratuito con modelos locales; suscripción Go para modelos gestionados; cuotas por proveedor. | Suscripción Copilot o proveedor externo. | Suscripción o cuota de Google. |
| **Extensibilidad** | Plugins, MCP, skills, comandos, agents personalizados. | Extensiones del marketplace, MCP según soporte. | Integración con el ecosistema Google. |
| **Portabilidad** | CLI/TUI y web; funciona en terminal y servidores remotos. | Requiere el editor (o Codespaces). | Requiere el entorno de Google. |
| **Curva de aprendizaje** | Alta: configuración por archivos y conceptos (compaction, agents, MCP). | Baja-media: integrado en el editor. | Baja-media: integrado en el editor. |
| **Trazabilidad** | Alta: sesiones, briefs, commits, archivos de estado. | Media: historial de chat y cambios. | Media: historial de chat y cambios. |

## 4. OpenCode Go vs consola/CLI

- **OpenCode Go**: suscripción que da acceso a modelos gestionados. Algunos de esos modelos entrenan con los datos de la petición; revisar la política de privacidad antes de usarlos con código o datos sensibles.
- **CLI/TUI y web**: interfaces al mismo servicio. La CLI/TUI permite trabajar en terminal y servidores remotos; la web facilita la gestión visual. La configuración y las sesiones son compartidas.
- **Modelos locales (Ollama)**: no requieren suscripción ni salida a la nube; son la opción por defecto cuando la privacidad es prioritaria.

Regla práctica: si el código o los datos no deben salir del equipo, usa modelos locales. Si usas Go, asume que los datos pueden usarse para entrenamiento.

## 5. Cuándo elegir cada uno

- **OpenCode** cuando quieras control fino del contexto, trabajar en terminal/servidor, usar modelos locales o documentar el proceso con archivos de estado.
- **VS Code + Copilot/agentes** cuando la productividad en el editor sea prioritaria y la política de datos del proveedor sea aceptable.
- **Antigravity** cuando ya estés en el ecosistema Google y su política de datos encaje con tu caso.

En este laboratorio, la opción por defecto es OpenCode con modelos locales, por privacidad y trazabilidad.

## 6. Límites

- Esta comparativa no incluye benchmarks de calidad ni de velocidad; no se han medido en este laboratorio.
- Las políticas de privacidad cambian; verificarlas en las fuentes oficiales antes de una decisión vinculante.
- No se recomienda una herramienta única para todos los casos; la elección depende del riesgo aceptable y del coste.
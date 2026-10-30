# Índice de Documentación

Este directorio organiza la documentación del laboratorio en tres capas: **arquitectura** (decisiones y diseño), **guías** (procedimientos ejecutables) y **referencia** (marcos de evaluación y bitácora). Las **evidencias** registran ejecuciones reales con artefactos verificables o registros parciales que declaran explícitamente lo que falta.

## Arquitectura (`arquitectura/`)

| Documento | Qué contiene |
|-----------|--------------|
| [`architecture.md`](arquitectura/architecture.md) | Visión general de componentes, límites de confianza y flujo previsto |
| [`contenerizacion.md`](arquitectura/contenerizacion.md) | Diseño futuro: Docker/Compose para infraestructura de inferencia reproducible |
| [`squad.md`](arquitectura/squad.md) | Diseño futuro: patrón de agentes colaborativos locales |

## Guías (`guias/`)

Procedimientos paso a paso para instalar, configurar y diagnosticar.

| Documento | Qué resuelve |
|-----------|--------------|
| [`server-deployment-ubuntu-ollama.md`](guias/server-deployment-ubuntu-ollama.md) | Despliegue bare-metal headless: Ubuntu Server, Netplan, OpenSSH, Ollama |
| [`continue-remote-ollama-setup.md`](guias/continue-remote-ollama-setup.md) | Sincronización de ventana de contexto 16K entre Continue y Ollama remoto |
| [`gpu-setup.md`](guias/gpu-setup.md) | Comprobación de drivers CUDA y visibilidad de GPU para Ollama |
| [`opencode-desde-cero.md`](guias/opencode-desde-cero.md) | Qué es OpenCode, por qué empezar con un modelo local y tu primera sesión |
| [`agents-md-publico-privado.md`](guias/agents-md-publico-privado.md) | Cómo organizar las instrucciones de un proyecto y el filtro antes de publicarlas |
| [`opencode-session-continuity.md`](guias/opencode-session-continuity.md) | Patrón de continuidad entre sesiones con comandos y archivos de estado |
| [`local-vs-cloud.md`](guias/local-vs-cloud.md) | Criterios de decisión para elegir ejecución local vs cloud |
| [`troubleshooting.md`](guias/troubleshooting.md) | Diagnóstico conservador de problemas frecuentes |

## Referencia (`referencia/`)

Marcos de evaluación, bitácora técnica y casos de estudio.

| Documento | Qué aporta |
|-----------|------------|
| [`ai-security-evaluation.md`](referencia/ai-security-evaluation.md) | Marco de evaluación de calidad y seguridad de funciones con LLM (conjunto dorado, inyección, métricas, CI) |
| [`prompt-robustness-testing.md`](referencia/prompt-robustness-testing.md) | Diseño de la matriz de perturbación: canarios C0–C4, familias F1–F4, niveles N0–N3, métricas de evasión |
| [`bitacora-decisiones-aprendizaje.md`](referencia/bitacora-decisiones-aprendizaje.md) | Memoria técnica cronológica: decisiones, incidentes, causa raíz, hoja de ruta (GGUF/CUDA, red, clientes, RAG) |
| [`hoja-de-ruta-seguridad-asistentes.md`](referencia/hoja-de-ruta-seguridad-asistentes.md) | Hoja de ruta del eje de seguridad de asistentes: frontera de datos, inyección desde repositorio y permisos; fases y criterios de salida |
| [`CASE_STUDY_OPENCODE_MIGRATION.md`](referencia/CASE_STUDY_OPENCODE_MIGRATION.md) | Caso de estudio: migración de asistentes y lecciones de continuidad de sesión |
| [`coste-contexto-y-optimizacion.md`](referencia/coste-contexto-y-optimizacion.md) | Riesgo de consumo elevado de prompts, controles de optimización y prevención |
| [`opencode-vs-vscode-antigravity.md`](referencia/opencode-vs-vscode-antigravity.md) | Criterios de decisión: OpenCode vs VS Code / Google Antigravity (privacidad, coste, contexto) |

## Evidencias (`evidencias/`)

Ejecuciones reales con artefactos congelados (JSON, huella de entorno, resultados) o registros parciales declarados. Cada carpeta conserva sus artefactos originales; si se corrige un README, se anota la fecha y el motivo en lugar de reescribir la evidencia.

| Carpeta | Qué registra |
|---------|--------------|
| [`2026-10-22-robustez-instrumento/`](evidencias/2026-10-22-robustez-instrumento/) | Validación del instrumento (selftest): determinismo, inversa, testigo, factor de expansión. **Sin modelo**. |
| [`2026-10-22-robustez-ejecucion-v1/`](evidencias/2026-10-22-robustez-ejecucion-v1/) | Primera ejecución con modelo (`qwen2.5:3b`, N0/N1). Obediencia 0,50. Instrumento original. |
| [`2026-10-22-robustez-ejecucion-v2/`](evidencias/2026-10-22-robustez-ejecucion-v2/) | Línea base N0 con instrumento corregido (control negativo C0, 15 transformaciones). Obediencia 0,50 replicada. |
| [`2026-10-26-robustez-prompt-v2/`](evidencias/2026-10-26-robustez-prompt-v2/) | Prompt `v2` endurecido frente a `v1`, N0. Obediencia 0,50 sin cambios: las instrucciones no defienden a este modelo. |
| [`2026-10-30-inferencia-7b-continue/`](evidencias/2026-10-30-inferencia-7b-continue/) | Registro **Parcial**: integración 7B + Continue probada por el autor, sin artefacto reproducible. No es un PASS. |
| [`2026-10-30-opencode-uso-real/`](evidencias/2026-10-30-opencode-uso-real/) | **Validado** el uso de OpenCode v2.1.4 en esta máquina: lectura del repositorio, consulta de documentación, escritura y enlaces. No valida precios ni instalación limpia. |
| [`plantilla-evidencia.md`](evidencias/plantilla-evidencia.md) | Plantilla para registrar nuevas evidencias de forma consistente |

---

## Convenciones

- **Nombres de carpetas de evidencia**: `YYYY-MM-DD-descripcion-corta[-vN]` (ej. `2026-10-22-robustez-ejecucion-v2`)
- **Estados permitidos**: **Validado**, **Parcial**, **Runbook preparado**, **Diseño**, **Pendiente**
- **Evidencia vs hallazgo**: Una auditoría que encuentra el problema ha funcionado, pero el control no está aprobado. La tabla lleva resultado observado y gravedad; aparte, qué se corrigió y qué solo se recomendó.
- **No expongas Ollama a Internet**. Documenta supuestos de firewall, TLS y autenticación.
- **Usa `ollama.lab.local` u otro placeholder**, nunca una IP interna real.

---

## Navegación rápida

- **Empezar aquí**: [`guias/server-deployment-ubuntu-ollama.md`](guias/server-deployment-ubuntu-ollama.md) (despliegue base)
- **Primeros pasos con OpenCode**: [`guias/opencode-desde-cero.md`](guias/opencode-desde-cero.md) (qué es, por qué local, primera sesión)
- **Contexto 16K**: [`guias/continue-remote-ollama-setup.md`](guias/continue-remote-ollama-setup.md)
- **Entender la matriz**: [`referencia/prompt-robustness-testing.md`](referencia/prompt-robustness-testing.md)
- **Seguridad de asistentes**: [`referencia/hoja-de-ruta-seguridad-asistentes.md`](referencia/hoja-de-ruta-seguridad-asistentes.md)
- **Ver resultados reales**: [`evidencias/2026-10-22-robustez-ejecucion-v2/`](evidencias/2026-10-22-robustez-ejecucion-v2/)
- **Hoja de ruta**: [`referencia/bitacora-decisiones-aprendizaje.md#entrada-04-hoja-de-ruta-y-ejes-de-aprendizaje-futuros`](referencia/bitacora-decisiones-aprendizaje.md#entrada-04-hoja-de-ruta-y-ejes-de-aprendizaje-futuros)
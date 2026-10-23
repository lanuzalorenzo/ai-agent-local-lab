# Guía para agentes: ai-agent-local-lab

> **Si llegas nuevo:** el contrato de contenido es el de `portfolio-ciberseguridad-lorenzo/AGENTS.md`. Este archivo añade convenciones técnicas propias del laboratorio de IA.

Este repositorio documenta un laboratorio local de agentes de IA construido con Ollama y Continue, integrado como herramienta complementaria de desarrollo y seguridad en el portfolio.

## Estructura

```text
.
├── AGENTS.md
├── README.md
├── LICENSE
├── docs/
│   ├── README.md
│   ├── arquitectura/
│   │   ├── architecture.md
│   │   ├── contenerizacion.md
│   │   └── squad.md
│   ├── guias/
│   │   ├── continue-remote-ollama-setup.md
│   │   ├── gpu-setup.md
│   │   ├── local-vs-cloud.md
│   │   ├── opencode-session-continuity.md
│   │   ├── server-deployment-ubuntu-ollama.md
│   │   └── troubleshooting.md
│   ├── referencia/
│   │   ├── ai-security-evaluation.md
│   │   ├── bitacora-decisiones-aprendizaje.md
│   │   ├── CASE_STUDY_OPENCODE_MIGRATION.md
│   │   └── prompt-robustness-testing.md
│   └── evidencias/
│       ├── 2026-10-22-robustez-instrumento/
│       ├── 2026-10-22-robustez-ejecucion-v1/
│       ├── 2026-10-22-robustez-ejecucion-v2/
│       └── plantilla-evidencia.md
├── examples/
│   ├── agent-session.md
│   └── code-reading-demo.md
├── scripts/
│   ├── instalacion/
│   │   ├── install_ollama.sh
│   │   └── gpu_check.sh
│   ├── robustez/
│   │   ├── prompt_robustness_matrix.py
│   │   └── run_robustness_lab.sh
│   └── utilidades/
│       └── run_agent.sh
└── config/
    ├── Modelfile.portfolio-agent
    └── ollama.service
```

## Convenciones de contenido (compartidas con el portfolio)
- **Prohibido:** bloques «En fácil», «TL;DR», «En resumen» u otros rótulos de registro. Se escribe en español claro y directo; los nombres oficiales de productos y herramientas se conservan (Ollama, Continue, VS Code, etc.).
- **Estados:** usa solo **Validado**, **Parcial**, **Runbook preparado**, **Diseño** o **Pendiente**. Un diseño o runbook sin ejecutar no es una validación.
- **Estructura de docs:**
  - `README.md` de práctica: 240–310 palabras, problema en prosa, tabla con lo hecho/encontrado, 2–3 lecciones, enlaces.
  - `informe.md` solo si sostiene lo que la página no puede (catálogo, valores, matriz, verificación). No duplica la página.
  - `runbook.md` solo para prácticas reejecutables.
  - `bitacora/` solo si guarda un hecho que no está en otro sitio.
- **Evidencia vs hallazgo:** una auditoría que encuentra el problema ha funcionado, pero el control no está aprobado. La tabla lleva resultado observado y gravedad; aparte, qué se corrigió y qué solo se recomendó.
- **Alcance local-first:** el cloud es un complemento justificado, no el tema principal. No añadas rankings de modelos, noticias ni comparativas sin medición propia.
- En documentos de evaluación de IA, separa diseño/expectativas de resultados medidos; no presentes umbrales como resultados.
- No expongas Ollama a Internet. Documenta supuestos de firewall, TLS y autenticación.
- Usa `ollama.lab.local` u otro placeholder, nunca una IP interna real.
- Este laboratorio es independiente del laboratorio final de ciberseguridad. Si se enlaza desde el portfolio, mantiene su alcance y evidencias separados.
- Registra decisiones, problemas y análisis de causa raíz en `docs/bitacora-decisiones-aprendizaje.md`; mantén la hoja de ruta (GGUF/CUDA, seguridad de red, integración de cliente, RAG) actualizada allí.

## Convenciones de Commits
Formato: `type(scope): imperative summary in English`
Ámbitos permitidos:
- `docs` — cambios en archivos de documentación bajo `docs/`
- `examples` — cambios en archivos de ejemplos bajo `examples/`
- `scripts` — cambios en scripts de shell bajo `scripts/`
- `config` — cambios en archivos de configuración bajo `config/`
- `repo` — cambios generales del repositorio (README, AGENTS.md, LICENSE, config a nivel raíz)
Tipos permitidos: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`
El asunto debe ser imperativo, conciso y en inglés.
# Repository Guide — ai-agent-local-lab

> **If you are new:** the content contract is defined in `portfolio-ciberseguridad-lorenzo/AGENTS.md`. This file adds repo-specific conventions.

This repository documents a local AI agent lab built with Ollama and Continue, integrated as a development and security portfolio companion tool.

## Structure

```text
.
├── AGENTS.md
├── README.md
├── LICENSE
├── CASE_STUDY_OPENCODE_MIGRATION.md
├── docs/
│   ├── architecture.md
│   ├── bitacora-decisiones-aprendizaje.md
│   ├── continue-remote-ollama-setup.md
│   ├── gpu-setup.md
│   ├── server-deployment-ubuntu-ollama.md
│   ├── opencode-session-continuity.md
│   ├── ai-security-evaluation.md
│   ├── prompt-robustness-testing.md
│   ├── local-vs-cloud.md
│   └── troubleshooting.md
├── docs/evidencias/
│   └── 2026-10-22-robustez-prompt/
├── evolutivos/
│   ├── contenerizacion.md
│   └── squad.md
├── examples/
│   ├── agent-session.md
│   └── code-reading-demo.md
├── scripts/
│   ├── install_ollama.sh
│   ├── prompt_robustness_matrix.py
│   ├── run_robustness_lab.sh
│   ├── run_agent.sh
│   └── gpu_check.sh
└── system/
    ├── Modelfile.portfolio-agent
    └── ollama.service
```

## Content conventions (shared with portfolio)
- **Forbidden:** "En fácil", "TL;DR", "In short" or similar register labels. Write in clear, direct Spanish; keep official product/tool names in original form (Ollama, Continue, VS Code, etc.).
- **States:** use only **Validado**, **Parcial**, **Runbook preparado**, **Diseño** or **Pendiente**. A design or runbook not executed is not a validation.
- **Document structure:**
  - Practice `README.md`: 240–310 words, problem in prose, table with what was done/found, 2–3 lessons, links.
  - `informe.md` only if it sustains what the page cannot (catalogue, values, matrix, verification). Does not duplicate the page.
  - `runbook.md` only for re-runnable practices.
  - `bitacora/` only if it records a fact not captured elsewhere.
- **Evidence vs finding:** an audit that finds the issue worked, but the control is not approved. The table shows observed result and severity; separately, what was fixed and what was only recommended.
- **Local-first scope:** cloud is a justified complement, not the main topic. Do not add model rankings, news or unmeasured benchmarks.
- In AI evaluation documents, separate design/expectations from measured results; do not present thresholds as outcomes.
- Do not expose Ollama to the Internet. Document firewall, TLS and authentication assumptions.
- Use `ollama.lab.local` or another placeholder, never a real internal IP.
- This lab is independent from the cybersecurity final lab. If linked from the portfolio, keep scope and evidence separate.
- Record decisions, problems and root-cause analyses in `docs/bitacora-decisiones-aprendizaje.md`; keep the roadmap (GGUF/CUDA, network security, client integration, RAG) updated there.

## Commit Conventions
Format: `type(scope): imperative summary in English`
Allowed scopes:
- `docs` — changes to documentation files under `docs/`
- `examples` — changes to example files under `examples/`
- `scripts` — changes to shell scripts under `scripts/`
- `system` — changes to system service files under `system/`
- `repo` — general repository changes (README, AGENTS.md, LICENSE, root-level config)
Allowed types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`
Subject must be imperative, concise and in English.
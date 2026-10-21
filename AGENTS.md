# Repository Guide

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
│   ├── local-vs-cloud.md
│   └── troubleshooting.md
├── examples/
│   ├── agent-session.md
│   └── code-reading-demo.md
├── scripts/
│   ├── install_ollama.sh
│   ├── run_agent.sh
│   └── gpu_check.sh
└── system/
    ├── Modelfile.portfolio-agent
    └── ollama.service
```

When working in this repository:

- Check the existing documentation before creating or modifying content.
- Preserve the current structure. Follow the existing pattern when adding new documents.
- Do not add empty files or restructure existing content without a clear reason.
- Write documentation in clear Spanish; keep official product and tool names in their original form (Ollama, Continue, VS Code, etc.).
- Do not include credentials, API keys, personal data, internal IP addresses or private prompt filenames.
- Distinguish between validated results and planned or pending work.
- Keep the operational model (`qwen2.5-coder:7b`) aligned across README, Modelfile, scripts and docs.
- Keep the local-first scope: cloud is a justified complement, not the main topic. Do not add model rankings, news or unmeasured benchmarks.
- In AI evaluation documents, separate design and expectations from measured results; do not present thresholds as outcomes.
- Do not expose Ollama to the Internet. Document firewall, TLS and authentication assumptions.
- Use `ollama.lab.local` or another placeholder, never a real internal IP.
- This lab is independent from the cybersecurity final lab. If linked from the portfolio, keep the scope and evidence separate.
- Record decisions, problems and root-cause analyses in `docs/bitacora-decisiones-aprendizaje.md`; keep the roadmap (GGUF/CUDA, network security, client integration, RAG) updated there.

## Commit Conventions

All commits in this repository (made by the user or by AI assistants such as GitHub Copilot, Google Antigravity, Claude, etc.) must strictly follow the **Conventional Commits** standard:

- Format: `type(scope): imperative summary in English`
- **Allowed scopes:**
  - `docs` — changes to documentation files under `docs/`
  - `examples` — changes to example files under `examples/`
  - `scripts` — changes to shell scripts under `scripts/`
  - `system` — changes to system service files under `system/`
  - `repo` — general repository changes (README, AGENTS.md, LICENSE, root-level config)
- **Allowed types:** `feat`, `fix`, `docs`, `refactor`, `test`, `chore`
- The subject must be imperative, concise and written in English.
- Examples:
  - `docs(docs): add GPU setup guide for NVIDIA drivers`
  - `chore(scripts): add Ollama install and agent run scripts`
  - `docs(repo): init repository README with architecture and setup`
  - `feat(system): add ollama systemd service unit`

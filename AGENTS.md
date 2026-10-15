# Repository Guide

This repository documents a local AI agent lab built with Ollama and Continue, integrated as a development and security portfolio companion tool.

## Structure

```text
.
├── AGENTS.md
├── README.md
├── LICENSE
├── docs/
│   ├── architecture.md
│   ├── gpu-setup.md
│   └── troubleshooting.md
├── examples/
│   ├── agent-session.md
│   └── code-reading-demo.md
├── scripts/
│   ├── install_ollama.sh
│   ├── run_agent.sh
│   └── gpu_check.sh
└── system/
    └── ollama.service
```

When working in this repository:

- Check the existing documentation before creating or modifying content.
- Preserve the current structure. Follow the existing pattern when adding new documents.
- Do not add empty files or restructure existing content without a clear reason.
- Write documentation in clear Spanish; keep official product and tool names in their original form (Ollama, Continue, VS Code, etc.).
- Do not include credentials, API keys, personal data or sensitive identifiers.
- Distinguish between validated results and planned or pending work.

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

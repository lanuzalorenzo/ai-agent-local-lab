# Uso real de OpenCode para redactar una guía del repositorio

> **Estado:** Validado el uso del agente en esta máquina. No valida precios, planes ni el resto de métodos de instalación.

## 1. Metadatos

| Campo | Valor |
|---|---|
| **Fecha** | 2026-10-30 |
| **Tipo** | Uso real de herramienta |
| **Herramienta** | OpenCode `v2.1.4` |
| **Modelo** | `opencode-go/deepseek-v4.1-flash` (remoto, no local) |
| **Entorno** | Ubuntu 26.04.1 LTS, Linux 7.0.0-38-generic x86_64 |
| **Binario** | `~/.opencode/bin/opencode` |
| **Estado** | Validado (uso) |

## 2. Qué se ha ejecutado

Sesión interactiva de OpenCode abierta en este repositorio. La petición fue redactar una guía pública sobre OpenCode —qué es, instalación, uso básico y gratis frente a pago—, enlazarla desde los índices y contrastar los datos con la documentación oficial.

Comandos ejecutados en la sesión:

```bash
opencode --version
# opencode v2.1.4

command -v opencode
# ~/.opencode/bin/opencode

. /etc/os-release; echo "$PRETTY_NAME"
# Ubuntu 26.04.1 LTS

uname -srm
# Linux 7.0.0-38-generic x86_64
```

Dentro de la sesión, el agente:

- leyó `AGENTS.md`, `README.md`, `docs/README.md` y las guías existentes;
- consultó la documentación oficial de OpenCode V2 (introducción, modelos, proveedores, precios de Console y Go, TUI);
- creó `docs/guias/opencode-desde-cero.md`;
- añadió el enlace en `README.md` y en `docs/README.md`;
- comprobó que los enlaces locales del documento resuelven a archivos existentes.

## 3. Artefactos

| Artefacto | Descripción |
|---|---|
| `docs/guias/opencode-desde-cero.md` | Guía completa, 2.291 palabras; SHA-256 `e88ae3a3bd4a62cb6738e5aeee8f669255c845a40e781cac331f2b6a7384ebef` en el momento del registro |
| `README.md` | Fila añadida en la tabla de documentos |
| `docs/README.md` | Fila en la tabla de guías y entrada en navegación rápida |

## 4. Qué valida y qué no

| Pregunta | Estado |
|---|---|
| ¿OpenCode arranca y opera en este equipo? | Validado |
| ¿El agente lee el repositorio, consulta documentación y escribe archivos? | Validado |
| ¿Los enlaces locales del documento resuelven? | Validado |
| ¿Los precios y planes descritos son correctos? | Contrastado con la documentación oficial; sin compra ni verificación de facturación |
| ¿Funcionan `brew`, `npm`, los binarios de escritorio y Docker? | No medido |
| ¿Funciona con un modelo local de Ollama? | No medido en esta sesión |

## 5. Resultados

- La guía quedó redactada y enlazada, con 2.291 palabras.
- La instalación existente responde con `opencode v2.1.4`.
- La sesión usó un modelo remoto; no se ejecutó inferencia local.

## 6. Hallazgos y límites

- **H-1:** el uso real demuestra que la herramienta funciona en este equipo, no que las cifras de precios sigan vigentes. La guía lleva fecha de revisión y enlaces a la fuente.
- **H-2:** no se repitió la instalación en un equipo limpio. El binario ya estaba instalado.
- **H-3:** esta evidencia no cubre el camino local-first del repositorio. Para eso hace falta una prueba con Ollama y un modelo de código.
- **H-4:** la salida de un modelo no es determinista. Repetir la petición no produce el mismo texto, solo un resultado equivalente.

## 7. Qué no demuestra

- Que OpenCode sea mejor que otro cliente.
- Que el coste de una suscripción o de una API sea el adecuado para un uso concreto.
- Que el agente no cometa errores: la guía se revisó, pero no hay una evaluación sistemática de sus afirmaciones.
- Nada sobre seguridad de prompts ni sobre exposición de red.

## 8. Cómo reproducir

```bash
cd ai-agent-local-lab
opencode --version
opencode
```

Dentro de la sesión, pedir la guía y comprobar los enlaces:

```bash
grep -o '](\([^)]*\.md\))' docs/guias/opencode-desde-cero.md
```

La reproducción es funcional, no literal: el texto puede variar.

## 9. Siguiente paso

Repetir el flujo en un equipo limpio con el instalador oficial y registrar la instalación como evidencia aparte. Después, probar la misma guía con un modelo local servido por Ollama y anotar qué cambia en calidad y latencia.

# Validación de uso de OpenCode en este equipo

> **Estado:** Validado el uso de la herramienta en esta máquina. No valida precios, planes ni los demás métodos de instalación.
> **Corrección (2026-10-30, misma fecha):** la guía `docs/guias/opencode-desde-cero.md` se reescribió después de este registro. Ver la sección 10.

## 1. Metadatos

| Campo | Valor |
|---|---|
| **Fecha** | 2026-10-30 |
| **Tipo** | Uso real de la herramienta |
| **Herramienta** | OpenCode `v2.1.4` |
| **Modelo** | `opencode-go/deepseek-v4.1-flash` (remoto, no local) |
| **Entorno** | Ubuntu 26.04.1 LTS, Linux 7.0.0-38-generic x86_64 |
| **Binario** | `~/.opencode/bin/opencode` |
| **Estado** | Validado (uso) |

## 2. Qué se ejecutó

Se abrió una sesión interactiva de OpenCode en este repositorio. El objetivo era comprobar que la herramienta arranca, lee el repositorio, consulta documentación y escribe archivos. Como caso de uso se añadió una guía pública de OpenCode y se enlazó desde los índices del repositorio.

Comandos de comprobación del equipo:

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

Durante la sesión, OpenCode:

- leyó `AGENTS.md`, `README.md`, `docs/README.md` y las guías existentes;
- consultó la documentación oficial de OpenCode (introducción, modelos, proveedores, precios de Console y Go, TUI);
- creó `docs/guias/opencode-desde-cero.md`;
- añadió el enlace en `README.md` y en `docs/README.md`;
- comprobó que los enlaces locales de la guía apuntan a archivos existentes.

## 3. Artefactos

| Artefacto | Descripción |
|---|---|
| `docs/guias/opencode-desde-cero.md` | Versión registrada: 2.291 palabras; SHA-256 `e88ae3a3bd4a62cb6738e5aeee8f669255c845a40e781cac331f2b6a7384ebef` en el momento del registro |
| `README.md` | Fila añadida en la tabla de documentos |
| `docs/README.md` | Fila en la tabla de guías y entrada en navegación rápida |

## 4. Qué valida y qué no

| Pregunta | Estado |
|---|---|
| ¿OpenCode arranca y funciona en este equipo? | Validado |
| ¿La herramienta lee el repositorio, consulta documentación y escribe archivos? | Validado |
| ¿Los enlaces locales de la guía apuntan a archivos existentes? | Validado |
| ¿Los precios y planes descritos son correctos? | Contrastado con la documentación oficial; sin compra ni comprobación de facturación |
| ¿Funcionan `brew`, `npm`, los binarios de escritorio y Docker? | No medido |
| ¿Funciona con un modelo local de Ollama? | No medido en esta sesión |

## 5. Resultados

- La guía quedó escrita y enlazada, con 2.291 palabras en la versión registrada.
- La instalación existente responde con `opencode v2.1.4`.
- La sesión usó un modelo remoto; no se ejecutó inferencia local.

## 6. Hallazgos y límites

- **H-1:** el uso demuestra que la herramienta funciona en este equipo, no que las cifras de precios sigan vigentes. La guía lleva fecha de revisión y enlaces a la fuente.
- **H-2:** no se repitió la instalación en un equipo limpio. El binario ya estaba instalado.
- **H-3:** esta evidencia no prueba el flujo con modelo local. Para eso hace falta una prueba con Ollama y un modelo de código.
- **H-4:** la salida de un modelo no es determinista. Repetir la petición da un texto distinto, aunque equivalente.

## 7. Qué no demuestra

- Que OpenCode sea mejor que otro cliente.
- Que el coste de una suscripción o de una API sea adecuado para un uso concreto.
- Que la herramienta no cometa errores: la guía se revisó, pero no hay una evaluación sistemática de sus afirmaciones.
- Nada sobre seguridad de prompts ni sobre exposición de red.

## 8. Cómo reproducir

```bash
cd lab-ia-aprendizaje
opencode --version
opencode
```

Dentro de la sesión, pide el documento y comprueba los enlaces:

```bash
grep -o '](\([^)]*\.md\))' docs/guias/opencode-desde-cero.md
```

La reproducción es funcional, no literal: el texto puede variar.

## 9. Siguiente paso

Repetir el flujo en un equipo limpio con el instalador oficial y registrar esa instalación como evidencia aparte. Después, probar el mismo caso con un modelo local servido por Ollama y anotar qué cambia en calidad y latencia.

## 10. Nota de revisión (mismo día)

Registro original sin cambios en sus datos. Después se reescribió la guía `docs/guias/opencode-desde-cero.md`:

- El SHA-256 y el recuento de palabras de la sección 3 corresponden a la versión registrada, no a la vigente.
- La versión vigente no incluye precios ni planes, así que el punto de la sección 4 sobre precios ya no le afecta.
- El punto H-3 sigue vigente: esta evidencia no prueba el flujo local.
- Desde esta fecha, el trabajo diario usa OpenCode Go y el flujo local queda para datos que no pueden salir de la red (ver bitácora, entrada 08). La prueba con Ollama del paso siguiente sigue siendo necesaria para ese caso.

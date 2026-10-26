# Guía para agentes: ai-agent-local-lab

> Si llegas nuevo: el contrato de contenido es el de `portfolio-ciberseguridad-lorenzo/AGENTS.md`. Este archivo añade convenciones del lab de IA.

Lab local de agentes de IA con Ollama y Continue, integrado como herramienta de desarrollo/seguridad del portfolio. Estructura: ver `README.md` y `docs/`.

## Convenciones

- Sin rótulos de registro; español claro y directo; nombres oficiales de productos.
- Estados explícitos: Validado · Parcial · Runbook preparado · Diseño · Pendiente.
- README de práctica 240–310 palabras; `informe.md` solo si sostiene; `runbook.md` solo reejecutable; `bitacora/` solo hechos nuevos.
- Evidencia vs hallazgo: hallazgo no es PASS; tabla con resultado/gravedad y aparte qué se corrigió/recomendó.
- Alcance local-first; sin rankings/noticias/comparativas sin medición propia.
- En docs de evaluación de IA, separar diseño/expectativas de resultados medidos; no presentar umbrales como resultados.
- No exponer Ollama a Internet; documentar firewall, TLS y auth.
- Usar `ollama.lab.local` u otro placeholder, nunca IP interna real.
- Lab independiente del lab final de ciberseguridad; si se enlaza desde el portfolio, alcance y evidencias separados.
- Decisiones/problemas/RCA en `docs/referencia/bitacora-decisiones-aprendizaje.md`; mantener hoja de ruta (GGUF/CUDA, seguridad de red, integración de cliente, RAG) actualizada allí.

## Commits

Formato: `type(scope): imperative summary in English`. Scopes: `docs`, `examples`, `scripts`, `config`, `repo`. Tipos: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`. Asunto imperativo, conciso, en inglés. Commit/push con autorización por lote.
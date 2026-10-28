# Guía para agentes: ai-agent-local-lab

Laboratorio local de agentes de IA con Ollama y Continue, usado como herramienta de desarrollo y seguridad del portfolio público. Estructura y guías: `README.md` y `docs/`.

## Convenciones

- Alcance local-first: nada de rankings, noticias ni comparativas sin medición propia.
- No expongas Ollama a Internet; documenta firewall, TLS y autenticación.
- Usa `ollama.lab.local` u otro placeholder, nunca una IP interna real.
- README de práctica de 240–310 palabras; `informe.md` solo si sostiene el contenido; `runbook.md` solo si es reejecutable; `bitacora/` solo con hechos nuevos.
- En evaluación de IA, separa diseño y expectativas de resultados medidos; no presentes umbrales como resultados.
- Lab independiente del lab final de ciberseguridad: si se enlaza desde el portfolio, el alcance y las evidencias van separados.
- Decisiones, problemas y RCA en `docs/referencia/bitacora-decisiones-aprendizaje.md`; mantén allí la hoja de ruta (GGUF/CUDA, seguridad de red, integración de cliente, RAG).
- Sin secretos, credenciales ni datos personales.

## Contrato editorial

Español claro y directo, sin rótulos de registro. Estados explícitos (Validado · Parcial · Runbook preparado · Diseño · Pendiente). Evidencia y hallazgo van separados: un hallazgo no es un PASS. El contrato completo está en [portfolio-ciberseguridad-lorenzo](https://github.com/lanuzalorenzo/portfolio-ciberseguridad-lorenzo/blob/main/AGENTS.md).

## Commits

Formato: `type(scope): imperative summary in English`. Scopes: `docs`, `examples`, `scripts`, `config`, `repo`. Tipos: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`. Asunto imperativo, conciso y en inglés.

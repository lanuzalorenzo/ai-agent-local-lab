# Equipo de agentes (diseño)

> **Estado:** Diseño. No hay implementación ni ejecuciones. Queda aplazado hasta cerrar la fase 4 de la [hoja de ruta de seguridad](../referencia/hoja-de-ruta-seguridad-asistentes.md).

## Qué es

Un equipo de agentes es varios agentes con papeles distintos que trabajan en cadena. Por ejemplo: uno propone un diseño, otro escribe el código, otro revisa lo escrito y otro redacta la documentación. Cada agente recibe instrucciones propias para su papel, en lugar de una sola instrucción general para todo.

## Qué se buscaría

- **Papeles claros.** Cada agente hace una cosa y se puede revisar por separado.
- **Menos trabajo manual en tareas repetitivas.** Por ejemplo, documentar un cambio o comprobar que los enlaces funcionan.

## Qué lo frena

- Cada agente añade llamadas al modelo, y con ellas, tiempo y consumo.
- Si un agente se equivoca, el error pasa al siguiente. Hay que definir qué se revisa y por quién.
- Sin evidencia de que un equipo de agentes sea mejor que uno solo, no tiene sentido montarlo.

## Cuándo se retomaría

Cuando haya una tarea concreta que se repita con frecuencia y un criterio para medir si el equipo la hace mejor que un agente solo. Hasta entonces, se trabaja con un solo agente y reglas claras en el `AGENTS.md` de cada proyecto.

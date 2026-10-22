# Continuidad de sesiones con OpenCode

> **En fácil:** un agente no recuerda lo que hiciste ayer. Para que no se pierda el hilo, el estado se guarda en archivos versionados y el agente los lee al arrancar. Así puedes cambiar de modelo, de máquina o cerrar la sesión sin volver a empezar.

> **Estado:** patrón documentado a partir del uso. No es una evaluación comparativa de modelos ni una garantía de que cualquier agente lo aplique igual.
>
> **Alcance:** OpenCode como cliente de agentes. El patrón es aplicable a otros clientes que permitan comandos personalizados y lectura de archivos.

## 1. El problema

Una sesión de agente es efímera:

- al cerrar el chat se pierde el hilo;
- al cambiar de modelo o de agente, el contexto no viaja;
- las sesiones largas se compactan y pierden detalle;
- si el estado vive solo en la conversación, no se puede auditar ni recuperar.

La continuidad no debe depender de la memoria del modelo; debe depender de archivos versionados.

## 2. Principio: el estado vive en archivos

| Artefacto | Función | Cuándo se actualiza |
|---|---|---|
| Puntero de continuidad | Dice qué toca ahora y cuál es la siguiente acción | Al cerrar cada sesión |
| Brief de sesión | Objetivo, alcance, decisiones, evidencias, pendientes y commits | Al cerrar cada sesión |
| Diario | Tres líneas: qué hice, qué no entendí, qué sigue | Al cerrar cada sesión |
| Mapa de estado | Estado resumido de cada frente y su siguiente acción | Cuando cambia un frente |
| Git | Historial verificable de lo publicado | En cada commit |

Regla: el agente lee estos archivos al arrancar, comprueba Git y **propone** el siguiente paso antes de tocar nada. Si el puntero y el estado real no coinciden, gana el estado real y se corrige el puntero.

## 3. Comandos personalizados

OpenCode descubre comandos de proyecto en `.opencode/commands/*.md`. Cada archivo tiene:

- un frontmatter con `description`;
- un cuerpo que es una plantilla de prompt;
- opcionalmente `$ARGUMENTS`, que inyecta el texto que escribas tras el comando.

Ejemplo mínimo de `/continuar`:

```md
---
description: Retoma el trabajo desde el plan y el último brief
---

Continúa el trabajo. Lee el puntero de continuidad, el plan y el brief más
reciente. Revisa el estado de Git. Propón el siguiente paso antes de tocar nada.

Contexto adicional: $ARGUMENTS
```

Ejemplo mínimo de `/cerrar-sesion`:

```md
---
description: Cierra la sesión con un brief de continuidad
---

Cierra esta sesión. Revisa el trabajo y Git. Escribe un brief con objetivo,
decisiones, evidencias, pendientes y siguiente paso. Añade tres líneas al diario.
Actualiza el puntero. No hagas commit ni push sin autorización explícita.
```

Un comando **no es código**: es una instrucción. Cualquier modelo puede ejecutarlo, pero el resultado depende de que el modelo lea archivos, use herramientas y respete los límites.

## 4. Estructura mínima

```text
proyecto/
├── .opencode/
│   └── commands/
│       ├── continuar.md
│       └── cerrar-sesion.md
├── docs/
│   ├── plan.md
│   └── sessions/
│       └── YYYY-MM-DD-tema.md
└── diary.md
```

No hace falta que se llamen así, pero cada archivo debe tener una responsabilidad única: el plan no guarda el detalle de la sesión y el brief no repite el plan.

## 5. Qué debe hacer `/continuar`

1. Leer el protocolo de sesión y el puntero de continuidad.
2. Leer el brief más reciente.
3. Comprobar el mapa de estado y, si existe, ejecutar el script de consistencia.
4. Revisar el estado de Git de los repos implicados.
5. Proponer el siguiente paso y esperar confirmación.

Un `/continuar` que empieza editando archivos sin proponer nada está mal diseñado.

## 6. Qué debe hacer `/cerrar-sesion`

1. Revisar el trabajo realizado y Git.
2. Escribir o actualizar el brief.
3. Actualizar el plan si cambió una decisión.
4. Añadir tres líneas al diario.
5. Actualizar el mapa de estado si cambió un frente.
6. Recomendar si la siguiente tarea merece sesión nueva.
7. No hacer commit ni push sin autorización explícita.

## 7. Versionar los comandos

`.opencode/` suele quedar fuera de Git. Si los comandos solo existen en el disco local, se pierden al cambiar de máquina.

Patrón recomendado:

1. Guardar la copia canónica en un repositorio versionado, por ejemplo `tools/opencode/commands/`.
2. Sincronizar al workspace con un script idempotente.
3. Añadir un modo `--check` que compare y falle si hay diferencias.
4. Editar siempre la copia versionada, nunca la del workspace.

```bash
# copia
tools/sync-opencode-commands.sh

# comprobación, sin copiar
tools/sync-opencode-commands.sh --check
```

## 8. Límites y errores frecuentes

- **No hereda la conversación.** Una sesión nueva relee archivos; no recuerda el chat anterior.
- **Depende del modelo.** Un modelo sin uso de herramientas puede ignorar los pasos o inventar el estado.
- **Depende de permisos.** Si el agente no puede leer el plan o el brief, el comando no sirve.
- **Depende del directorio.** Los comandos de proyecto se descubren desde la raíz del workspace. Si abres una subcarpeta, puede que no aparezcan.
- **Un estado mentiroso produce un agente confiado.** Si el puntero no se actualiza al cerrar, el siguiente agente partirá de una ficción.
- **No sustituye a Git.** El brief explica el porqué; el commit prueba el qué.

## 9. Checklist para reproducirlo

- [ ] Elegir los archivos de estado y su responsabilidad.
- [ ] Escribir el protocolo de arranque y cierre.
- [ ] Crear los comandos con `description` y `$ARGUMENTS`.
- [ ] Versionar la copia canónica.
- [ ] Añadir script de sincronización y comprobación.
- [ ] Probar en una sesión nueva y con otro modelo.
- [ ] Verificar que el agente propone antes de actuar.
- [ ] Verificar que no hace commit ni push sin autorización.

## 10. Qué no publicar

Los comandos y los briefs pueden contener rutas internas, nombres de proyectos privados, decisiones personales o datos de clientes. Antes de publicar:

- elimina rutas absolutas y nombres de repos privados;
- sustituye ejemplos reales por ejemplos genéricos;
- no incluyas prompts privados, tokens ni direcciones IP internas;
- revisa que el repositorio público no enlace al privado.

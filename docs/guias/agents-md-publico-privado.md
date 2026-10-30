# AGENTS.md: qué se publica y qué no

> **Estado:** Diseño aplicado en este repositorio. La plantilla no se ha probado en otros proyectos.

Un agente de código lee instrucciones antes de tocar nada: cómo está organizado el proyecto, qué comandos sirven para comprobar un cambio y qué no se debe tocar. Esas instrucciones pueden escribirse en el propio chat, cada vez, o guardarse en un archivo del proyecto. Este documento explica el segundo camino y dónde poner el límite entre lo público y lo privado.

El archivo se llama `AGENTS.md`. Lo leen varias herramientas, entre ellas OpenCode, que lo carga al abrir un proyecto. En Continue se adjunta a mano con `@AGENTS.md`.

## 1. Por qué en un archivo y no en el chat

Escribir las reglas en cada conversación tiene tres problemas:

- Se repiten, y cada vez pueden salir distintas.
- No queda rastro de qué regla se usó.
- Cambiar de herramienta obliga a copiarlas otra vez.

Un archivo en el repositorio se versiona como cualquier otro código: se revisa, se cambia con un commit y se puede recuperar.

## 2. Tres niveles, tres lugares

Las instrucciones no van todas en el mismo sitio. Cada nivel tiene un público distinto.

| Nivel | Dónde vive | Qué contiene | Visibilidad |
|---|---|---|---|
| **Modelo** | Definición del modelo (`Modelfile`) | Solo el papel del asistente y la orden de leer el `AGENTS.md` del proyecto | Público |
| **Proyecto** | `AGENTS.md` en la raíz del repositorio | Convenciones técnicas, comandos de comprobación, qué no tocar | Público, sin datos personales ni de infraestructura |
| **Persona** | Espacio privado de notas, fuera de cualquier repositorio | Preferencias personales, rol profesional, clientes, planes, contexto de trabajo | Privado. Nunca se publica |

Regla práctica: si una instrucción sirve a cualquier persona que quiera ordenar su proyecto, va en el nivel de proyecto. Si solo te sirve a ti, va en el nivel personal.

## 3. El filtro antes de publicar

Antes de subir un `AGENTS.md` o un `Modelfile`, recorre estas preguntas:

| Si el texto… | Qué hacer |
|---|---|
| Dice quién eres, tu cargo, tu situación laboral o tus planes | Quítalo. Va al nivel personal |
| Incluye IPs, nombres de host, usuarios, puertos concretos o rutas personales | Sustitúyelo por marcadores: `ollama.lab.local`, `usuario`, `192.0.2.10` (direcciones de documentación) |
| Nombra proyectos privados, notas internas o carpetas de tu equipo | Quítalo o sustitúyelo por una descripción genérica |
| Habla de clientes, datos de personas o contratos | Quítalo. Nunca va a un repositorio público |
| Contiene claves, tokens o contraseñas | Quítalos y rótalos. Las claves nunca van en un archivo de instrucciones |
| Sirve para cualquier proyecto parecido | Va bien en público |

Antes de subir el cambio, busca patrones sospechosos. Si encuentra algo, revisa cada línea:

```bash
grep -rniE "password|passwd|token|api[_-]?key|secret|BEGIN .*PRIVATE" AGENTS.md config/
grep -rnE "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" AGENTS.md config/
```

El comando no detecta todo. Es una ayuda, no una garantía: la revisión humana es la que decide.

## 4. Plantilla pública

Esta plantilla sirve de punto de partida. Sustituye los marcadores por datos de tu proyecto y borra las secciones que no apliquen.

```markdown
# Guía para agentes: <nombre del proyecto>

Proyecto de <qué hace, en una frase>. Estructura: `README.md` y `docs/`.

## Convenciones

- <Idioma de los textos y de los mensajes de commit>.
- <Formato de los commits, por ejemplo `tipo(ámbito): resumen en imperativo`>.
- <Nombres de carpetas o archivos que no se deben cambiar sin avisar>.

## Verificación

- Antes de dar un cambio por terminado, ejecuta: `<comando de tests>`.
- Si cambias <algo sensible>, ejecuta también: `<comando de comprobación>`.

## Límites

- No añadas secretos, claves ni datos personales.
- No cambies <archivos o carpetas protegidos> sin preguntar.
- No hagas commit ni push sin que te lo pidan.
```

## 5. Cómo se usa en este repositorio

- **El modelo** (`config/Modelfile.portfolio-agent`) fija un papel genérico y ordena leer el `AGENTS.md` del proyecto. No contiene ningún rol personal.
- **El proyecto** tiene su `AGENTS.md` con las convenciones del repositorio.
- **El nivel personal** no está en el repositorio. Si necesitas que un asistente lo use, cárgalo en tu propio entorno, no en el repositorio público.

Esto hace que el archivo del proyecto sea útil para cualquiera que lo lea, y que lo privado no tenga que viajar con él.

## 6. Qué no hace un AGENTS.md

Un archivo de instrucciones es una **petición**, no una barrera. El modelo puede ignorarla, y los resultados de [robustez de prompts](../referencia/prompt-robustness-testing.md) lo muestran: un prompt de sistema que ordena no obedecer órdenes escondidas no bastó en las pruebas de ese modelo.

Por eso, las reglas que importan de verdad se aplican fuera del modelo: permisos de las herramientas, revisión de los cambios antes de aceptarlos y control de los datos que salen del equipo. El archivo ayuda a que el agente trabaje bien. Los permisos son los que impiden que trabaje mal.

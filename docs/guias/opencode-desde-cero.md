<img src="../../assets/iconos/ia-local.svg" width="64" alt="Icono del laboratorio de IA local">

# OpenCode desde cero

> Para quién: si nunca has usado un agente de código en la terminal. No hace falta saber programar a fondo.

Esta guía cuenta cómo llegamos a OpenCode, qué es y cómo empezar. Está escrita desde el uso, no desde el manual.

## Cómo llegamos aquí

Todo empezó por los límites.

Copilot se nos quedaba corto cada mes. Antigravity se reseteaba cada semana, pero a medida que los proyectos crecían, se agotaba antes de que llegara el reseteo.

Probamos OpenRouter con Continue en VS Code. Había modelos gratuitos, pero no eran suficientes para trabajar a diario.

Después encontramos OpenCode. Intentamos usarlo con Ollama en local. Funcionaba, pero montarlo y ajustar el rendimiento costaba mucho tiempo.

Pasamos a OpenCode Console y nos convenció, hasta que el proyecto creció y se quedaron sin créditos. Mientras tanto probamos a conectar Antigravity para seguir trabajando con OpenCode. Fue caótico: no nos dejaba trabajar bien. Acabamos en OpenCode Go, que es lo que usamos hoy. En límites y en disponibilidad de modelos ha funcionado mejor que todo lo anterior.

La lección que nos dejó el camino: el límite no lo marca solo la herramienta, sino cuánto trabajas. Y el modelo se puede cambiar sin cambiar la herramienta.

Las opciones, los planes y las condiciones cambian. Mira la [documentación de proveedores](https://opencode.ai/v2/docs/providers/) antes de decidir.

## Qué es OpenCode

OpenCode es un agente de programación de código abierto que funciona en la terminal. También hay aplicación de escritorio y versión web.

Le pides cosas en lenguaje normal. Lee los archivos de tu proyecto, propone cambios y los aplica si se lo permites. Tú decides qué se queda.

```bash
cd ~/proyectos/mi-api
opencode
```

Para empezar, pide algo que no cambie nada:

```text
Explica cómo funciona la autenticación de este proyecto y señala lo que veas frágil
```

Piensa en el agente como el mecánico y en el modelo como el motor. Puedes cambiar de motor sin cambiar de taller.

## Por qué no un asistente dentro del editor

Un asistente de editor es cómodo para empezar. OpenCode tiene otras ventajas:

- Funciona en la terminal y en servidores. Puedes usarlo aunque el modelo esté en otra máquina.
- Cambias de modelo sin cambiar de forma de trabajar.
- Las reglas del proyecto viven en archivos. Se leen, se revisan y se guardan en Git.
- Es de código abierto.

El precio es que hay más que aprender. Si solo quieres autocompletar mientras escribes, un asistente de editor basta.

## Local o remoto

Cada opción tiene su sitio.

**Modelo local** (con Ollama, en tu equipo o en un servidor):

- El código no sale de tu red.
- No dependes de límites de un proveedor.
- Cuesta tiempo montarlo y ajustarlo, y el rendimiento depende de tu hardware.

**Modelo remoto** (un proveedor conectado a OpenCode):

- Tiene más capacidad y menos problemas de límites para el trabajo diario.
- Tu código viaja al proveedor, así que antes revisa su política de privacidad.

Nuestra regla práctica: lo que no debe salir de tu red, va en local. Para el trabajo diario, un proveedor con buenos límites, siempre que su política te valga.

## Instalación

Necesitas Linux, macOS o Windows y un proyecto en disco. En Windows, usa el binario o la aplicación de escritorio.

La forma recomendada:

```bash
curl -fsSL https://opencode.ai/v2/install | bash
```

Comprueba que funciona:

```bash
opencode --version
```

También hay instalación con Homebrew o npm, y aplicación de escritorio. Para la versión web, `opencode pair` genera un enlace de un solo uso.

## Conectar un modelo

### Opción A: Ollama en local

Crea un archivo `opencode.json` en la raíz del proyecto:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "model": "ollama/qwen2.5-coder:7b",
  "providers": {
    "ollama": {
      "package": "@opencode/ai/providers/openai-compatible",
      "settings": {
        "baseURL": "http://ollama.lab.local:11434/v1"
      },
      "models": {
        "qwen2.5-coder:7b": {
          "name": "Qwen 2.5 Coder 7B (local)"
        }
      }
    }
  }
}
```

Cambia `ollama.lab.local` por el nombre de tu servidor. Ollama debe ser accesible solo desde tu red. No publiques el puerto 11434 en Internet. La [guía de despliegue en Ubuntu Server](server-deployment-ubuntu-ollama.md) explica el firewall.

### Opción B: un proveedor remoto

Dentro de OpenCode escribe `/connect`, elige el proveedor y sigue los pasos para iniciar sesión o pegar tu clave. Luego `/models` te muestra qué puedes usar.

En OpenCode Go, por ejemplo, el modelo Claude Haiku 5.5 se identifica como `opencode-go/claude-haiku-5-5`. Si quieres que sea el de uso habitual, ponlo en `opencode.json`:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "model": "opencode-go/claude-haiku-5-5"
}
```

La lista de modelos cambia. Antes de enviar código de un cliente, revisa la política de privacidad del proveedor y la sección de privacidad de tu cuenta, porque algunos modelos la tienen configurada de forma distinta.

No pegues claves en el chat ni en `opencode.json`. Usa `/connect` o variables de entorno.

## Tu primera sesión

1. Entra en un proyecto pequeño y ejecuta `opencode`.
2. Escribe `/models` y comprueba que aparece el modelo que quieres.
3. Pide una lectura, como el ejemplo de arriba.
4. Crea una rama para no tocar tu trabajo: `git switch -c prueba-opencode`.
5. Pide un cambio pequeño, como corregir una errata.
6. Revisa el cambio. Si no te gusta, escribe `/undo`.

Deshacer es parte de aprender a usar un agente. En una rama, no pasa nada si algo sale mal.

## Lo que usarás a diario

- `@` y el nombre de un archivo para adjuntarlo al mensaje.
- `!` delante de un mensaje para ejecutar un comando de terminal, por ejemplo `!git status`.
- `/` para ver los comandos disponibles.
- `/new` para empezar una conversación limpia.
- `/models` para cambiar de modelo.
- `/undo` para deshacer el último cambio.

## Las reglas del proyecto

Las instrucciones de cada proyecto van en un archivo llamado `AGENTS.md`. Ahí dices cómo se organiza el código, cómo se comprueba que un cambio funciona y qué no se toca. El agente lo lee al empezar.

Lo más útil de este archivo es que queda guardado en el proyecto, como cualquier otro código. Una guía futura explicará cómo lo organizamos aquí.

## Permisos

Un agente puede leer archivos, ejecutar comandos y modificar el repositorio. Antes de dejarlo trabajar solo:

- Revisa qué puede hacer sin preguntarte.
- Trabaja en una rama, nunca en `main`.
- Mira el cambio antes de aceptarlo.
- No le des claves ni datos personales que no necesite.
- Si el modelo es remoto, asume que lo que lee puede salir de tu equipo.

## Errores comunes

- **Pedir una tarea enorme de golpe.** El agente se pierde y gasta contexto. Divide el trabajo y adjunta los archivos que importan.
- **No tener `AGENTS.md`.** El agente inventa estilo y comandos.
- **Trabajar sobre `main`.** Mezclas pruebas con trabajo real.
- **Pegar claves en el chat.** Quedan en el historial.
- **Usar un modelo local demasiado pequeño.** Falla al usar herramientas y da respuestas incoherentes.

## Dónde seguir

Documentación oficial:

- Instalación: <https://opencode.ai/v2/docs/>
- Proveedores: <https://opencode.ai/v2/docs/providers/>
- Configuración: <https://opencode.ai/v2/docs/config/>
- Permisos: <https://opencode.ai/v2/docs/permissions/>
- Problemas: <https://opencode.ai/v2/docs/troubleshooting/>

En este repositorio:

- [Continuidad de sesiones con OpenCode](opencode-session-continuity.md): cómo no perder el contexto entre sesiones.
- [Inferencia local frente a cloud](local-vs-cloud.md): criterios para decidir dónde corre el modelo.
- [OpenCode frente a VS Code y Antigravity](../referencia/opencode-vs-vscode-antigravity.md): comparación por privacidad, coste y control.

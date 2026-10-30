<img src="../../assets/iconos/ia-local.svg" width="64" alt="Icono del laboratorio de IA local">

# OpenCode desde cero: qué es, cómo se instala y cuánto cuesta

> **Estado:** Validado el uso real de OpenCode en esta máquina ([evidencia](../evidencias/2026-10-30-opencode-uso-real/README.md)). Parcial en el resto: precios y planes contrastados con la documentación oficial, sin compra ni instalación limpia. Los precios, modelos y cuotas cambian: comprueba siempre la fuente enlazada antes de decidir.
>
> **Para quién:** alguien que nunca ha usado un agente de código en la terminal. No requiere saber programar para entender la guía, aunque se aprovecha más si tienes un proyecto a mano.

## 1. Qué es OpenCode

OpenCode es un agente de programación de código abierto que se ejecuta en la terminal. Le hablas en lenguaje natural, lee los archivos de tu proyecto, propone cambios y los aplica con las herramientas que le hayas dado: leer, editar, buscar, ejecutar comandos, consultar la web o llamar a servidores MCP.

No es un autocompletado ni un chat dentro de un editor. Es un programa que trabaja sobre tu directorio:

```bash
cd ~/proyectos/mi-api
opencode
```

A partir de ahí escribes lo que quieres, por ejemplo:

```text
Explica cómo funciona la autenticación de este proyecto y señala los puntos débiles
```

Y ves el razonamiento, las lecturas de archivos y los cambios propuestos. Tú decides qué se acepta.

### La idea que hay detrás

OpenCode separa dos piezas:

- **El agente** (el programa): decide qué hacer, pide herramientas y muestra resultados.
- **El modelo** (el motor): el modelo de lenguaje que razona. Puede ser local o remoto, y lo eliges tú.

Esa separación es la parte importante: el mismo OpenCode funciona con un modelo gratuito en tu portátil, con el modelo que ya pagas en otra suscripción o con una API de pago. El agente no te obliga a un proveedor.

### Qué ofrece

| Capacidad | Para qué sirve |
|---|---|
| Sesiones | Cada conversación conserva su contexto; se pueden recuperar, reanudar y separar por tarea |
| Lectura y edición del proyecto | Abre archivos por ruta o con `@`, aplica cambios y muestra el diff |
| Terminal integrada | Ejecuta comandos con `!` y devuelve la salida a la conversación |
| Agentes | Perfiles con instrucciones y herramientas distintas (por ejemplo, uno de revisión y otro de implementación) |
| Instrucciones del proyecto | `AGENTS.md` fija convenciones, estructura y límites para que el agente no improvise |
| Permisos | Controlan qué herramientas y comandos puede ejecutar sin preguntar |
| MCP y skills | Conecta servicios externos y carga procedimientos especializados |
| Plugins | Extiende el comportamiento del servidor o de la interfaz |
| API y SDK | Permite integrar OpenCode en otros programas |
| Interfaces | Terminal, aplicación de escritorio, web y Docker |

### Qué no es

- No es un sustituto de revisar el código. Un agente puede equivocarse con seguridad; el diff y los tests siguen siendo tuyos.
- No es una herramienta de privacidad por sí sola. Si usas un modelo remoto, tu código viaja al proveedor. La privacidad depende de dónde ejecutes el modelo.
- No es un editor. Convive con VS Code, Neovim o el que uses; no lo reemplaza.

## 2. Antes de instalar: decide dónde razona el modelo

Esta decisión explica casi todo el resto: coste, privacidad, velocidad y calidad.

| Opción | Coste | Privacidad | Cuándo tiene sentido |
|---|---|---|---|
| Modelo local (Ollama, LM Studio, vLLM) | 0 en software; pagas tu hardware y la electricidad | Alta: el código no sale de tu red | Privacidad estricta, aprendizaje, equipos con GPU |
| Plan que ya pagas (ChatGPT Plus/Pro, GitHub Copilot) | Lo que ya pagas | Según el proveedor | Ya tienes suscripción y quieres aprovecharla |
| Modelos gratuitos de OpenCode | 0, con límites y disponibilidad variable | Según el proveedor | Probar sin tarjeta |
| API key propia (OpenAI, Anthropic, Google, OpenRouter…) | Pago por uso | Según el proveedor | Control de modelo y presupuesto por consumo |
| OpenCode Console (pago por uso) | Créditos | Según el proveedor elegido | Un solo proveedor para varios modelos |
| OpenCode Go (suscripción) | Desde 10 USD/mes | Según el proveedor elegido | Uso intensivo con coste predecible |

Regla práctica: empieza gratis con un modelo local si tu equipo lo aguanta; si no, prueba los modelos gratuitos; si el trabajo es diario, compara el coste real de una API con la suscripción.

## 3. Instalación

### Requisitos

- Linux, macOS o Windows.
- Node.js solo si instalas por npm; el instalador y los binarios no lo necesitan.
- Un proyecto en disco y permisos de escritura sobre él.
- Salida a Internet si el modelo es remoto. Con un modelo local, no hace falta para razonar.

### Terminal (recomendado)

```bash
curl -fsSL https://opencode.ai/v2/install | bash
```

Alternativas:

```bash
brew install anomalyco/tap/opencode-v2   # macOS/Linux con Homebrew
npm install -g @opencode/cli             # requiere Node.js
```

También hay binarios sueltos para Linux, macOS y Windows en la página de instalación. Los gestores de paquetes de Windows no están soportados; usa el binario o la aplicación de escritorio.

Comprueba que quedó instalado:

```bash
opencode --version
```

### Aplicación de escritorio

Hay builds para macOS, Windows y Linux (`.deb`, `.rpm`, `AppImage`). Es la misma base con interfaz gráfica; útil si la terminal te frena al principio.

### Web y Docker

- Web: `opencode pair` abre un enlace local de un solo uso para conectar la interfaz web.
- Docker: `ghcr.io/anomalyco/opencode:2.0.0` (usa etiquetas versionadas).

### Primer arranque

```bash
cd ~/proyectos/mi-api
opencode
```

Dentro:

1. `/connect` para enlazar un proveedor. Si eliges un modelo local, normalmente no hay que conectar nada.
2. `/models` para elegir modelo. La lista solo muestra los disponibles en ese proyecto.
3. Escribe tu primera petición y pulsa Enter.

Si no quieres abrir la interfaz interactiva:

```bash
opencode run --model ollama/qwen2.5-coder:7b "Resume la estructura del proyecto"
```

## 4. Lo mínimo para no perderse

| Acción | Cómo |
|---|---|
| Adjuntar un archivo | Escribe `@` y busca; también `@ruta/archivo#20-45` para un rango |
| Ejecutar un comando | Empieza el mensaje con `!`, por ejemplo `!git status` |
| Ver comandos | `/` y filtra |
| Nueva sesión | `/new` o `Ctrl+X`, luego `N` |
| Recuperar sesión | `/sessions` o `Ctrl+X`, luego `L` |
| Cambiar de modelo | `/models` o `Ctrl+X`, luego `M` |
| Cambiar de agente | `/agents` o `Shift+Tab` |
| Deshacer | `/undo` o `Ctrl+X`, luego `U` |
| Rehacer | `/redo` o `Ctrl+X`, luego `R` |
| Salto de línea | `Shift+Enter`, `Ctrl+J` o `Alt+Enter` |
| Pregunta rápida sin ensuciar el hilo | `/btw ¿por qué falló el test del paso 2?` |
| Paleta completa | `Ctrl+P` |

La tecla líder por defecto es `Ctrl+X`. Todo esto es configurable en `~/.config/opencode/cli.json`, que guarda preferencias de terminal y no se mezcla con la configuración del proyecto.

### Tres archivos que conviene conocer

- **`AGENTS.md`**: instrucciones del proyecto. Convenciones, comandos de verificación, qué no tocar. Es lo que evita que el agente invente estilo o estructura.
- **`opencode.json` o `opencode.jsonc`**: configuración del proyecto: modelo por defecto, agentes, permisos, MCP, plugins.
- **`~/.config/opencode/opencode.json`**: configuración global del usuario, para lo que quieres en todos los proyectos.

La configuración se recarga al guardar; no hace falta reiniciar.

### Permisos: el detalle que separa una demo de un incidente

Un agente puede leer archivos, ejecutar comandos y modificar el repositorio. Antes de dejarlo trabajar solo:

- Revisa qué herramientas tiene habilitadas y cuáles piden confirmación.
- Trabaja en una rama, no en `main`.
- Mira el diff antes de aceptar.
- No le des claves ni datos personales que no necesite.
- Si el modelo es remoto, asume que lo que lee puede salir de tu equipo.

## 5. Gratis y de pago, sin marketing

### Lo que es gratis siempre

- **El programa.** OpenCode es código abierto. Todas las interfaces y funciones principales están disponibles sin licencia de pago.
- **Modelos locales.** Con Ollama, LM Studio o vLLM en tu equipo, el coste de software es cero. Pagas hardware y luz. En este repositorio hay un [runbook de despliegue](server-deployment-ubuntu-ollama.md) y una guía de [inferencia local frente a cloud](local-vs-cloud.md).
- **Traer tu propia clave.** Si ya tienes API de un proveedor, la conectas y pagas solo su consumo. OpenCode no añade margen.
- **Aprovechar un plan existente.** ChatGPT Plus/Pro se puede enlazar con «Sign in with ChatGPT» y GitHub Copilot con su inicio de sesión; el uso cuenta contra tu plan. Requiere que el plan tenga acceso a los modelos que quieras usar.

### Modelos gratuitos de OpenCode

OpenCode Console publica una lista de modelos con precio de entrada cero. En la fecha de esta guía incluye, entre otros, `big-pickle`, `glm-5.3-flash-free`, `deepseek-v4.1-flash-free`, `beam-free`, `flint-40b-free`, `mimo-v2.6-flash-free` y varios Nemotron. Son útiles para probar sin tarjeta.

Dos avisos:

- Son ofertas de tiempo limitado, con regiones restringidas en algunos casos y disponibilidad variable. No los uses como base de un flujo de trabajo crítico.
- Para usarlos hace falta una cuenta de OpenCode Console; sin sesión, el proveedor `opencode` no aparece.

Además, algunos proveedores externos tienen cuota gratuita propia (Google AI Studio, OpenRouter con modelos gratuitos, etc.). Sus límites cambian a menudo y no los controla OpenCode: compruébalos en su web.

### Lo que se paga

**OpenCode Console (pago por uso).** Sin cuota de asiento. Añades créditos y pagas por petición según la tabla de precios por millón de tokens. Hay un recargo de procesamiento del 4,6 % + 0,31 USD al comprar créditos. Cuando el saldo llega a cero, las peticiones de pago fallan con `402`.

**OpenCode Go (suscripción).** Acceso a un catálogo de modelos de código con límites mensuales expresados en dólares de consumo:

| Plan | Precio | Qué incluye |
|---|---|---|
| Go | 10 USD/mes | Acceso de bajo coste al catálogo |
| Go Plus | 40 USD/mes | Límites más altos |
| Go Teams | 20 USD/miembro/mes | Un límite por miembro, 5 USD por encima de Go en cada modelo |

Los límites se reparten por ventanas: 20 % del mensual en 5 horas, 50 % semanal y 100 % mensual. Es una suscripción opcional: no hace falta para usar OpenCode.

**API de proveedor.** La opción con más control y la más fácil de disparar sin querer: se paga por token de entrada y salida, y el contexto largo multiplica la factura. La guía de coste de contexto de este repositorio explica por qué una sesión mal llevada puede costar más que una suscripción.

### Qué elegir según tu caso

| Situación | Elección razonable |
|---|---|
| Portátil sin GPU y quiero probar hoy | Modelos gratuitos de Console; si no hay, una API con 5 USD de límite |
| Tengo GPU y datos que no pueden salir | Ollama local con un modelo de código de 7B a 14B |
| Ya pago ChatGPT Plus o Copilot | Enlazarlo y medir si cubre tu uso |
| Uso diario de 4 a 8 horas | Comparar Go (10 USD) con el gasto real de tu API durante un mes |
| Equipo pequeño | Go Teams; cada miembro con su límite y sus credenciales |
| Solo quiero aprender el flujo | Modelo local pequeño o modelos gratuitos; no pagues todavía |

## 6. Cómo empezar en diez minutos

1. Instala: `curl -fsSL https://opencode.ai/v2/install | bash`.
2. Entra en un proyecto pequeño y ejecuta `opencode`.
3. Sin conectar nada, comprueba si detecta Ollama o LM Studio con `/models`. Si no, conecta un proveedor con `/connect`.
4. Pide algo de solo lectura: «Resume la estructura y dime dónde está la configuración».
5. Crea un `AGENTS.md` con las convenciones del proyecto y las órdenes de test.
6. Pide un cambio pequeño en una rama y revisa el diff.
7. Ejecuta `/undo` para ver cómo se revierte. Saber deshacer es parte de aprender a usarlo.

## 7. Errores frecuentes

| Error | Qué pasa | Remedio |
|---|---|---|
| Dar una tarea enorme sin contexto | El agente explora a ciegas y gasta contexto | Divide, nombra archivos con `@`, define el criterio de hecho |
| No tener `AGENTS.md` | Estilo y comandos inventados | Escribe convenciones y verificación |
| Usar `main` para probar | Cambios mezclados con trabajo real | Rama por tarea |
| Ignorar el coste del contexto | Factura alta o límites agotados | Sesiones cortas, `/new` por tarea, evitar volcar archivos enteros |
| Confiar en el resumen de la sesión | Se pierde detalle al compactar | Deja estado en archivos versionados |
| Pegar claves en el chat | Quedan en el historial y pueden salir al proveedor | Variables de entorno y gestor de secretos |
| Modelo local demasiado pequeño | Herramientas mal usadas y respuestas incoherentes | Sube de tamaño o baja la ambición de la tarea |
| Instalar con `sudo npm` | Permisos rotos y actualizaciones frágiles | Instalador oficial o gestor de versiones |

## 8. Dónde seguir

- Documentación oficial, instalación y descargas: <https://opencode.ai/v2/docs/>
- Proveedores y conexión de cuentas: <https://opencode.ai/v2/docs/providers/>
- Modelos y precios de Console: <https://opencode.ai/v2/docs/console/models/>
- Suscripción Go: <https://opencode.ai/v2/docs/console/go/>
- Configuración: <https://opencode.ai/v2/docs/config/>
- Permisos: <https://opencode.ai/v2/docs/permissions/>
- Solución de problemas: <https://opencode.ai/v2/docs/troubleshooting/>

Dentro de este repositorio:

- [Continuidad de sesiones con OpenCode](opencode-session-continuity.md): cómo evitar que el contexto se pierda entre sesiones.
- [Inferencia local frente a cloud](local-vs-cloud.md): criterios para decidir dónde ejecutar el modelo.
- [OpenCode frente a VS Code y Antigravity](../referencia/opencode-vs-vscode-antigravity.md): comparación por privacidad, coste y control.
- [Coste de contexto y optimización](../referencia/coste-contexto-y-optimizacion.md): por qué el contexto es la partida cara.

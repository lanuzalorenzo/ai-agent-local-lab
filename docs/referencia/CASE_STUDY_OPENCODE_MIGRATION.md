# Caso de estudio: dos flujos de trabajo con IA

> **Estado:** Parcial. Describe el diseño inicial y el flujo que se usa hoy. No incluye claves ni mediciones de latencia o calidad.

## 1. Visión general

El laboratorio trabaja con dos flujos, elegidos según el dato:

- **Flujo local:** para código y datos que no pueden salir de la red.
- **Flujo remoto:** para el trabajo diario de desarrollo, con OpenCode Go.

El objetivo es que cada tarea vaya al entorno que ofrece el mejor equilibrio entre privacidad, límites y capacidad. Ambos flujos usan el mismo cliente, OpenCode, para que el cambio de uno a otro no obligue a cambiar de forma de trabajar.

## 2. Flujo 1: datos restringidos en local (Ollama)

- **Propósito:** modificar código sensible, ejecutar tareas sin enviar datos a terceros y trabajar sin conexión.
- **Infraestructura:** servidor en red privada (`http://ollama.lab.local:11434`) con Ollama y Qwen 2.5 Coder (7B).
- **Límites:**
  - La ventana de contexto es menor que la de los modelos remotos.
  - La calidad depende del hardware y del modelo descargado.
  - Montarlo y ajustarlo lleva mucho tiempo.
  - «Local» no significa automáticamente «privado»: hay que controlar la escucha de red, el firewall, los logs y el cliente.

## 3. Flujo 2: trabajo diario con OpenCode Go

- **Propósito:** desarrollo diario, lectura de repositorios, documentación y cambios en proyectos.
- **Infraestructura:** suscripción OpenCode Go, conectada desde OpenCode con `/connect`. Por ejemplo, el modelo Claude Haiku 5.5 se identifica como `opencode-go/claude-haiku-5-5`.
- **Antes:** mientras se agotaban los créditos de OpenCode Console, se conectó Antigravity a OpenCode. Fue caótico y no permitía trabajar bien; se descartó.
- **Motivo:** límites y disponibilidad de modelos que no cubrían ni el flujo local ni los planes gratuitos probados antes (experiencia de uso propia, no medida).
- **Límites:**
  - Los datos salen del equipo. No usar con secretos ni datos personales.
  - Antes de enviar código de un cliente, revisar la política de privacidad vigente del proveedor.
  - Depende de los límites y condiciones del proveedor, que cambian.

## 4. Configuración

El flujo local se define en `opencode.json`. Sustituye `ollama.lab.local` por el nombre de tu servidor:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
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

El flujo remoto no necesita nada en el archivo: se conecta dentro de OpenCode con `/connect`. Las claves nunca van en `opencode.json` ni en el repositorio.

El diseño inicial incluía también la API de NVIDIA NIM. Se probó, pero no se pudo validar la cuenta y no se pudo usar, así que se descartó. No forma parte del flujo en uso.

## 5. Criterios de selección

| Criterio | Flujo local | Flujo remoto (OpenCode Go) |
|---|---|---|
| Privacidad del código | Alta, si la red y los logs están controlados | Baja: el código sale del equipo |
| Límites de uso | Los marca el hardware | Los marca el plan |
| Coste | Hardware y electricidad | Suscripción; opciones y precios en la web oficial |
| Latencia | Baja en red local | Depende de la red y del proveedor |
| Capacidad | Modelos de código medianos | Modelos gestionados por el proveedor |
| Datos permitidos | Código sensible, secretos y datos personales, si la red está controlada | Código y documentación según la política del proveedor; nunca secretos ni datos personales |

## 6. Seguridad del laboratorio

- Ollama no debe escuchar en `0.0.0.0:11434` sin firewall.
- El puerto no se publica en Internet. El acceso remoto usa red privada y, si hace falta, un proxy con TLS y autenticación.
- Las claves de API se guardan en variables de entorno o en el gestor de credenciales, nunca en el repositorio.
- Los prompts privados, las notas personales y los datos de clientes quedan fuera del repositorio y de cualquier contexto enviado a un proveedor remoto.
- Los modelos se descargan de fuentes oficiales, revisando origen y licencia.
- Los logs de inferencia se tratan como potencialmente sensibles.

## 7. Estado y validación

| Elemento | Estado |
|---|---|
| Servidor Ubuntu con Ollama | Documentado; instalación no reproducida en este repositorio |
| Modelo local Qwen 2.5 Coder 7B | Configurado en el Modelfile y en la guía de Continue |
| Ollama dentro de OpenCode | Ejemplo; requiere el nombre de servidor real |
| OpenCode Go en uso diario | Uso propio, sin medición comparativa; política del proveedor no verificada aquí |
| Medición de latencia y calidad | No realizada; no se presentan métricas |

## 8. Lecciones

1. Separar flujos evita enviar código sensible a un proveedor por comodidad.
2. Los límites de uso pesan tanto como la privacidad: un flujo que se queda corto acaba sin usarse.
3. La seguridad depende de la red y de la gestión de claves, no solo de que el modelo corra en local.
4. La documentación debe distinguir configuración, ejecución y medición.

La mecánica de continuidad entre sesiones (comandos, briefs y estado en archivos) se documenta en [`../guias/opencode-session-continuity.md`](../guias/opencode-session-continuity.md).

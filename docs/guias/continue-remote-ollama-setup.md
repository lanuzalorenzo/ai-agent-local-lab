# Continue en VS Code con Ollama en otro equipo

> **Estado:** Runbook preparado. La configuración de ejemplo no está guardada en el repositorio, y el resultado de la conexión no se ha registrado aquí.

Esta guía configura Continue, la extensión de VS Code, para usar un modelo que corre en el servidor de Ollama de tu red.

> **Privacidad:** esta guía usa `ollama.lab.local` como nombre de ejemplo. No publiques direcciones IP internas, nombres de máquinas ni prompts privados. Cambia el nombre por el de tu red y no añadas datos de tu infraestructura al repositorio.

## 1. Qué hay en el servidor

- **Servidor:** `http://ollama.lab.local:11434`, Ubuntu Server (ver la [guía de despliegue](server-deployment-ubuntu-ollama.md)).
- **Modelo:** `portfolio-agent`, creado a partir de `qwen2.5-coder:7b` con una ventana de contexto de 16 384 tokens.
- **Cliente:** VS Code con la extensión Continue en tu equipo.

Crear el modelo en el servidor es un paso aparte. El repositorio no incluye una ejecución de ese comando:

```bash
ollama create portfolio-agent -f config/Modelfile.portfolio-agent
```

El script [`run_agent.sh`](../../scripts/utilidades/run_agent.sh) usa el modelo base `qwen2.5-coder:7b`, no `portfolio-agent`.

## 2. Configurar Continue

Continue guarda su configuración en `~/.continue/config.yaml` (o `config.json`). Añade el modelo así:

```yaml
models:
  - name: Portfolio Agent
    provider: ollama
    model: portfolio-agent
    apiBase: http://ollama.lab.local:11434
    contextLength: 16384
```

El valor `contextLength` tiene que coincidir con el `num_ctx` del `Modelfile`. Si no coinciden, al adjuntar archivos grandes aparece el error `File exceeds model's context length`.

## 3. Cómo dar contexto al modelo

No conviene cargar documentos grandes en el prompt del sistema: se envían en cada petición y el modelo tarda más. Es mejor adjuntar solo lo que hace falta en cada tarea:

- `@file`: un archivo concreto, por ejemplo `@AGENTS.md`.
- `@folder` o `@workspace`: busca en el repositorio con índices locales.
- `@code`: un fragmento de código seleccionado en el editor.

No adjuntes prompts privados, notas personales, credenciales ni datos de clientes. Para pruebas, usa repositorios de laboratorio y datos inventados.

## 4. Red y seguridad

- Ollama escucha por defecto solo en `127.0.0.1:11434`. Para usarlo desde otro equipo, limita la escucha a la interfaz de la red de laboratorio y pon un firewall delante.
- No expongas el puerto 11434 en Internet.
- Si el acceso remoto cruza redes que no son de confianza, usa un proxy inverso con TLS y autenticación.
- Comprueba dónde escucha el servicio con `ss -lntp | grep 11434`.
- Anota qué cliente y qué modelo usas. No compartas logs que contengan prompts.

## 5. Comprobaciones rápidas

En el servidor:

```bash
systemctl status ollama
ss -lntp | grep 11434
ollama list
curl -s http://localhost:11434/api/tags
```

La última línea pide la lista de modelos al propio servidor, sin enviar datos.

Si Continue no conecta, comprueba en este orden:

1. Que el nombre `ollama.lab.local` se resuelve desde tu equipo.
2. Que el firewall deja pasar el puerto solo desde la red de laboratorio.
3. Que `contextLength` coincide con `num_ctx`.
4. Los logs del servicio: `journalctl -u ollama -n 100 --no-pager`.

# Guía de Configuración: Continue (VS Code) + Ollama Remoto

Configuración del cliente de desarrollo Continue en VS Code conectado al servidor bare-metal dedicado de inferencia local.

> **Privacidad:** esta guía usa `ollama.lab.local` como hostname de ejemplo. No
> publiques direcciones IP internas, nombres de máquinas ni rutas de prompts
> privados. Sustituye el hostname por el valor de tu red y mantén el repositorio
> libre de datos de infraestructura.

---

## 1. Topología del Entorno

- **Servidor Remoto Ollama:** `http://ollama.lab.local:11434` (Ubuntu Server headless).
- **Modelo Especializado:** `portfolio-agent` (basado en `qwen2.5-coder:7b`, con `num_ctx 16384` y prompt de sistema conciso).
- **Cliente:** VS Code con extensión Continue en equipo de desarrollo.

---

## 2. Configuración en Continue (`~/.continue/config.yaml` o `config.json`)

Para evitar el error `File exceeds model's context length`, es necesario sincronizar el parámetro `contextLength` de Continue con la directiva `num_ctx` del `Modelfile` del servidor:

```yaml
models:
  - name: Portfolio Agent
    provider: ollama
    model: portfolio-agent
    apiBase: http://ollama.lab.local:11434
    contextLength: 16384
```

---

## 3. Patrón de Trabajo: Inyección de Contexto Bajo Demanda

En lugar de cargar el prompt de sistema con documentos extensos en cada llamada:

1. **Prompt de sistema base minimalista:** solo define el rol (*Software
   Architect, DevSecOps & Cloud Security*) y las restricciones éticas y
   arquitectónicas.
2. **Contexto bajo demanda con modificadores de Continue:**
   - `@file`: adjunta archivos específicos (por ejemplo, `@AGENTS.md`).
   - `@folder` / `@workspace`: indexación vectorial y embeddings locales para
     consultar el repositorio.
   - `@code`: selección de fragmentos concretos de código C#, Netplan o KQL.
3. **Higiene de contexto:** no adjuntes prompts privados, notas personales,
   credenciales ni datos de clientes. Usa repositorios de laboratorio y datos
   sintéticos.

---

## 4. Requisitos de red y seguridad

- Ollama escucha por defecto en `127.0.0.1:11434`. Si necesitas acceso remoto,
  limita la escucha a la interfaz de la red de laboratorio y aplica firewall.
- No expongas el puerto `11434` a Internet.
- Usa un proxy inverso con TLS y autenticación si el acceso remoto cruza redes no
  confiables.
- Verifica la interfaz de escucha con `ss -lntp | grep 11434`.
- Registra qué cliente y qué modelo se usan; no compartas logs con prompts
  sensibles.

## 5. Diagnóstico rápido

```bash
# Servicio
systemctl status ollama

# Escucha y puerto
ss -lntp | grep 11434

# Modelo disponible
ollama list

# Prueba local sin datos sensibles
curl -s http://localhost:11434/api/tags
```

Si Continue no conecta:

1. Comprueba que el hostname resuelve desde el cliente.
2. Verifica que el firewall permite el puerto solo desde la red de laboratorio.
3. Confirma que `contextLength` coincide con `num_ctx`.
4. Revisa los logs de Ollama con `journalctl -u ollama -n 100 --no-pager`.

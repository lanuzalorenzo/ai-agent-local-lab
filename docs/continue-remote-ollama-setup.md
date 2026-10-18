# Guía de Configuración: Continue (VS Code) + Ollama Remoto

Configuración del cliente de desarrollo Continue en VS Code conectado al servidor bare-metal dedicado de inferencia local.

---

## 1. Topología del Entorno

- **Servidor Remoto Ollama:** `http://192.168.50.156:11434` (Ubuntu Server headless).
- **Modelo Especializado:** `portfolio-agent` (basado en `llama3` con `num_ctx 16384` y prompt de sistema conciso).
- **Cliente:** VS Code con extensión Continue en equipo de desarrollo (XPS).

---

## 2. Configuración en Continue (`~/.continue/config.yaml` o `config.json`)

Para evitar el error de cliente `File exceeds model's context length`, es imperativo sincronizar el parámetro `contextLength` de Continue con la directiva `num_ctx` definida en el `Modelfile` del servidor:

```yaml
models:
  - name: Portfolio Agent
    provider: ollama
    model: portfolio-agent
    apiBase: http://192.168.50.156:11434
    contextLength: 16384
```

---

## 3. Patrón de Trabajo Óptimo (Inyección de Contexto Bajo Demanda)

En lugar de sobrecargar el prompt de sistema del modelo con documentos masivos en cada llamada:

1. **Prompt de sistema base minimalista:** Solo define rol (*Software Architect, DevSecOps & Cloud Security*) y restricciones éticas/arquitectónicas.
2. **Contexto bajo demanda con modificadores de Continue:**
   - `@file`: Adjunta archivos específicos (ej. `@prompt-maestro-diario.md`, `@AGENTS.md`).
   - `@folder` / `@workspace`: Indexación vectorial y embeddings locales para consultar el repositorio.
   - `@code`: Selección de fragmentos concretos de código C#, Netplan o KQL.

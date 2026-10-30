# Bitácora de decisiones y aprendizaje

Este documento recoge, en orden cronológico, las decisiones, los problemas, sus causas y las soluciones del laboratorio. Sirve como memoria técnica, como guía para reinstalar el entorno y como punto de partida para decidir qué sigue.

## Índice de entradas

1. [Entrada 01: Servidor sin escritorio con Ubuntu Server](#entrada-01-servidor-sin-escritorio-con-ubuntu-server)
2. [Entrada 02: Sin red tras instalar Ubuntu Server](#entrada-02-sin-red-tras-instalar-ubuntu-server)
3. [Entrada 03: Ollama, primeras pruebas y acceso por SSH](#entrada-03-ollama-primeras-pruebas-y-acceso-por-ssh)
4. [Entrada 04: Hoja de ruta y ejes de aprendizaje](#entrada-04-hoja-de-ruta-y-ejes-de-aprendizaje)
5. [Entrada 05: Ajuste de la ventana de contexto (`portfolio-agent` con Continue)](#entrada-05-ajuste-de-la-ventana-de-contexto-portfolio-agent-con-continue)
6. [Entrada 06: Dónde guardar los vectores del RAG local](#entrada-06-dónde-guardar-los-vectores-del-rag-local)
7. [Entrada 07: Cifras de VRAM de terceros: la aritmética primero](#entrada-07-cifras-de-vram-de-terceros-la-aritmética-primero)
8. [Entrada 08: Trabajo diario con OpenCode Go y local para datos restringidos](#entrada-08-trabajo-diario-con-opencode-go-y-local-para-datos-restringidos)
9. [Entrada 09: Datos internos en el historial público](#entrada-09-datos-internos-en-el-historial-público)

---

## Entrada 01: Servidor sin escritorio con Ubuntu Server

- **Contexto:** hace falta un equipo dedicado a la inferencia de modelos con Ollama, sin depender de APIs de terceros ni exponer datos o código.
- **Decisión:** instalar Ubuntu Server en modo consola, en un equipo físico, en lugar de una distribución con escritorio o una máquina virtual con GPU compartida.
- **Por qué:**
  - **Memoria:** un escritorio reserva del orden de 1,5 a 3,5 GB de RAM para la interfaz gráfica y sus servicios. Es una estimación general, no una medición de este laboratorio. Sin escritorio, esa memoria queda para el modelo.
  - **Superficie de ataque:** sin escritorio ni navegadores en el servidor hay menos programas que mantener y parchear.
  - **Gestión con `systemd`:** Ollama corre como servicio en segundo plano, se reinicia solo y deja registros que se leen con `journalctl`.

---

## Entrada 02: Sin red tras instalar Ubuntu Server

- **Problema:** después de la instalación mínima, el equipo no tenía red ni internet. No estaban `nmtui`, `NetworkManager` ni ninguna herramienta de Wi-Fi interactiva.
- **Causa:** el instalador mínimo configura solo la pila básica de red, con `systemd-networkd`, y no instala herramientas de conexión. Sin internet no se puede instalar `network-manager` con `apt`.
- **Solución en dos fases:**
  1. **Cable, con Netplan.** Conexión por cable al router. Configuración en `/etc/netplan/01-netcfg.yaml`:
     ```yaml
     network:
       version: 2
       renderer: networkd
       ethernets:
         enp3s0:
           dhcp4: true
     ```
     Se aplica con `sudo netplan apply`. Se comprueba con `ip a` y la resolución de nombres.
  2. **Wi-Fi.** Con internet ya disponible, se instala `network-manager` (`sudo apt update && sudo apt install network-manager -y`) y se configura la red inalámbrica con `sudo nmtui`. Así el servidor puede colocarse en cualquier punto de la red.

---

## Entrada 03: Ollama, primeras pruebas y acceso por SSH

- **Acceso remoto:** el servidor se administra desde el equipo principal por SSH, con clave o sesión:
  ```bash
  ssh usuario@IP_DEL_SERVIDOR
  ```
- **Instalación de Ollama:** con el script oficial:
  ```bash
  curl -fsSL https://ollama.com/install.sh | sh
  ```
  El socket de escucha esperado es `127.0.0.1:11434`, o la interfaz que se configure.
- **Primeras pruebas de modelos:**
  - Se probó `llama3` con `ollama run llama3`.
  - La valoración de tiempos de respuesta, latencia del primer token y uso de CPU o GPU es subjetiva. No hay datos ni archivos en el repositorio que la respalden.
  - Se previó extender las pruebas a modelos de razonamiento y de código, como `mistral` o `codellama`.
- **Modelo operativo:** `qwen2.5-coder:7b`, por su buen rendimiento con código y porque encaja con el `Modelfile` del laboratorio.

---

## Entrada 04: Hoja de ruta y ejes de aprendizaje

El laboratorio sigue como espacio de aprendizaje en IA aplicada. Estos son los ejes pendientes; las casillas marcadas ya están hechas.

### Eje 1: aceleración por hardware y modelos cuantizados

- [ ] Validar los drivers CUDA y NVIDIA Container Toolkit si se añade una GPU dedicada.
- [ ] Medir cómo cambian la calidad y el consumo de memoria de la GPU con cuantizaciones GGUF distintas (Q4_K_M, Q5_K_M, Q8_0).

### Eje 2: red y exposición segura

- [ ] Configurar Ollama para escuchar en la red (`OLLAMA_HOST=0.0.0.0:11434`) y limitar el acceso con un firewall (`ufw`), un túnel SSH o una VPN WireGuard. Solo el equipo autorizado debe poder usar la API.
- [ ] Poner un proxy inverso con TLS (NGINX o Caddy) con autenticación por token o mTLS.

### Eje 3: clientes y asistentes de desarrollo

- [x] Continue en VS Code apuntando al servidor Ollama, con el contexto de 16K sincronizado.
- [ ] Evaluar el uso de todo el código como contexto (*embeddings* del repositorio) y el autocompletado en tiempo real.

### Eje 4: RAG local y agentes

- [ ] Construir un RAG local con una base de datos vectorial embebida (ChromaDB o Qdrant) para consultar documentación técnica y notas propias sin enviar nada fuera. El criterio del motor está en la [entrada 06](#entrada-06-dónde-guardar-los-vectores-del-rag-local).
- [ ] Probar frameworks de agentes locales (LangChain, LlamaIndex o AutoGen) con el modelo servido por Ollama.

### Eje 5: evaluación y robustez de modelos

- [ ] Construir el conjunto dorado mínimo (20 a 50 casos) descrito en [`ai-security-evaluation.md`](ai-security-evaluation.md) y ejecutarlo en CI.
- [x] Implementar la matriz de disfraces de [`prompt-robustness-testing.md`](prompt-robustness-testing.md): canarios C0 a C4, familias F1 a F4 y niveles N0 a N3.
- [x] Ejecutar la matriz en el equipo Ubuntu con [`run_robustness_lab.sh`](../../scripts/robustez/run_robustness_lab.sh) y guardar la huella del entorno junto a los resultados.
- [x] Primera ejecución (2026-10-22, `qwen2.5:3b`, N0 y N1): obediencia en N0 de 0,50. La inyección directa funciona sin transformar.
- [x] Añadir el control negativo C0 y excluir las cuatro transformaciones que el modelo no descifra. Medían si el modelo entiende el texto, no si resiste la orden.
- [x] Segunda pasada, solo N0 (2026-10-22, prompt `v1`): control negativo 3 de 3 con JSON válido; obediencia de 0,50, igual que la primera.
- [x] Registrar la huella del prompt de sistema desde la pasada `prompt-v2`. Las evidencias `v1` y `v2` anteriores no la registraron.
- [ ] Terminar la corrección del instrumento: comprobación de descifrado (para reactivar F3) y un detector de C3 que separe el formato del contenido.
- [x] Medir el prompt `v2`: N0 sigue en 0,50. La defensa tiene que ser un control externo, no otra instrucción. N1 con `v2` sigue pendiente.
- [ ] En cada ejecución, separar el fallo del filtro (evasión) del fallo del modelo (obediencia). Sin ese desglose no se sabe qué corregir.
- [ ] Comparar modelos locales con una **puntuación por tarea**, no con un ranking general: el resultado solo vale para el prompt y la tarea evaluados.
- [ ] Medir el factor de expansión de tokens de cada transformación. Una defensa que multiplica el coste por diez es un problema de consumo, no solo de filtrado.

---

## Entrada 05: Ajuste de la ventana de contexto (`portfolio-agent` con Continue)

- **Fecha:** octubre 2026
- **Contexto:** al conectar Continue desde el equipo cliente con el servidor (`http://ollama.lab.local:11434`), se probaron modelos especializados y prompts de sistema largos.

### 1. Problemas iniciales

- **Respuestas lentas:** un prompt de sistema de unos 1.500 tokens, fijado en el `Modelfile`, obligaba al modelo a procesarlo en cada llamada. Eso retrasaba el primer token y hacía lenta la interacción.
- **Límite de contexto:** al adjuntar archivos grandes con `@file` (un archivo de contexto de unos 18,8 KB), aparecía el error `File exceeds model's context length`. El límite por defecto era de 2.048 tokens, tanto en Ollama como en Continue.

### 2. Cambios aplicados

#### A. Cambios en el `Modelfile` del servidor

- **Prompt de sistema ligero:** el prompt largo se sustituyó por un bloque `SYSTEM` corto. Solo fija el papel del asistente y remite a las reglas del repositorio (su `AGENTS.md`). Las reglas personales de rol no están en el repositorio público, y la versión publicada es esta.
- **Ventana de contexto (`num_ctx`):** se añadió `PARAMETER num_ctx 16384` en [`config/Modelfile.portfolio-agent`](../../config/Modelfile.portfolio-agent) para poder cargar documentos grandes sin ocupar memoria desde el arranque:

```dockerfile
FROM qwen2.5-coder:7b

SYSTEM """
Eres un asistente de desarrollo para un laboratorio de IA local.
Sigue las instrucciones del AGENTS.md del repositorio en el que trabajas.
Si no tienes un dato, dilo en lugar de suponerlo.
"""

PARAMETER num_ctx 16384
PARAMETER stop <|im_end|>
PARAMETER stop <|endoftext|>
PARAMETER temperature 0.2
PARAMETER top_p 0.9
```

#### B. Configuración de Continue

Se fijó `contextLength: 16384` en la definición del modelo, para que el cliente y el servidor usen el mismo límite y no se bloquee al cargar archivos:

```yaml
models:
  - name: Portfolio Agent
    provider: ollama
    model: portfolio-agent
    apiBase: http://ollama.lab.local:11434
    contextLength: 16384
```

### 3. Resultados

Lo que sigue es la observación del autor. No hay una ejecución reproducible adjunta en el repositorio.

1. **Respuestas más rápidas:** el modelo no vuelve a procesar un prompt largo en cada llamada.
2. **Contexto bajo demanda:** adjuntar solo los archivos que hacen falta (`@AGENTS.md`, `@file`, `@folder` o `@workspace`) según la tarea.
3. **Archivos grandes:** se pueden adjuntar archivos de hasta 16K tokens sin que la ventana se desborde.

---

## Entrada 06: Dónde guardar los vectores del RAG local

- **Fecha:** octubre 2026
- **Estado:** Diseño. No se ha medido nada y la decisión no está tomada.
- **Contexto:** el eje 4 de la hoja de ruta propone un RAG sobre documentación técnica y notas propias. Antes de elegir un modelo para las respuestas hay que decidir dónde se guardan los vectores (las representaciones numéricas de los textos). Hay dos familias: una base embebida (ChromaDB o Qdrant en local) o PostgreSQL con la extensión `pgvector`.
- **Decisión:** ninguna todavía. Se deja escrito el criterio para no elegir por costumbre ni por lo que dice una comparativa ajena.

| Criterio | Base embebida | PostgreSQL con `pgvector` |
|---|---|---|
| Mantenimiento | Una librería; sin servicio ni puerto | Un servicio propio, con copias de seguridad, parches y autenticación |
| Búsqueda combinada (texto y vector) | Limitada o a mano | SQL completo y búsqueda por palabras en la misma consulta |
| Coherencia con los metadatos | Copia aparte que puede desincronizarse | Transacciones junto al resto de datos |
| Corpus pequeño (menos de 50 000 fragmentos) | Suficiente | Demasiado para ese tamaño |
| Varios consumidores a la vez | Punto débil | Resuelto de origen |
| Huella en el servidor sin escritorio | Menor; se carga al consultar | Un proceso más, siempre en memoria |
| Cliente .NET | Menos opciones maduras | Proveedor de EF Core con tipos vectoriales |

**Criterio propuesto:** si el corpus es pequeño y el único consumidor es el agente del laboratorio, base embebida: menos piezas, una copia de seguridad de un directorio y ningún puerto que cerrar. Si aparece información relacional que consultar junto al vector, búsqueda combinada o un segundo cliente, PostgreSQL. Cambiar después de haber construido los índices implica reindexar, no mover un archivo.

**Riesgo de método:** el motor influye menos que el modelo de embeddings y la forma de trocear los documentos. Sin un conjunto dorado no se puede afirmar que un motor recupere mejor. Hay que compararlos con el mismo instrumento del eje 5, con las mismas preguntas y el mismo corpus.

**Nota:** `pgvector` no es una extensión de algo que ya exista en el laboratorio. Exige instalar PostgreSQL, que hoy no está.

**Pendiente:**
- Fijar el tamaño del corpus y el número de consumidores antes de la primera prueba.
- Elegir el modelo de embeddings y documentar su dimensión y su coste en tokens.
- Medir la recuperación (qué porcentaje de preguntas del conjunto dorado encuentra el fragmento correcto) antes de comparar motores.

---

## Entrada 07: Cifras de VRAM de terceros: la aritmética primero

- **Fecha:** octubre 2026
- **Estado:** Parcial. Es una observación sin medir. El cálculo justifica el escepticismo; la comprobación en hardware sigue pendiente.
- **Contexto:** es habitual leer que un modelo de unos 27 000 millones de parámetros, «con cuantización ligera», cabe en menos de 10 GB de VRAM y funciona entero en la gráfica. Antes de repetir esa cifra o de planear una compra con ella, conviene hacer la cuenta.

**La cuenta que no se puede saltar:** el peso de los parámetros en memoria es proporcional a los bits por peso.

| Cuantización (bits por peso, aprox.) | Peso de 27 B | ¿Cabe en 10 GB? |
|---|---:|---|
| FP16 (16) | ~54 GB | No |
| Q8 (8,5) | ~28 GB | No |
| Q5_K_M (5,7) | ~19 GB | No |
| Q4_K_M (4,8) | ~16 GB | No |
| Q3_K_M (3,9) | ~13 GB | No |
| Q2_K (3,1) | ~10,5 GB | Al límite, y sin caché |

A eso se suma la caché del contexto (KV cache), que con ventanas largas puede ocupar varios GB más. Conclusión: un modelo de 27 B en menos de 10 GB exige bajar de 3 bits por peso, lo que no es una cuantización ligera. La otra opción es usar la RAM del sistema para parte del modelo (*offload* parcial), que es otra cosa.

**Excepción que no conviene confundir:** los modelos de mezcla de expertos (MoE) activan pocos parámetros por token, pero necesitan tener todos sus pesos cargados para no degradarse. Si parte de los expertos vive en RAM, el modelo funciona, pero no corre entero en la gráfica ni a la velocidad que sugiere el anuncio.

**Regla reutilizable:** antes de aceptar una cifra de VRAM, divide los parámetros entre los bits por peso y suma el contexto. Si el resultado no cuadra con lo anunciado, el error está en el anuncio.

**Lo que sí es cierto y justifica el caso local:** un modelo servido en local no está sujeto a las políticas de rechazo de un proveedor, y eso importa en las auditorías de un laboratorio propio. Pero no rechazar no es lo mismo que acertar. La validez de un análisis se demuestra ejecutando pruebas, no leyendo la respuesta.

**Pendiente:**
- Comprobar el tamaño real de cada archivo GGUF descargado frente al cálculo. El tamaño en disco es la comprobación más rápida.
- Medir la VRAM real con `nvidia-smi` durante la inferencia, no al cargar el modelo.

---

## Entrada 08: Trabajo diario con OpenCode Go y local para datos restringidos

- **Fecha:** octubre 2026
- **Estado:** Parcial. La decisión está en uso. Las comparaciones de límites y disponibilidad son experiencia propia, sin medición.
- **Contexto:** Copilot y Antigravity se agotaban antes del reinicio de sus límites a medida que los proyectos crecían. OpenRouter con modelos gratuitos quedaba corto para el trabajo diario. OpenCode con Ollama en local funcionaba, pero montarlo y ajustar el rendimiento consumía demasiado tiempo. OpenCode Console se quedó corto al crecer el trabajo y se agotaron sus créditos. Mientras tanto se conectó Antigravity a OpenCode: fue caótico y no permitía trabajar bien. La API de NVIDIA (build/dev) también se probó, pero no se pudo validar la cuenta y no llegó a usarse.
- **Decisión:** el trabajo diario se hace con OpenCode Go. El modelo local (Ollama) queda para código y datos que no pueden salir de la red del laboratorio. Deja de ser la opción por defecto.
- **Consecuencias:**
  - Antes de enviar datos a Go hay que revisar su política de privacidad vigente. No está verificada en el repositorio.
  - Las guías de decisión (`local-vs-cloud.md` y la comparativa de OpenCode) reflejan este criterio.
  - La decisión se revisa si cambian los límites, la política del proveedor o el hardware.

**Pendiente:**
- Verificar la política de privacidad vigente de OpenCode Go antes de usarlo con datos de clientes o personales.

---

## Entrada 09: Datos internos en el historial público

- **Fecha:** 2026-10-30
- **Estado:** Parcial. El estado actual y el historial de la rama principal ya están saneados en GitHub. El repositorio se renombró a `lab-ia-aprendizaje`. Queda pendiente que GitHub borre de su caché los commits antiguos.
- **Contexto:** antes de seguir publicando se revisó la coherencia del repositorio. El historial público contenía una dirección IP de la red interna, el nombre de un equipo personal, el rol personal del prompt de sistema de `portfolio-agent`, una ruta del equipo y referencias a notas privadas. No había credenciales.
- **Acción:**
  - Se sustituyeron esos datos por marcadores (`ollama.lab.local`, «equipo cliente», «asistente de desarrollo») en el estado actual y en todos los commits, con `git filter-branch`.
  - Se guardó una copia de seguridad fuera del repositorio antes de reescribir, y se borró al terminar.
  - La rama principal tiene protección que impide reescrituras forzadas. Para subir el historial saneado se activó temporalmente la reescritura forzada, se subió el cambio y se restauró la protección con sus valores originales.
- **Consecuencias:**
  - No hay que rotar credenciales, porque no se expuso ninguna.
  - Los commits antiguos pueden seguir visibles en las cachés de GitHub hasta que se soliciten.
- **Pendiente:**
  - Pedir a GitHub Support que elimine de su caché los commits antiguos.

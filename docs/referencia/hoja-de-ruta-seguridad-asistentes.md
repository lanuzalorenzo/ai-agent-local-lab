# Hoja de ruta: seguridad de asistentes en local

> **Estado:** Diseño. Fase 0 en revisión (2026-10-30). No hay resultados de los tres experimentos; lo que aparece como pendiente no se presenta como validado.
>
> **Alcance:** este repositorio, con Ollama y un cliente de desarrollo local (Continue u OpenCode). La inferencia local es la plataforma; el eje es la seguridad del asistente.

## 1. Pregunta y límites

La pregunta no es «¿es seguro el modelo?». Es:

> ¿Qué datos salen del equipo, qué obedece el agente cuando lee contenido del repositorio y qué puede tocar con sus herramientas?

Queda fuera: rankings de modelos, *AI red teaming* genérico, certificaciones, RAG, agentes autónomos y cualquier prueba con datos reales o servicios expuestos a Internet.

## 2. Fases

| Fase | Objetivo | Entregable | Criterio de salida | Estado |
|---|---|---|---|---|
| **0. Verdad y alcance** | Que el repositorio no afirme más de lo que sostiene | Rutas privadas eliminadas, estados explícitos, comandos copiables, prueba 7B + Continue registrada como Parcial, bug de `--restore` corregido | Sin rutas privadas, sin enlaces rotos, sin estados contradictorios | En revisión |
| **1. Reproducibilidad mínima** | Que lo que ya funciona se pueda repetir | `portfolio-agent` construido con `ollama create`, digest fijado, `run_agent.sh` usando ese modelo, servicio no-root, bind/firewall documentado o declarado local-only | Un runbook desde cero produce una respuesta local y deja evidencia saneada | Pendiente |
| **2. Frontera de datos** | Qué sale del equipo al usar el asistente | Captura de conexiones, DNS, destinos y volumen en local y en el flujo híbrido; prueba negativa sin red | Tabla de destinos con fecha y conclusión, incluso si no hay salida | Pendiente |
| **3. Inyección desde el repositorio** | Qué obedece el agente al leer un archivo | Fixture con instrucción oculta, fichero señuelo, tarea de agente, transcripción y veredicto | Evidencia de qué leyó, qué obedeció y qué no; el resultado negativo también se publica | Pendiente |
| **4. Permisos del agente** | Qué puede tocar | Política mínima de shell, lectura/escritura y red; prueba antes/después | Comando que demuestre el corte y alcance residual documentado | Pendiente |
| **5. Decisión de alcance** | Si el banco de seguridad se separa de la inferencia | Decisión escrita con evidencia de las fases 2–4 | Criterio explícito: mantener un repo o separar | Pendiente |

## 3. Los tres experimentos

### Experimento 1: frontera de datos

- **Qué se mide:** conexiones del cliente, resolución DNS, destinos, volumen y si el endpoint es realmente local.
- **Cómo:** prompt controlado, captura en el host o en un entorno aislado, comparación local frente a híbrido, prueba sin red.
- **Evidencia:** tabla saneada de destinos, fecha, cliente, configuración redactada y conclusión. Sin IPs internas ni prompts sensibles.
- **Criterio:** se puede decir qué sale y qué no, con una prueba reproducible; no se extrapola a otros clientes.

### Experimento 2: inyección desde el repositorio

- **Qué se mide:** si una instrucción oculta en un archivo del repo hace que el agente lea un señuelo o cambie de tarea.
- **Cómo:** fixture con una instrucción oculta en un README o comentario, un fichero señuelo con marcador único y una tarea legítima; se registran las herramientas invocadas y la salida.
- **Evidencia:** salida del agente, fichero señuelo, transcripción redactada y conclusión. Si no obedece, también se publica.
- **Criterio:** el resultado es observable y repetible; no se usan secretos ni datos personales. La matriz de perturbaciones actual no cubre este caso: prueba un campo de usuario, no contenido del repositorio.

### Experimento 3: permisos del agente

- **Qué se mide:** alcance real de shell, lectura/escritura de ficheros y red; qué se corta con una política mínima.
- **Cómo:** baseline sin política y después con política; intentos controlados de leer fuera del repo, escribir y abrir red.
- **Evidencia:** antes y después, comando que demuestra el corte, política versionada y límites residuales.
- **Criterio:** la política se aplica y se puede comprobar; no se confunde «el agente no quiso» con «el agente no pudo».

## 4. Dependencias y orden

1. Cerrar la Fase 0 antes de añadir páginas nuevas.
2. Cerrar la Fase 1 antes de los experimentos: sin modelo reproducible y sin endpoint controlado, las pruebas no son comparables.
3. Ejecutar 1 → 2 → 3. La frontera de datos informa qué cliente y qué endpoint se usan; la inyección necesita ese cliente; los permisos necesitan el mismo entorno.
4. No abrir RAG, *squad*, contenedores ni comparativas de modelos hasta cerrar la Fase 4. Son líneas legítimas, pero no sostienen el eje.

## 5. Reglas de evidencia

- Cada experimento tiene runbook, fecha, entorno, comando y artefacto saneado.
- Un hallazgo no es un PASS. Un control que no se rompe también es un hallazgo.
- Un resultado negativo se publica; no se rellena con una expectativa.
- No se publican IPs internas, secretos, rutas personales ni prompts privados.
- Si un paso no se puede reproducir, se marca como **Parcial** o **Pendiente**, no como **Validado**.

## 6. Decisión de alcance

La decisión por defecto es mantener un solo repositorio: la inferencia local es la plataforma y la seguridad de asistentes es el eje. Se separará solo si las fases 2–4 producen un cuerpo de evidencias y un público distintos, o si el mantenimiento del entorno de inferencia impide avanzar en seguridad. La decisión se toma en la Fase 5, no antes.

# Inferencia local frente a cloud: criterios de decisión

> **Estado:** criterios documentados. No es un benchmark ni una comparación de rendimiento medida.
>
> **Propósito:** decidir dónde ejecutar cada carga de trabajo sin convertir la elección en una preferencia ideológica.

## 1. La pregunta correcta

No es «¿local o cloud?». Es:

> ¿Qué dato entra, quién lo ve, cuánto cuesta, cuánto tarda y qué capacidad necesita?

La respuesta puede ser distinta para cada flujo. En este laboratorio convive un flujo local para trabajo privado y un flujo cloud para documentación masiva.

## 2. Dimensiones

| Dimensión | Local | Cloud |
|---|---|---|
| Sensibilidad del dato | El dato no sale del equipo o de la red de laboratorio | Depende del contrato, la región y la retención |
| Coste | Hardware, electricidad y mantenimiento | Pago por uso; puede ser menor en picos |
| Latencia | Sin red; limitada por el hardware | Red y cola del proveedor |
| Capacidad | Limitada por VRAM y modelo | Modelos mayores y escalado elástico |
| Disponibilidad | Depende de tu equipo y tu red | Depende del proveedor |
| Mantenimiento | Tú actualizas runtime, drivers y modelos | El proveedor actualiza |
| Cumplimiento | Control directo, sin tercero | Requiere revisar región, retención y subencargados |
| Reproducibilidad | Alta si fijas versiones | Puede cambiar sin aviso |

## 3. Escenarios típicos

| Escenario | Decisión razonable | Motivo |
|---|---|---|
| Código o datos de un cliente | Local | El dato no debe salir sin contrato y autorización |
| Borradores y documentación pública | Cloud o híbrido | Capacidad y coste; el dato no es sensible |
| Clasificación de tickets con datos personales | Local o cloud con redacción previa | Minimizar el dato antes de enviarlo |
| Evaluación masiva de un conjunto dorado | Cloud acotado o local en lote | Depende del volumen y del presupuesto |
| Asistente de desarrollo diario | Local si el hardware alcanza | Privacidad y latencia; el modelo debe ser suficiente |
| Modelo grande para arquitectura | Cloud | El hardware local no lo soporta |

## 4. Flujo híbrido

El caso de estudio de este repositorio describe dos flujos con el mismo cliente:

1. **Local:** Ollama en un servidor dedicado, para edición y trabajo con código privado.
2. **Cloud:** un proveedor externo, para documentación masiva y tareas que requieren más capacidad.

La decisión no es permanente: se revisa cuando cambia el dato, el coste o la capacidad. Lo importante es que la configuración deje claro qué proveedor usa cada flujo y que no se mezclen datos sensibles con el flujo remoto.

Ver [`CASE_STUDY_OPENCODE_MIGRATION.md`](../../docs/referencia/CASE_STUDY_OPENCODE_MIGRATION.md).

## 5. Errores frecuentes

- **«Local» significa privado.** Falso: depende de la configuración del cliente, del endpoint, de los logs y de si el modelo descarga recursos externos.
- **«Tengo GPU» significa que el modelo la usa.** Falso: hay que observarlo durante una inferencia.
- **«Cloud es más caro».** Depende del volumen y del coste de mantener hardware.
- **«El modelo local es igual de bueno».** Depende del modelo y de la tarea; no se asume.
- **«Ya funciona en mi máquina».** Sin versión fijada y sin evidencia, no es reproducible.

## 6. Cómo registrar la decisión

Para cada flujo, dejar escrito:

- qué dato entra y qué sensibilidad tiene;
- dónde se ejecuta el modelo y quién lo administra;
- qué coste se espera y con qué tope;
- qué latencia se necesita;
- qué se registra y durante cuánto tiempo;
- qué evidencia respalda que funciona;
- cuándo se revisa la decisión.

Una decisión sin fecha de revisión se convierte en deuda.

## 7. Límites

Este documento no compara modelos concretos ni publica latencias o costes medidos. Para eso hace falta ejecutar la misma carga en ambos entornos y conservar los resultados. Mientras no exista esa medición, las cifras son estimaciones o criterios, no evidencias.

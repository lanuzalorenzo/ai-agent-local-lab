# Ejemplo ilustrativo: lectura de un repositorio

## Escenario

Este ejemplo describe una tarea que puede probarse con un modelo local: pedir una explicación del propósito y la estructura de un repositorio y solicitar mejoras justificadas por archivos concretos. Es un escenario de prueba, no una sesión real ni una evaluación de la calidad de un modelo.

## Procedimiento propuesto

1. Configura Continue para usar el modelo local que hayas descargado en Ollama.
2. Selecciona un repositorio de prueba sin secretos, datos personales ni código que no tengas permiso para procesar.
3. Pide un resumen que cite rutas existentes y distinga hechos del repositorio de recomendaciones.
4. Verifica manualmente las afirmaciones contra los archivos y registra errores o limitaciones.
5. Si quieres comprobar el uso de GPU, observa el sistema durante la misma inferencia según [`docs/gpu-setup.md`](../docs/gpu-setup.md).

## Prompt de ejemplo

> Resume el propósito y la estructura de este repositorio usando solo archivos que hayas podido leer. Separa hechos observados de recomendaciones. Para cada recomendación, explica el problema concreto que resolvería. Indica las limitaciones de contexto y no inventes pruebas, resultados o configuraciones.

## Criterios de evaluación

| Criterio | Qué revisar |
|---|---|
| Trazabilidad | Las rutas citadas existen y respaldan las afirmaciones |
| Precisión | No inventa componentes, resultados ni pruebas |
| Utilidad | Las recomendaciones se relacionan con hallazgos concretos |
| Privacidad | No se usaron datos sensibles y se verificó el endpoint |
| Ejecución | Se anota modelo, versiones y evidencia real si se afirma uso de GPU |

**Resultado observado:** no registrado. Las respuestas de un modelo son salidas no verificadas y deben revisarse antes de incorporarlas a código o documentación.

# Evidencia — Inferencia local 7B + Continue (registro parcial)

> **Fecha de registro:** 2026-10-30
> **Fecha de la prueba:** no registrada
> **Estado:** Parcial — probado por el autor; sin artefacto reproducible en el repositorio
> **Modelo:** `qwen2.5-coder:7b` (digest no registrado)
> **Cliente:** Continue (versión no registrada)
> **Endpoint:** placeholder de laboratorio; no se publica una IP real

## Qué se observó

El autor confirma que la integración responde con el modelo de 7B en su equipo. La latencia percibida es alta («lento»), pero la integración funciona.

## Qué falta para pasar a Validado

- fecha y hora de la prueba;
- `ollama --version` y `ollama list` con el digest exacto;
- versión de Continue y configuración redactada;
- hardware, driver y memoria disponible;
- prompt de prueba y respuesta observada;
- latencia aproximada o `journalctl` sin prompts;
- comprobación de que el cliente usa el endpoint local y no un proveedor cloud.

## Límites

No hay `entorno.json`, `resultados.json`, captura ni log. Esta página no es una medición de rendimiento ni un PASS de seguridad. «Lento» no es una cifra de tokens por segundo.

## Siguiente paso

Repetir una sola prueba controlada, guardar los artefactos saneados y cambiar el estado a Validado para esa ejecución concreta. Mientras tanto, se cita como Parcial y no se usa para afirmar que el laboratorio está validado de extremo a extremo.

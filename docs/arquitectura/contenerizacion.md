# Contenerización de la infraestructura de IA

> **Estado:** Diseño. No hay Dockerfile, Compose ni ejecución asociada.

## Objetivo

El objetivo es ejecutar el servicio de inferencia de forma reproducible con Docker y Docker Compose, sin depender de la instalación del sistema anfitrión.

## Ventajas

- **Resiliencia:** arranque e inicialización del servicio de inferencia tras un reinicio del host.
- **Reproducibilidad:** infraestructura como código portable y desacoplada del sistema operativo base.
- **Persistencia:** modelos e imágenes en volúmenes montados.

## Descripción

Un entorno contenerizado sería aislado y reproducible, y se administraría y escalaría como una unidad. El trabajo se dedicaría a nuevas funcionalidades en lugar de a la instalación del servicio.

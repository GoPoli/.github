# GoPoli - Docker Environments

Este directorio contiene las configuraciones de **Docker Compose** para ejecutar **GoPoli** en las distintas etapas del ciclo de vida del proyecto. Cada entorno define los servicios, variables y redes según su propósito: demostración, desarrollo o producción.

Todas las imágenes se publican automáticamente en **GitHub Container Registry** desde el repositorio de cada componente.

---

## Estructura General

| Carpeta | Entorno | Propósito |
| --- | --- | --- |
| [`demo/`](demo/README.md) | Demostración | Ejecutar GoPoli completo en local con un solo comando, sin configurar nada. |
| [`dev/`](dev/README.md) | Desarrollo | Stack local con un archivo `.env` por servicio para ajustar la configuración. |
| [`production/`](production/README.md) | Producción | Solo API y PWA en un servidor; la base de datos vive en Neon. |

---

## Imágenes

| Servicio | Imagen | Repositorio | Puerto |
| --- | --- | --- | --- |
| `db-gopoli` | `ghcr.io/gopoli/gopoli-db:latest` | [GoPoli-DB](https://github.com/GoPoli/GoPoli-DB) | `5432` |
| `api-gopoli` | `ghcr.io/gopoli/gopoli-api:latest` | [GoPoli-API](https://github.com/GoPoli/GoPoli-API) | `8080` |
| `web-gopoli` | `ghcr.io/gopoli/gopoli-web:latest` | [GoPoli-Web](https://github.com/GoPoli/GoPoli-Web) | `3000` |

---

## Demo

**Ruta:** [`/docker/demo`](demo/README.md)

* Variables definidas directamente en el `docker-compose.yml`.
* Base de datos con esquema, catálogos y usuario demo.
* La API espera a que PostgreSQL esté `healthy` antes de arrancar.
* Ideal para **demostraciones**, **pruebas de integración** y **validaciones rápidas**.

---

## Desarrollo

**Ruta:** [`/docker/dev`](dev/README.md)

* Un archivo `.env` por servicio (`.env.db`, `.env.api`, `.env.web`), sin tocar el compose.
* Persistencia de PostgreSQL en el volumen `pg_data`.
* Dependencias explícitas entre servicios (`depends_on` con healthcheck).
* Misma exposición de puertos que en demo.

---

## Producción

**Ruta:** [`/docker/production`](production/README.md)

* Solo los contenedores esenciales: **API** y **PWA**.
* PostgreSQL gestionado en **Neon** (u otro proveedor).
* Reinicio automático de los contenedores (`restart: unless-stopped`).
* Pensado para ir detrás de un proxy reverso con HTTPS.

---

## Red y Volúmenes

| Elemento | Demo | Dev | Producción | Descripción |
| --- | --- | --- | --- | --- |
| `pg_data` | ✅ | ✅ | ❌ | Volumen persistente de PostgreSQL. |
| `network` | ✅ | ✅ | ✅ | Red bridge compartida entre servicios. |

---

## Nota sobre `NEXT_PUBLIC_API_URL`

La PWA se ejecuta en el navegador del usuario, así que `NEXT_PUBLIC_API_URL` debe ser una URL que **el navegador** pueda resolver: `http://localhost:8080` en local o el dominio público de la API en producción. El nombre interno `api-gopoli` solo existe dentro de la red de Docker y no sirve para la PWA.

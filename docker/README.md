# GoPoli - Docker Environments

Este directorio contiene las configuraciones de **Docker Compose** para ejecutar **GoPoli** en las distintas etapas del ciclo de vida del proyecto. Cada entorno define los servicios, variables y redes según su propósito: demostración, desarrollo o producción.

Todas las imágenes se publican automáticamente en **GitHub Container Registry** desde el repositorio de cada componente.

---

## Estructura General

| Carpeta | Entorno | Propósito |
| --- | --- | --- |
| [`demo/`](demo/README.md) | Demostración | Ejecutar GoPoli completo en local con un solo comando, sin configurar nada. |
| [`dev/`](dev/README.md) | Desarrollo | Stack local con un archivo `.env` por servicio para ajustar la configuración. |
| [`production/`](production/README.md) | Producción | Servidor detrás de Nginx con HTTPS; base incluida en red interna o externa (Neon). |

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
* Base de datos con esquema, catálogos y datos de demostración (`GOPOLI_SEED_DEMO=true`).
* La API espera a que PostgreSQL esté `healthy` antes de arrancar.
* Ideal para **demostraciones**, **pruebas de integración** y **validaciones rápidas**.

---

## Desarrollo

**Ruta:** [`/docker/dev`](dev/README.md)

* Un archivo `.env` por servicio (`.env.db`, `.env.api`, `.env.web`), sin tocar el compose.
* Persistencia de PostgreSQL en el volumen `pg_data`.
* Dependencias explícitas entre servicios (`depends_on` con healthcheck).
* Datos de demostración opcionales con `GOPOLI_SEED_DEMO` en `.env.db`.
* Misma exposición de puertos que en demo, solo en `127.0.0.1`.

---

## Producción

**Ruta:** [`/docker/production`](production/README.md)

* **API**, **PWA** y **PostgreSQL** (perfil `db`) o una base externa como **Neon** (sin perfil).
* La base vive en una red interna sin puertos publicados; API y PWA escuchan solo en `127.0.0.1` con puertos configurables (`GOPOLI_API_PORT`, `GOPOLI_WEB_PORT`).
* Sin datos de demostración, etiquetas de imagen fijables y scripts de actualización (`update_gopoli.sh`) y respaldo (`backup_gopoli.sh`).
* Pensado para ir detrás de Nginx con certificados de Let's Encrypt.

---

## Red y Volúmenes

| Elemento | Demo | Dev | Producción | Descripción |
| --- | --- | --- | --- | --- |
| `pg_data` | ✅ | ✅ | ✅ (perfil `db`) | Volumen persistente de PostgreSQL. |
| `network` | ✅ | ✅ | ❌ | Red bridge compartida entre servicios. |
| `backend` | ❌ | ❌ | ✅ | Red interna entre la API y PostgreSQL, sin salida a internet. |
| `frontend` | ❌ | ❌ | ✅ | Red de la API y la PWA con los puertos publicados en `127.0.0.1`. |

## Endurecimiento Común

Los tres entornos aplican el mismo perfil de seguridad a cada contenedor mediante el ancla `x-hardening`:

| Medida | Efecto |
| --- | --- |
| `read_only: true` + `tmpfs` | El contenedor no puede modificar su propia imagen; lo temporal vive en memoria |
| `cap_drop: [ALL]` | Sin capacidades de Linux |
| `no-new-privileges` | Ningún proceso puede escalar privilegios |
| `deploy.resources.limits` | Límites de CPU y memoria por servicio |
| `logging` `json-file` 10 MB × 3 | Los logs no llenan el disco |
| Puertos en `127.0.0.1` | Nada queda expuesto a la red sin un proxy delante |

---

## Nota sobre `NEXT_PUBLIC_API_URL`

La PWA se ejecuta en el navegador del usuario, así que `NEXT_PUBLIC_API_URL` debe ser una URL que **el navegador** pueda resolver: `http://localhost:8080` en local o el dominio público de la API en producción. El nombre interno `api-gopoli` solo existe dentro de la red de Docker y no sirve para la PWA.

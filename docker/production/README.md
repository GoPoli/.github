# **Despliegue de GoPoli en Producción con Docker**

Esta guía describe cómo desplegar el entorno **de producción** de GoPoli con Docker Compose. En producción solo corren la **API** y la **PWA**; PostgreSQL es un servicio gestionado externo para garantizar respaldos y disponibilidad.

---

## **Requisitos Previos**

* **Docker**: [Instrucciones de instalación](https://docs.docker.com/get-docker/)
* **Docker Compose v2**: [Instalación oficial](https://docs.docker.com/compose/install/)
* Una base PostgreSQL gestionada (recomendado: [Neon](https://github.com/GoPoli/GoPoli-DB/blob/main/docs/DATABASE_NEON.md)) con el esquema de GoPoli.

> [!NOTE]
> Se recomienda un servidor dedicado o una instancia cloud, detrás de un proxy reverso con HTTPS.

---

## **Arquitectura del Entorno**

| Servicio | Tipo | Ubicación |
| --- | --- | --- |
| API GoPoli | Contenedor Docker | Servidor principal |
| PWA GoPoli | Contenedor Docker | Servidor principal |
| PostgreSQL | Externo | Neon (u otro proveedor gestionado) |
| HTTPS | Proxy reverso | Nginx, Traefik o Caddy |

---

## **Archivos Requeridos**

* `docker-compose.yml`
* `.env.api`
* `.env.web`

```bash
base=https://raw.githubusercontent.com/GoPoli/.github/main/docker/production
curl -L $base/docker-compose.yml -o docker-compose.yml
curl -L $base/.env.api.example -o .env.api
curl -L $base/.env.web.example -o .env.web
```

| Archivo | Variable | Valor |
| --- | --- | --- |
| `.env.api` | `SPRING_DATASOURCE_URL` | URL JDBC de Neon con pooler y `?sslmode=require` |
| `.env.api` | `SPRING_DATASOURCE_USERNAME` / `SPRING_DATASOURCE_PASSWORD` | Credenciales de la base |
| `.env.api` | `GOPOLI_JWT_SECRET` | Secreto propio de producción (`openssl rand -base64 48`) |
| `.env.web` | `NEXT_PUBLIC_API_URL` | Dominio público de la API, por ejemplo `https://api.gopoli.app` |

> [!IMPORTANT]
> Nunca reutilices en producción el secreto JWT ni las contraseñas de los entornos demo o dev.

---

## **Ejecución del Entorno de Producción**

```bash
docker compose -p gopoli up -d
```

Actualizar a la última versión publicada:

```bash
docker compose -p gopoli pull
docker compose -p gopoli up -d
```

Detener:

```bash
docker compose -p gopoli down
```

> [!TIP]
> Para fijar una versión concreta, reemplaza `latest` por una etiqueta `sha-<commit>` o `X.Y.Z` publicada en GHCR. Así un despliegue es reproducible y se puede revertir.

---

## **Servicios del Entorno**

### 1. **API GoPoli (Backend)**

```yaml
api-gopoli:
  image: ghcr.io/gopoli/gopoli-api:latest
  container_name: gopoli-api
  restart: unless-stopped
  ports:
    - "8080:8080"
  env_file:
    - .env.api
```

* **Puerto:** `8080`
* **Dependencias externas:** PostgreSQL (Neon)

### 2. **Web GoPoli (PWA)**

```yaml
web-gopoli:
  image: ghcr.io/gopoli/gopoli-web:latest
  container_name: gopoli-web
  restart: unless-stopped
  ports:
    - "3000:3000"
  env_file:
    - .env.web
```

* **Puerto:** `3000`
* **Configuración:** `NEXT_PUBLIC_API_URL` se inyecta al arrancar el contenedor.

---

## **Red**

```yaml
networks:
  network:
    driver: bridge
```

---

## **Acceso al Entorno**

* **API GoPoli:** `http://<host>:8080`
* **PWA GoPoli:** `http://<host>:3000`

> [!TIP]
> Publica ambos servicios detrás de un proxy reverso con certificados TLS (por ejemplo `api.tu-dominio` → `:8080` y `app.tu-dominio` → `:3000`). La PWA necesita HTTPS para registrar el service worker y poder instalarse.

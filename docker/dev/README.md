# **Despliegue de GoPoli en Dev con Docker**

Esta guía describe cómo levantar el entorno **Dev** de GoPoli con Docker Compose. Es igual al demo, pero cada servicio lee su configuración de un archivo `.env` propio, de modo que puedes cambiar credenciales, secretos o la URL de la API sin tocar el compose.

---

## **Requisitos Previos**

* **Docker**: [Instrucciones de instalación](https://docs.docker.com/get-docker/)
* **Docker Compose v2**: [Instrucciones oficiales](https://docs.docker.com/compose/install/)

---

## **Archivos Necesarios**

En el mismo directorio deben estar:

* `docker-compose.yml`
* `.env.db`
* `.env.api`
* `.env.web`

Descárgalos con sus plantillas:

```bash
base=https://raw.githubusercontent.com/GoPoli/.github/main/docker/dev
curl -L $base/docker-compose.yml -o docker-compose.yml
curl -L $base/.env.db.example -o .env.db
curl -L $base/.env.api.example -o .env.api
curl -L $base/.env.web.example -o .env.web
```

Luego reemplaza los valores entre `< >`:

| Archivo | Variable | Qué poner |
| --- | --- | --- |
| `.env.db` | `POSTGRES_PASSWORD` | Contraseña de la base local |
| `.env.db` | `GOPOLI_SEED_DEMO` | `true` para crear las cuentas de demostración en el primer arranque |
| `.env.api` | `SPRING_DATASOURCE_PASSWORD` | La misma contraseña de `.env.db` |
| `.env.api` | `GOPOLI_JWT_SECRET` | Secreto de al menos 32 caracteres (`openssl rand -base64 48`) |
| `.env.web` | `NEXT_PUBLIC_API_URL` | URL de la API vista desde el navegador (`http://localhost:8080`) |

> [!IMPORTANT]
> Los archivos `.env.*` contienen secretos. No los subas a ningún repositorio.

---

## **Ejecución del Entorno**

```bash
docker compose -p gopoli up -d
```

Para detenerlo:

```bash
docker compose -p gopoli down
```

Para ver los logs de un servicio:

```bash
docker compose -p gopoli logs -f api-gopoli
```

---

## **Descripción de Servicios**

### 1. **Base de Datos (PostgreSQL)**

```yaml
db-gopoli:
  image: ghcr.io/gopoli/gopoli-db:latest
  container_name: gopoli-db
  ports:
    - "127.0.0.1:5432:5432"
  env_file:
    - .env.db
  volumes:
    - pg_data:/var/lib/postgresql/data
```

* **Puerto externo:** `5432`
* **Datos persistentes:** volumen `pg_data`
* **Configuración:** `.env.db`
* **Datos de demostración:** con `GOPOLI_SEED_DEMO=true` crea `demo.local@elpoli.edu.co`, `conductor.demo@elpoli.edu.co` y `pasajera.demo@elpoli.edu.co` (contraseña `gopoli-local-dev`)

### 2. **API GoPoli (Backend)**

```yaml
api-gopoli:
  image: ghcr.io/gopoli/gopoli-api:latest
  container_name: gopoli-api
  ports:
    - "127.0.0.1:8080:8080"
  env_file:
    - .env.api
  depends_on:
    db-gopoli:
      condition: service_healthy
```

* **Puerto externo:** `8080`
* **Depende de:** `db-gopoli` en estado `healthy`
* **Configuración:** `.env.api` (variables documentadas en [GoPoli-API](https://github.com/GoPoli/GoPoli-API#variables-de-entorno))

### 3. **Web GoPoli (PWA)**

```yaml
web-gopoli:
  image: ghcr.io/gopoli/gopoli-web:latest
  container_name: gopoli-web
  ports:
    - "127.0.0.1:3000:3000"
  env_file:
    - .env.web
```

* **Puerto externo:** `3000`
* **Configuración:** `.env.web`; la URL de la API se inyecta al arrancar el contenedor.

---

## **Acceso a los Servicios**

* **PWA GoPoli** → `http://localhost:3000`
* **API GoPoli** → `http://localhost:8080/health`
* **PostgreSQL** → `postgresql://gopoli:<password>@localhost:5432/gopoli`

Los puertos se publican solo en `127.0.0.1`. Los contenedores corren con el mismo endurecimiento que producción: solo lectura, sin capacidades, `no-new-privileges`, límites de recursos y rotación de logs.

---

## **Desarrollar un componente contra el stack**

Para trabajar en un solo componente con recarga en caliente, levanta el resto con Docker y ejecuta ese componente desde su repositorio:

```bash
docker compose -p gopoli up -d db-gopoli api-gopoli
```

Y en el repositorio de la PWA:

```bash
pnpm install
pnpm dev
```

Del mismo modo, para trabajar en la API levanta solo `db-gopoli` y ejecuta `./mvnw spring-boot:run` en GoPoli-API.

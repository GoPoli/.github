# **Demostración de GoPoli con Docker**

Esta guía describe cómo levantar GoPoli completo en tu equipo con Docker Compose: base de datos, API y PWA, sin configurar variables.

## **Requisitos Previos**

- **Docker**: [Instrucciones de instalación](https://docs.docker.com/get-docker/)
- **Docker Compose v2**: incluido en Docker Desktop. En Linux sigue las [instrucciones oficiales](https://docs.docker.com/compose/install/).

> [!NOTE]
> Antes de empezar, asegúrate de que Docker esté en ejecución. Con Docker Desktop, ábrelo y espera a que termine de iniciar.

---

## **Opción 1: Ejecución Rápida con un Solo Comando**

```bash
curl -L https://raw.githubusercontent.com/GoPoli/.github/main/docker/demo/compose.yaml -o compose.yaml && docker compose -p gopoli up -d
```

Este comando:

1. **Descarga** el `compose.yaml` del entorno demo.
2. **Levanta** los contenedores en segundo plano (`-d`) bajo el proyecto `gopoli`.

Servicios disponibles:

- **PWA GoPoli**: [http://localhost:3000](http://localhost:3000)
- **API GoPoli**: [http://localhost:8080/health](http://localhost:8080/health)
- **PostgreSQL**: `postgresql://gopoli:gopoli@localhost:5432/gopoli`

Inicia sesión con cualquiera de las cuentas de demostración (contraseña `gopoli-local-dev`):

| Correo | Rol |
| --- | --- |
| `demo.local@elpoli.edu.co` | Pasajera con historial y ruta habitual |
| `conductor.demo@elpoli.edu.co` | Conductor con vehículo y un viaje activo con chat |
| `pasajera.demo@elpoli.edu.co` | Pasajera unida a los viajes de ejemplo |

Para detener todo:

```bash
docker compose -p gopoli down
```

---

## **Opción 2: Ejecución Paso a Paso**

#### **Paso 1: Descargar el archivo de Compose**

```bash
curl -L https://raw.githubusercontent.com/GoPoli/.github/main/docker/demo/compose.yaml -o compose.yaml
```

#### **Paso 2: Descargar las imágenes**

```bash
docker pull ghcr.io/gopoli/gopoli-db:latest
docker pull ghcr.io/gopoli/gopoli-api:latest
docker pull ghcr.io/gopoli/gopoli-web:latest
```

> [!TIP]
> Si los paquetes de la organización son privados, inicia sesión antes con `docker login ghcr.io` usando un token de GitHub con permiso `read:packages`.

#### **Paso 3: Iniciar los servicios**

```bash
docker compose -p gopoli up -d
```

- **`-p gopoli`** da nombre al proyecto y, con él, a la red y al volumen.
- **`up -d`** levanta los contenedores en segundo plano.

#### **Paso 4: Verificar**

```bash
docker compose -p gopoli ps
curl http://localhost:8080/health
curl http://localhost:8080/programs
```

La base aparece como `healthy` cuando terminó de crear el esquema; recién entonces arranca la API.

#### **Paso 5: Detener y limpiar**

```bash
docker compose -p gopoli down
```

Para borrar también los datos de PostgreSQL:

```bash
docker compose -p gopoli down -v
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
  environment:
    POSTGRES_DB: gopoli
    POSTGRES_USER: gopoli
    POSTGRES_PASSWORD: gopoli
    GOPOLI_SEED_DEMO: "true"
  volumes:
    - pg_data:/var/lib/postgresql/data
```

- Crea 13 tablas y carga catálogos, ubicaciones y los datos de demostración en el primer arranque.
- El volumen `pg_data` conserva los datos entre reinicios.

### 2. **API (Spring Boot)**

```yaml
api-gopoli:
  image: ghcr.io/gopoli/gopoli-api:latest
  container_name: gopoli-api
  ports:
    - "127.0.0.1:8080:8080"
  depends_on:
    db-gopoli:
      condition: service_healthy
```

- Se conecta a `db-gopoli` por la red interna.
- Usa un secreto JWT de demostración; **no** reutilices este archivo en entornos compartidos.

### 3. **PWA (Next.js)**

```yaml
web-gopoli:
  image: ghcr.io/gopoli/gopoli-web:latest
  container_name: gopoli-web
  ports:
    - "127.0.0.1:3000:3000"
  environment:
    NEXT_PUBLIC_API_URL: http://localhost:8080
```

- `NEXT_PUBLIC_API_URL` apunta al puerto publicado en tu equipo, porque es el navegador quien llama a la API.

### 4. **Volúmenes y Red**

```yaml
volumes:
  pg_data:

networks:
  network:
    driver: bridge
```

### 5. **Endurecimiento**

Aunque es un entorno de demostración, los tres contenedores corren con sistema de archivos de solo lectura, sin capacidades de Linux, con `no-new-privileges`, límites de CPU y memoria y rotación de logs. Los puertos solo se publican en `127.0.0.1`, así que nada queda expuesto a la red local.

# GoPoli

🇺🇸 English: [Read in English](README.md)

GoPoli es una aplicación de viaje compartido entre estudiantes: **PWA Next.js** (`web/`), API **Spring Boot** (`backend/`) y **PostgreSQL**.

## Tabla de Contenido
- [Características](#características)
- [Instalación](#instalación)
- [El proceso](#el-proceso)
  - [Tecnologías utilizadas](#tecnologías-utilizadas)
  - [Estructura del proyecto](#estructura-del-proyecto)
- [Licencia](#licencia)
- [Autores](#autores)

---

## Características
- Inicio de sesión
- Registro de estudiantes
- Consulta de carreras
- Viajes compartidos (crear, unirse, gestionar)
- Mapa (OpenStreetMap / Leaflet) y rutas en auto (OSRM)
- Consumo de API REST
- Integración con Railway / Neon
- Soporte con base de datos PostgreSQL
- PWA instalable

---

## Instalación

### Backend + base de datos
```bash
git clone https://github.com/MaicolD0930/GoPoli
cd GoPoli/backend
# Configura SPRING_DATASOURCE_* (ver DATABASE_NEON.md o backend/DOCKER_DB.md)
./mvnw spring-boot:run
```

### PWA web
```bash
cd GoPoli/web
cp .env.example .env.local   # define NEXT_PUBLIC_API_URL
npm install
npm run dev
```

Abre [http://localhost:3000](http://localhost:3000). Despliegue: [`web/DEPLOYMENT.md`](web/DEPLOYMENT.md), [`DEPLOY_RAILWAY.md`](DEPLOY_RAILWAY.md).

## El proceso

### Tecnologías utilizadas
- Next.js (PWA)
- Spring Boot
- PostgreSQL
- Railway / Neon

### Estructura del proyecto
```text
GoPoli/
├── backend/
│   ├── src/
│   ├── pom.xml
│   └── mvnw
│
├── web/
│   ├── src/
│   │   ├── app/
│   │   └── features/
│   ├── public/
│   └── package.json
```

La arquitectura del proyecto está dividida en dos módulos principales:

- **backend/**: API REST desarrollada con Spring Boot (PostgreSQL).
- **web/**: PWA Next.js (App Router + TypeScript). Mapa: OpenStreetMap (Leaflet); rutas: OSRM.

Dentro de `web/`, las features se organizan por dominio (`auth`, `mapa`, `perfil`, etc.) en `src/features/`, con páginas del App Router en `src/app/`.

---

## Recursos útiles
- [Next.js Docs](https://nextjs.org/docs)
- [Spring Boot Docs](https://spring.io/projects/spring-boot)
- [Railway Docs](https://docs.railway.app/)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)

---

## Licencia
Este proyecto es para fines académicos y educativos.

---

## Autores
- Michael Daniel (MaicolD0930)
- Jorge Martinez (GeorgeAMS)
- Marian Lasney

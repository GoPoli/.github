# GoPoli

🇪🇸 Español: [Leer en español](README_ES.md)

GoPoli is a student ride-sharing app built as a **Next.js PWA** (`web/`), a **Spring Boot** REST API (`backend/`), and **PostgreSQL**.

## Table of Contents
- [Features](#features)
- [Installation](#installation)
- [The process](#the-process)
  - [Built with](#built-with)
  - [Project structure](#project-structure)
- [License](#license)
- [Author](#author)

---

## Features
- User login
- Student registration
- Career consultation
- Shared trips (create, join, manage)
- Map (OpenStreetMap / Leaflet) and driving routes (OSRM)
- REST API consumption
- Railway / Neon integration
- PostgreSQL database support
- Installable PWA

---

## Installation

### Backend + database
```bash
git clone https://github.com/MaicolD0930/GoPoli
cd GoPoli/backend
# Configure SPRING_DATASOURCE_* (see DATABASE_NEON.md or backend/DOCKER_DB.md)
./mvnw spring-boot:run
```

### Web PWA
```bash
cd GoPoli/web
cp .env.example .env.local   # set NEXT_PUBLIC_API_URL
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000). Deploy notes: [`web/DEPLOYMENT.md`](web/DEPLOYMENT.md), [`DEPLOY_RAILWAY.md`](DEPLOY_RAILWAY.md).

## The process

### Built with
- Next.js (PWA)
- Spring Boot
- PostgreSQL
- Railway / Neon

### Project structure
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

The project architecture is divided into two main modules:

- **backend/**: REST API developed with Spring Boot (PostgreSQL).
- **web/**: Next.js PWA (App Router + TypeScript). Map: OpenStreetMap (Leaflet); routes: OSRM.

Inside `web/`, features are organized by domain (`auth`, `mapa`, `perfil`, etc.) under `src/features/`, with App Router pages in `src/app/`.

## License
This project is for academic and educational purposes.

## Author
- Michael Daniel (MaicolD0930)
- Jorge Martinez (GeorgeAMS)
- Marian Lasney

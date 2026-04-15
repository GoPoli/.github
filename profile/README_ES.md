# GoPoli

🇺🇸 English: [Read in English](README.md)

GoPoli es una aplicación móvil desarrollada con **Flutter** para el frontend y **Spring Boot** para el backend.

## Tabla de Contenido
- [Demo](#demo)
- [Características](#características)
- [Instalación](#instalación)
- [El proceso](#el-proceso)
  - [Tecnologías utilizadas](#tecnologías-utilizadas)
  - [Estructura del proyecto](#estructura-del-proyecto)
- [Recursos útiles](#recursos-útiles)
- [Licencia](#licencia)
- [Autores](#autores)

---

## Demo
APK disponible en:

`frontend/build/app/outputs/flutter-apk/app-release.apk`

---

## Características
- Inicio de sesión
- Registro de estudiantes
- Consulta de carreras
- Consumo de API REST
- Integración con Railway
- Soporte con base de datos PostgreSQL

---

## Instalación
```bash
git clone https://github.com/MaicolD0930/GoPoli
cd GoPoli/frontend
flutter pub get
flutter run
```

## El proceso

### Tecnologías utilizadas
- Flutter
- Spring Boot
- Railway
- PostgreSQL

### Estructura del proyecto
```text
GoPoli/
├── backend/
│   ├── src/
│   ├── pom.xml
│   └── mvnw
│
├── frontend/
│   ├── lib/
│   │   ├── assets/
│   │   ├── config/
│   │   ├── models/
│   │   ├── pages/
│   │   ├── utils/
│   │   └── main.dart
│   │
│   ├── android/
│   ├── ios/
│   └── pubspec.yaml
```

La arquitectura del proyecto está dividida en dos módulos principales:

- **backend/**: API REST desarrollada con Spring Boot.
- **frontend/**: Aplicación móvil desarrollada con Flutter.

Dentro del frontend, la carpeta `lib/` se organiza por responsabilidades:
- `config/` → Configuración global
- `models/` → Modelos de datos
- `pages/` → Pantallas de navegación
- `utils/` → Funciones auxiliares y validaciones
- `assets/` → Imágenes y recursos estáticos

---

## Recursos útiles
- [Flutter Documentation](https://docs.flutter.dev/)
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
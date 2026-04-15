# GoPoli

🇪🇸 Español: [Leer en español](README_ES.md)

GoPoli is a mobile application developed with **Flutter** for the frontend and **Spring Boot** for the backend.

## Table of Contents
- [Demo](#demo)
- [Features](#features)
- [Installation](#installation)
- [The process](#the-process)
  - [Built with](#built-with)
  - [Project structure](#project-structure)
- [Useful resources](#useful-resources)
- [License](#license)
- [Author](#author)

---

## Demo
APK available at:

`frontend/build/app/outputs/flutter-apk/app-release.apk`

---

## Features
- User login
- Student registration
- Career consultation
- REST API consumption
- Railway integration
- PostgreSQL database support

---

## Installation
```bash
git clone https://github.com/MaicolD0930/GoPoli
cd GoPoli/frontend
flutter pub get
flutter run
```

## The process

### Built with
- Flutter
- Spring Boot
- Railway
- PostgreSQL

### Project structure
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
│   │   └── main.dart
│   │
│   ├── android/
│   ├── ios/
│   └── pubspec.yaml
```

The project architecture is divided into two main modules:

- **backend/**: REST API developed with Spring Boot.
- **frontend/**: Mobile application developed with Flutter.

Inside the frontend, the `lib/` folder is organized by responsibilities:
- `config/` → Global configuration
- `models/` → Data models
- `pages/` → Navigation screens
- `utils/` → Helper functions and validations
- `assets/` → Images and static resources

## License
This project is for academic and educational purposes.

## Author
- Michael Daniel (MaicolD0930)
- Jorge Martinez (GeorgeAMS)

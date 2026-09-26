# GoPoli environment

## GoPoli - Guía de Ejecución

Este repositorio es el repositorio especial `.github` de la organización **GoPoli**. Reúne los entornos para ejecutar el sistema completo, los manuales de instalación y los archivos de comunidad que se aplican a todos los repositorios.

### Opciones de Ejecución

- **Ejecutar con Docker**: para una ejecución rápida con Docker Compose, sigue la guía [Docker](docker/README.md).
- **Ejecutar con Kubernetes**: para desplegar en Docker Desktop o Minikube, sigue la guía de [Kubernetes](kubernetes/README.md).
- **Publicar en un servidor**: con dominio, Nginx y HTTPS, sigue la guía de [producción](docker/production/README.md).
- **Manual completo**: desarrollo local, nube y solución de problemas en el [Manual de Instalación](docs/INSTALACION.md).

Ejecución rápida:

```bash
curl -L https://raw.githubusercontent.com/GoPoli/.github/main/docker/demo/compose.yaml -o compose.yaml && docker compose -p gopoli up -d
```

## Estructura del Proyecto

GoPoli está compuesto por tres servicios, cada uno en su propio repositorio y con su imagen publicada en GitHub Container Registry:

- **PostgreSQL** ([GoPoli-DB](https://github.com/GoPoli/GoPoli-DB)): la base de datos con usuarios, catálogos, viajes y mensajes.
- **API GoPoli** ([GoPoli-API](https://github.com/GoPoli/GoPoli-API)): el backend Spring Boot que expone los endpoints REST y autentica con JWT.
- **Aplicación Web** ([GoPoli-Web](https://github.com/GoPoli/GoPoli-Web)): la PWA Next.js que consume la API y muestra el mapa, los viajes y el chat.

La app Flutter original se conserva archivada en [GoPoli-Mobile](https://github.com/GoPoli/GoPoli-Mobile).

## Contenido del Repositorio

```text
.github/
├── .github/
│   ├── ISSUE_TEMPLATE/              # Plantillas de issues para toda la organización
│   └── PULL_REQUEST_TEMPLATE.md     # Plantilla de pull request para toda la organización
├── docker/
│   ├── demo/                        # Stack completo sin configuración
│   ├── dev/                         # Stack completo con un .env por servicio
│   └── production/                  # Servidor con Nginx: DB interna o externa, scripts de actualización y respaldo
├── docs/
│   ├── INSTALACION.md               # Manual de instalación
│   ├── CI_CD.md                     # Pipelines, GHCR y configuración de la organización
│   ├── MATRIZ_TRAZABILIDAD_GOPOLIGO.md
│   ├── MIGRATION_PLAN.md
│   ├── GOPOLIGO-TALLER.docx
│   └── GOPOLI-TALLER .pdf
├── kubernetes/
│   └── k8s-deployment.yml           # Namespace restringido, base, API, PWA y NetworkPolicy
├── profile/
│   ├── README.md                    # Página de la organización
│   └── README_EN.md
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md
├── SECURITY.md
└── LICENSE
```

## Archivos de Comunidad

`CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `SECURITY.md` y las plantillas de `.github/` se muestran automáticamente en cada repositorio de la organización que no defina los suyos. Mantenerlos aquí evita duplicarlos en cada componente.

## Licencia

Este proyecto está bajo la licencia MIT. Consulta el archivo [LICENSE](LICENSE) para más detalles.

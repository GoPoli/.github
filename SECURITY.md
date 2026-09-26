# GoPoli Security Policies and Procedures

Este documento describe los procedimientos de seguridad y las políticas generales para los repositorios de la organización **GoPoli**.

- [Versiones soportadas](#versiones-soportadas)
- [Reportar una Vulnerabilidad](#reportar-una-vulnerabilidad)
- [Política de Divulgación](#política-de-divulgación)
- [Buenas prácticas del proyecto](#buenas-prácticas-del-proyecto)

## Versiones soportadas

Solo la rama `main` de cada repositorio y las imágenes `latest` publicadas en GitHub Container Registry reciben correcciones de seguridad.

| Componente | Imagen | Soportada |
| --- | --- | --- |
| GoPoli-API | `ghcr.io/gopoli/gopoli-api:latest` | :white_check_mark: |
| GoPoli-Web | `ghcr.io/gopoli/gopoli-web:latest` | :white_check_mark: |
| GoPoli-DB | `ghcr.io/gopoli/gopoli-db:latest` | :white_check_mark: |

## Reportar una Vulnerabilidad

El equipo de **GoPoli** toma en serio todas las vulnerabilidades. **No abras un issue público.** Repórtala de forma privada desde el repositorio afectado:

1. Abre la pestaña **Security** del repositorio.
2. Pulsa **Report a vulnerability**.
3. Describe el problema, los pasos para reproducirlo, el impacto y, si puedes, una propuesta de corrección.

El equipo confirmará la recepción en un plazo de 72 horas y te mantendrá al tanto del avance hasta la corrección y su anuncio.

Para vulnerabilidades en dependencias de terceros, repórtalas también a los mantenedores de esa dependencia.

## Política de Divulgación

Al recibir un reporte, el equipo asignará una persona responsable que coordinará la corrección:

* Confirmar el problema y determinar las versiones afectadas.
* Auditar el código en busca de problemas similares.
* Preparar y publicar la corrección lo antes posible, junto con una nueva imagen en GHCR.
* Publicar un aviso de seguridad (GitHub Security Advisory) una vez corregido.

## Buenas prácticas del proyecto

* Los secretos (`GOPOLI_JWT_SECRET`, credenciales de PostgreSQL) solo viven en variables de entorno de la API; nunca en el código ni en la PWA.
* La PWA guarda el JWT únicamente en memoria.
* Las contraseñas se almacenan con BCrypt.
* Los volcados de base de datos (`*.dump`, `*.backup`) nunca se versionan.
* CodeQL, Dependabot y la revisión de dependencias están activos en cada repositorio.

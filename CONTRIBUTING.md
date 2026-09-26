# Guía de Contribución

Gracias por aportar a **GoPoli**. Esta guía aplica a todos los repositorios de la organización.

## Repositorios

| Repositorio | Contenido | Stack |
| --- | --- | --- |
| [GoPoli-API](https://github.com/GoPoli/GoPoli-API) | API REST | Java 17, Spring Boot 4, JPA |
| [GoPoli-Web](https://github.com/GoPoli/GoPoli-Web) | PWA | Next.js 16, React 19, TypeScript |
| [GoPoli-DB](https://github.com/GoPoli/GoPoli-DB) | Base de datos | PostgreSQL 16 |
| [.github](https://github.com/GoPoli/.github) | Entornos, documentación y archivos de comunidad | Docker Compose, Kubernetes |

Abre el issue o el pull request en el repositorio del componente que cambias. Si el cambio toca varios componentes (por ejemplo, un endpoint nuevo en la API y su pantalla en la PWA), abre un pull request en cada repositorio y enlázalos entre sí.

## Flujo de trabajo

1. Crea un issue describiendo el problema o la mejora, salvo en cambios triviales.
2. Crea una rama desde `main`:

   | Tipo | Prefijo | Ejemplo |
   | --- | --- | --- |
   | Funcionalidad | `feature/` | `feature/calificaciones-conductor` |
   | Corrección | `fix/` | `fix/validacion-placa` |
   | Documentación | `docs/` | `docs/guia-neon` |
   | Infraestructura | `ci/` | `ci/cache-maven` |

3. Haz commits pequeños y descriptivos.
4. Abre un pull request hacia `main` completando la plantilla.
5. Espera a que pasen los checks (CI, CodeQL, revisión de dependencias) y a la revisión de al menos una persona del equipo.
6. Integra con **Squash and merge** o **Rebase and merge** para mantener un historial lineal.

## Mensajes de commit

Escribe en español, en tercera persona del presente y con punto final, describiendo qué hace el cambio:

```text
Valida la placa del vehículo antes de registrar al conductor.
```

Si el trabajo fue en pareja, agrega a la otra persona como coautora al final del mensaje:

```text
Co-authored-by: Nombre Apellido <correo@ejemplo.com>
```

## Estándares por componente

### GoPoli-API

- Ejecuta `./mvnw verify` antes de abrir el pull request.
- Cubre con pruebas unitarias las reglas de negocio nuevas (`policy/`, `security/`) y los controladores que cambies.
- Toda configuración nueva se expone como variable de entorno en `application.properties` y se documenta en el README.

### GoPoli-Web

- Ejecuta `pnpm lint`, `pnpm typecheck`, `pnpm test` y `pnpm build`.
- Instala dependencias con `pnpm install`; el `pnpm-lock.yaml` se versiona y la CI usa `--frozen-lockfile`.
- Cada dominio vive en `src/features/<dominio>` con su vista, su cliente HTTP y sus tipos.
- Nunca guardes el JWT en `localStorage` ni pongas secretos en variables `NEXT_PUBLIC_*`.

### GoPoli-DB

- GoPoli-DB es la fuente de verdad del esquema: los cambios van en `init/01_schema.sql` y la API solo lo valida (`ddl-auto=validate`).
- Los catálogos van en `init/02_catalogs.sql` y los datos de ejemplo en `demo/demo_data.sql`, nunca mezclados.
- El workflow de CI levanta la imagen con y sin datos de demostración; mantenlo en verde.

## Idioma

| Elemento | Idioma |
| --- | --- |
| Código, identificadores, nombres de archivos, rutas y tablas | Inglés |
| Textos de la interfaz, mensajes de error de la API y logs | Español (Colombia) |
| Comentarios | Español, solo cuando el porqué no es evidente |

## Documentación

La documentación vive en los `README.md` y en la carpeta `docs/` de cada repositorio, no en comentarios del código. Si tu cambio altera la instalación, la configuración o un endpoint, actualiza la documentación en el mismo pull request.

## Seguridad

No abras issues públicos para vulnerabilidades. Sigue la [política de seguridad](SECURITY.md).

## Código de conducta

Al participar aceptas el [Código de Conducta](CODE_OF_CONDUCT.md).

# Plan de migración: GoPoli → Next.js PWA (completado)

Documento de referencia tras migrar el cliente a la PWA. El stack actual es **Next.js (`web/`) + Spring Boot (`backend/`) + PostgreSQL**. El cliente móvil anterior (Flutter en `frontend/`) ya no forma parte del producto documentado.

---

## 1. Qué es GoPoli y cómo funciona

GoPoli es una app académica de **viaje compartido entre estudiantes** (contexto Poli / `@elpoli.edu.co`). El usuario se registra, inicia sesión con JWT, crea o se une a **servicios/grupos de viaje** entre ubicaciones del campus/ciudad, ve la ruta en un mapa, gestiona el grupo (iniciar / finalizar / cancelar / salir) y administra su perfil (foto, conductor con vehículo, historial, inhabilitar o eliminar cuenta).

### Arquitectura actual

| Capa | Tecnología | Ubicación |
|------|------------|-----------|
| Cliente PWA | Next.js (App Router) + TypeScript + React | `web/` |
| API REST | Spring Boot 4 + JPA + PostgreSQL | `backend/` |
| BD | PostgreSQL local, Neon o Railway | Ver `DATABASE_NEON.md`, `DEPLOY_RAILWAY.md`, `backend/DOCKER_DB.md` |
| Auth | JWT (jjwt) en header `Authorization: Bearer …` | `JwtService.java` + sesión en cliente (`web/src/features/auth`) |
| Mapa / rutas | OpenStreetMap (Leaflet) + OSRM | Features de mapa en `web/` |

Flujo de arranque (PWA):

1. Entrada en `src/app/page.tsx` / layout autenticado.
2. Si hay JWT en sesión de cliente → shell principal.
3. Si no → `/login`.

Navegación autenticada (layout `(main)`): secciones de mapa, buscar, viajes, perfil (y rutas relacionadas: grupo, servicio nuevo, mensajes, agenda según el App Router).

**El backend Spring Boot permanece.** La PWA consume la misma API REST. No se reemplaza Spring Boot ni Neon/Railway.

---

## 2. Estructura de carpetas

```
GoPoli/
├── backend/          # Spring Boot
├── web/              # Next.js PWA
├── scripts/
├── DATABASE_NEON.md
├── DEPLOY_RAILWAY.md
└── README.md / README_ES.md
```

### PWA (`web/`)

```
web/
├── public/                 # iconos PWA, favicon, sw.js
├── src/
│   ├── app/                # App Router (auth + main)
│   ├── features/           # auth, mapa, perfil, servicios, …
│   ├── components/         # UI compartida
│   └── …                   # types, utils, config
├── package.json
└── next.config.ts
```

### Backend Java (`backend/src/main/java/com/proyect/gopoli/`)

```
controller/   AuthController, UsuarioController, CatalogoController, ServicioController, …
dto/          UsuarioDto, VehiculoDto, LoginResponse
model/        Usuario, Vehiculo, Servicio, ServicioUsuario, Ubicacion, Carrera, …
repository/   *Repository (Spring Data JPA)
security/     JwtService
config/       UbicacionCoordenadasSeeder
util/         VehicleValidator
```

---

## 3. Pantallas / rutas (PWA)

| Pantalla | Ruta aproximada |
|----------|-----------------|
| Login | `/login` |
| Registro | `/registro` |
| Mapa / inicio | `/mapa` (u equivalente en `(main)`) |
| Buscar viajes | `/buscar` |
| Viajes | `/viajes` |
| Perfil | `/perfil` |
| Crear servicio | `/servicio/nuevo` |
| Detalle de grupo | `/grupo/[id]` |
| Editar perfil | `/perfil/editar` |
| Registro conductor | `/perfil/conductor` |
| Historial | `/perfil/historial` |

**No existe en producto:** recuperación de contraseña, onboarding aparte, pagos, notificaciones push, pantallas de admin.

Detalle de arranque local y PWA: [`web/README.md`](web/README.md). Despliegue: [`web/DEPLOYMENT.md`](web/DEPLOYMENT.md).

---

## 4. Modelos de datos (API / Java)

| Entidad / DTO | Campos / notas |
|---------------|----------------|
| `Usuario` / `UsuarioDto` | `idUsuario`, `correo`, `nombre`, `tel?`, carrera, tipo, estado, foto, `isDriver`, `vehiculo?` (DTO sin contraseña) |
| `Vehiculo` / `VehiculoDto` | marca, modelo, color, placa |
| `Carrera` | catálogo |
| `LoginResponse` | `token` + usuario |
| `Servicio` | fecha, descripción, salida/llegada, hora, creador, tipo, estado, capacidad |
| `Ubicacion` | nombre, latitud, longitud |
| `ServicioUsuario` | rol Creador/Miembro; participación passenger/driver |
| Historial | viajes finalizados (máx. 10) con participantes |

Constantes de negocio (`GoPoliConstants.java`):

- Tipo usuario: pasajero `1`, conductor `2`
- Tipo servicio: grupo pasajeros `1`, grupo conductor `3`
- Estado servicio: activo `1`, cancelado `2`, finalizado `3`, en curso `4`
- Roles grupo: `"Creador"` / `"Miembro"`; participación: `"passenger"` / `"driver"`

---

## 5. APIs REST (cliente → backend)

**Base URL:** `NEXT_PUBLIC_API_URL` (sin barra final). Ver `web/.env.example`.

Cabeceras típicas: `Content-Type: application/json`; endpoints de usuario autenticados añaden `Authorization: Bearer <token>`.  
Algunas llamadas de viaje pueden no exigir Bearer en el controlador actual (riesgo documentado abajo).

| Método | Path | Auth Bearer |
|--------|------|-------------|
| POST | `/register` | No |
| POST | `/login` | No |
| GET | `/carreras` | No |
| GET | `/ubicaciones` | No |
| GET / PUT | `/usuario/me` | Sí |
| PUT | `/usuario/me/foto` | Sí |
| POST | `/usuario/me/register-driver` / `unregister-driver` | Sí |
| GET | `/usuario/me/historial-viajes` | Sí |
| POST | `/usuario/me/inhabilitar` | Sí |
| DELETE | `/usuario/me` | Sí |
| POST | `/servicio/crear` | No* |
| GET | `/servicios/activos` | No* |
| POST | `/servicio/unirse` | No* |
| GET | `/servicio/{id}` / `…/miembros` | No* |
| PUT | `/servicio/cancelar|iniciar|finalizar/{id}` | No* |
| DELETE | `/servicio/salir/{idServicio}/{idUsuario}` | No* |
| GET | `/servicio/usuario/activo|miembro|encurso/{idUsuario}` | No* |

\*Sin validación JWT en el controlador actual.

Cuerpo de creación de servicio (orientativo):

```json
{
  "fecha": "YYYY-MM-DD",
  "descripcion": "...",
  "idLugarSalida": 1,
  "idLugarLlegada": 2,
  "horaSalida": "HH:mm:ss",
  "idCreador": 1,
  "idTipoServicio": 1,
  "capacidad": 3
}
```

### Controladores

| Controlador | Endpoints |
|-------------|-----------|
| `AuthController` | `POST /register`, `POST /login` |
| `UsuarioController` | `/usuario/...` |
| `CatalogoController` | `GET /carreras`, `GET /ubicaciones` |
| `ServicioController` | crear, cancelar, iniciar, finalizar, unirse, salir, miembros, activos, consultas por usuario |

CORS: `@CrossOrigin(origins = "*")` en controladores (restringir en producción cuando se decida).

---

## 6. Autenticación (PWA)

| Aspecto | Implementación |
|---------|----------------|
| Login | `POST /login` → token + usuario |
| Logout | Solo cliente (limpia sesión y navega a `/login`; no hay `/logout` en servidor) |
| Sesión | JWT en memoria vía capa `auth` / session del cliente |
| Envío | `Authorization: Bearer <token>` en perfil y acciones de usuario |
| Caducidad | 168 h configurables en servidor (`gopoli.jwt.expiration-hours`) |

**Recomendación de seguridad (futuro, no obligatorio para MVP):** cookies httpOnly + Secure + SameSite; restringir CORS; proteger `/servicio/*` con JWT; hashing de contraseñas.

---

## 7. Mapa y rutas

| Capacidad | Implementación en `web/` |
|-----------|--------------------------|
| Mapa | Leaflet + teselas OpenStreetMap (sin clave de mapas) |
| Ruta / polylines | OSRM (GeoJSON); si OSRM no responde, línea recta |
| GPS del dispositivo | No requerido para paridad (marcadores desde `ubicaciones` en BD) |
| Foto de perfil | Input file / File API → base64 al backend |

---

## 8. Variables de entorno

### PWA (`web/`)

| Clave | Propósito |
|-------|-----------|
| `NEXT_PUBLIC_API_URL` | Base URL del backend (pública) |

### Backend

| Clave | Propósito |
|-------|-----------|
| `PORT` | Puerto HTTP (Railway) |
| `SPRING_DATASOURCE_URL` | JDBC PostgreSQL |
| `SPRING_DATASOURCE_USERNAME` | Usuario BD |
| `SPRING_DATASOURCE_PASSWORD` | Contraseña BD |
| `GOPOLI_JWT_SECRET` | Firma JWT |
| `gopoli.jwt.expiration-hours` | Caducidad (default 168) |

Plantilla: `backend/.env.example`. **No** poner secretos de JWT ni BD en el cliente.

Documentación: `DEPLOY_RAILWAY.md`, `DATABASE_NEON.md`, `web/DEPLOYMENT.md`.

---

## 9. Funcionalidades a preservar

- Registro con correo `@elpoli.edu.co`, carrera, validaciones actuales
- Login JWT y restauración de sesión al abrir la app
- Roles pasajero/conductor y tipos de viaje 1 / 3
- Crear servicio (capacidad 2–4, fecha/hora, ubicaciones de catálogo)
- Listar activos, unirse, ver miembros, salir, cancelar, iniciar, finalizar
- Mapa con marcadores/ruta entre ubicaciones con coordenadas
- Perfil: ver, editar, foto base64, registro/baja conductor, historial
- Inhabilitar y eliminar cuenta
- Consumo del **mismo** backend desplegado

---

## 10. Offline / PWA

| Capacidad | Offline |
|-----------|---------|
| Shell UI, CSS, iconos, páginas estáticas | Sí (cache SW) |
| Login, crear/unirse/viaje, perfil, historial | **No** — dependen de API viva |
| Lista de servicios / miembros | **No** |
| Mapa OSM / ruta OSRM | **No** sin red |

---

## 11. Ausencias confirmadas (no inventar “por paridad”)

- Recuperación / reset de contraseña
- Notificaciones push / FCM
- Chat / mensajería (salvo lo ya implementado en `web/` si aplica)
- Pagos
- GPS tracking en vivo del vehículo
- Biometría
- Endpoint de logout servidor

---

## 12. Estado de la migración

| Tema | Estado |
|------|--------|
| Cliente Next.js PWA en `web/` | Hecho |
| Backend Spring Boot | Conservado |
| PostgreSQL (Neon / Railway / Docker) | Conservado |
| Mapa OSM + OSRM (sin Google Maps en la web) | Hecho |
| Cliente móvil Flutter | Retirado del stack documentado |

*Referencia de arquitectura y API para GoPoli (Next.js PWA + Spring Boot + PostgreSQL).*

# Matriz de trazabilidad de GoPoli

Fuente: `docs/GOPOLIGO-TALLER.docx`, revisión del 23 de septiembre de 2026.

## Criterio de alcance

El documento contiene dos contratos distintos:

1. **Producto entregado** (secciones 1–3): HU-01 a HU-07. La sección
   “Alcance: lo construido manda” declara este contrato como vigente.
2. **Análisis previo** (sección 4): RF1–RF29 y CU1–CU8. El mismo documento
   advierte que recuperación de contraseña, calificaciones y reportes, entre
   otras funciones, no pertenecen al software entregado.

Por ello, `Fuera del alcance vigente` no significa “cumplido”: conserva la
brecha del catálogo histórico sin afirmar que la aplicación la implemente.

## Historias del producto entregado

| ID | Evidencia de código/prueba | Estado | Brecha o nota |
|---|---|---|---|
| HU-01 Registro e inicio | `AuthController`, `RegistroForm`, `LoginForm`, `validations.test.mts` | Cubierto | No existe verificación por correo; esa variante solo aparece en CU1 histórico. |
| HU-02 Perfil y vehículo | `UsuarioController`, `EditarPerfilForm`, `RegistroConductorForm`, `PerfilPolicyTest` | Cubierto | Se añadió edición/validación de carrera y validación institucional en backend. |
| HU-03 Confirmar viaje | `InicioMapaView`, `CrearServicioForm`, `ServicioController`, `ServicioPolicyTest` | Cubierto | Se añadió validación de ubicaciones existentes y salida distinta del destino. |
| HU-04 Buscar y unirse | `BuscarViajesView`, `POST /servicio/unirse` | Cubierto | La unión es inmediata, como indica HU-04; no implementa solicitudes moderadas del RF11 histórico. |
| HU-05 Iniciar/finalizar | `GrupoView`, `ViajesTabView`, `ServicioController`, `ServicioPolicyTest` | Cubierto | Se impidieron transiciones inválidas y lecturas de grupo por no miembros. |
| HU-06 Agenda | `AgendaView`, `AgendaController` | Cubierto | CRUD y publicación desde ruta habitual presentes. |
| HU-07 Mensajes/historial | `MensajeController`, vistas de mensajes, `HistorialViajesView` | Cubierto | Mensajes limitados a miembros; historial tiene estado vacío. |

## Requisitos funcionales del análisis previo

| ID | Evidencia actual | Estado | Brecha |
|---|---|---|---|
| RF1 Registro | `/register`, `RegistroForm` | Cubierto |
| RF2 Inicio de sesión | `/login`, JWT | Cubierto |
| RF3 Cierre de sesión | sesión en memoria, Perfil | Cubierto |
| RF4 Recuperación | Ninguna | Fuera del alcance vigente | Requiere proveedor de correo, tokens de un solo uso y expiración. |
| RF5 Perfil | `/usuario/me`, foto, carrera | Cubierto |
| RF6 Destino | Agenda/creación de servicio | Parcial | No hay catálogo personal de “Mis destinos”. |
| RF7 Coincidencias cercanas | `/servicios/activos` | Parcial | Lista servicios; no calcula cercanía entre estudiantes. |
| RF8 Filtro horario | Datos de hora visibles | Parcial | No hay filtro de franja horaria. |
| RF9 Crear grupo | `/servicio/crear` | Cubierto |
| RF10 Solicitar ingreso | `/servicio/unirse` | Parcial | La unión es inmediata. |
| RF11 Aceptar/rechazar | Ninguna | Fuera del alcance vigente |
| RF12 Miembros | `/servicio/{id}/miembros`, `GrupoView` | Cubierto |
| RF13 Horario | Servicio/grupo | Cubierto |
| RF14 Cambiar horario | Agenda editable | Parcial | Una instancia publicada no se reprograma. |
| RF15 Abandonar | `/servicio/salir/...` | Cubierto |
| RF16 Cerrar grupo | cancelar/finalizar | Cubierto |
| RF17 Chat grupal | `MensajeController` | Cubierto |
| RF18 Cupo máximo | capacidad 2–4 y control de cupo | Cubierto |
| RF19 Historial | `/usuario/me/historial-viajes` | Cubierto |
| RF20 Calificar | Ninguna | Fuera del alcance vigente |
| RF21 Punto manual | Catálogo y mapa | Parcial | No persiste una coordenada manual como punto de encuentro. |
| RF22 Consejos seguridad | Ninguna interfaz dedicada | Fuera del alcance vigente |
| RF23 Soporte | Documentación del repositorio | Parcial | No hay chat ni correo de soporte configurado. |
| RF24 Reportes | Ninguna | Fuera del alcance vigente |
| RF25 Notificaciones | Feedback en pantalla | Parcial | No hay bandeja/push para solicitudes y cambios. |
| RF26 Completar viaje | `/servicio/finalizar/{id}` | Cubierto |
| RF27 Bloquear usuarios | Estado de usuario | Parcial | No hay operación administrativa autenticada. |
| RF28 Editar destino | Agenda editable antes de publicar | Parcial | No existe destino personal separado. |
| RF29 Cancelar viaje | `/servicio/cancelar/{id}` | Parcial | Cancela; no envía notificación persistente/push. |

## Requisitos no funcionales

| ID | Evidencia | Estado | Brecha |
|---|---|---|---|
| RNF1 Adaptable | Tailwind móvil/escritorio, AppShell | Cubierto por inspección; falta prueba E2E |
| RNF2 99 % disponibilidad | Ninguna medición/SLO | No verificable | No se deben inventar métricas. |
| RNF3 Máximo tres pasos | Inicio y Buscar en navegación principal | Cubierto por flujo; falta medición UX |
| RNF4 Actualización directa | PWA/Service Worker | Cubierto |
| RNF5 Interfaz clara | estados loading/error/empty y etiquetas | Parcial | Requiere prueba con usuarios para afirmación completa. |
| RNF6 Claro/oscuro | Preferencia no implementada | Fuera del alcance vigente |

## Casos de uso del análisis previo

| Caso | Estado | Evidencia/brecha |
|---|---|---|
| CU1 Crear cuenta | Parcial | Registro existe; faltan términos y verificación de correo. |
| CU2 Iniciar sesión | Parcial | Login existe; no hay estado “correo sin verificar” ni recuperación. |
| CU3 Registrar destino | Parcial | Agenda guarda rutas; faltan destinos múltiples y punto manual. |
| CU4 Buscar compañeros | Parcial | Busca servicios, no personas por distancia/horario/medio. |
| CU5 Crear grupo | Parcial | Grupo/cupo/hora existen; faltan privacidad, solicitudes e invitaciones. |
| CU6 Abandonar grupo | Cubierto | Valida pertenencia, estado y libera cupo. |
| CU7 Comunicación | Parcial | Chat restringido a miembros; falta reporte desde chat. |
| CU8 Calificar | Fuera del alcance vigente | Sin calificación, contactos ni reporte. |

## Seguridad y consistencia verificadas

- Toda mutación de servicio, agenda, perfil y mensajes usa el usuario derivado
  del JWT; no confía en un `idUsuario` del cuerpo.
- Solo miembros pueden consultar detalle, miembros y mensajes de un grupo.
- Solo el creador cambia el estado y las transiciones válidas son:
  planificación → en curso → finalizado, o planificación → cancelado.
- Correo de perfil permanece en `@elpoli.edu.co`; nombre, teléfono, carrera,
  ubicaciones y capacidad se validan en backend.
- Persisten riesgos arquitectónicos conocidos: CORS abierto, secreto JWT local
  por defecto y `ddl-auto=update`; son aceptables para local, no para producción.

## Bloqueos externos

- RF4/CU1 requieren correo transaccional y credenciales no presentes.
- RNF2 requiere despliegue y observabilidad; el repositorio no contiene una URL
  pública verificable ni datos de disponibilidad.
- Notificaciones push requieren claves VAPID/proveedor y consentimiento.


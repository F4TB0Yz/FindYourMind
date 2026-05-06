# PROJECT_CONTEXT.md — Base Estática del Proyecto

_Última actualización: 2026-05-06_

---

## Visión del Producto

**FindYourMind** es una aplicación móvil de gestión de hábitos y productividad personal. El objetivo es que el usuario pueda definir hábitos diarios con tres mecanismos de tracking (`single`, `timed`, `counter`), trackear su progreso con granularidad diaria, y visualizar su consistencia semanal. Las features de Notas y Tareas están planificadas pero no implementadas.

**Plataformas objetivo**: Android (primario), iOS (secundario), Web (tertiary/futuro).

**Estado del producto**: Alpha funcional. Auth + Habits completos. Notes/Tasks/Profile son placeholders.

---

## Stack Tecnológico

### Flutter / Dart
- **Flutter SDK**: ≥3.41.7
- **Dart SDK**: ≥3.8.1 (null-safety obligatorio, records y patterns disponibles)
- **Compilación**: Android (arm64 + arm32), iOS, Web (wasm pendiente)

### Backend: Supabase
- **Auth**: Email/password + Google OAuth (PKCE flow)
- **Database**: PostgreSQL (Supabase hosted)
- **Tablas activas**:
  - `habits`: id, user_id, title, description, icon, category, tracking_type, target_value, color, unit, initial_date, created_at, updated_at
  - `habit_logs`: id, habit_id (FK→habits CASCADE), date, value. UNIQUE(habit_id, date).
  - `users`: gestionada por Supabase Auth
- **Índices**: `idx_habits_user_initial_date(user_id, initial_date DESC)`, `idx_habit_logs_habit_id`, `idx_habit_logs_date`
- **Variables de entorno**: `SUPABASE_URL`, `SUPABASE_ANON_KEY` (`.env` en mobile, compile-time en web)

### Base de Datos Local
- **Engine**: SQLite via `drift ^2.23.0` + `sqlite3_flutter_libs ^0.5.24`
- **Abstracción tipada**: `drift ^2.23.0` + `drift_dev ^2.23.0` (code gen)
- **Estrategia**: Offline-first. SQLite como fuente primaria. Supabase como sincronización asíncrona.
- **Schema actual**: `habits.category`, `habits.tracking_type`, `habits.target_value`, `habits.color`, `habits.unit` y `habit_logs.value` como único campo de progreso agnóstico al tipo.
- **Cola de sync**: tabla `pending_sync` (entity_type, entity_id, action, data JSON, created_at, retry_count)

### Gestión de Estado
- **Librería**: `provider ^6.1.5` (ChangeNotifier)
- **Providers activos**:
  - `HabitsProvider` — lista de hábitos, paginación (pageSize=10), CRUD, logs diarios, filtros y 3 tracking types
  - `NewHabitProvider` — estado de formulario de creación (`category`, `trackingType`, `targetValue`)
  - `ThemeProvider` — dark/light mode, persistido en SharedPreferences
  - `SyncProvider` — estado de sincronización background

### Navegación
- **Librería**: `go_router ^14.6.3`
- **Patrón**: StatefulShellRoute para bottom nav persistente
- **Rutas principales**: `/auth`, `/login`, `/register`, `/habits`, `/habits/:id`, `/notes`, `/tasks`, `/profile`

### Dependencias Clave (resumen pubspec.yaml)
| Paquete | Versión | Uso |
|---|---|---|
| `dartz` | ^0.10.1 | Either<Failure, T> para error handling funcional |
| `equatable` | ^2.0.7 | Igualdad de entidades sin boilerplate |
| `flutter_localizations` | SDK | Localización Flutter en español |
| `flutter_dotenv` | 6.0.0 | Variables de entorno (.env) |
| `flutter_slidable` | 4.0.3 | Swipe actions en listas de hábitos |
| `flutter_svg` | 2.2.1 | SVG (logo Google auth) |
| `go_router` | ^14.6.3 | Navegación declarativa |
| `google_fonts` | ^6.2.1 | Tipografía (Google Fonts) |
| `internet_connection_checker` | ^3.0.1 | Detección de conectividad |
| `logger` | ^2.5.0 | Logging (wrapeado por AppLogger) |
| `hugeicons` | ^1.1.6 | Iconografía principal (Stroke Rounded) |
| `path` | ^1.9.0 | Rutas de archivos |
| `path_provider` | ^2.1.5 | Directorios de almacenamiento local |
| `provider` | 6.1.5+1 | Estado con ChangeNotifier |
| `shimmer` | ^3.0.0 | Efectos visuales en cards de hábitos |
| `shared_preferences` | ^2.2.2 | Persistencia de preferencias |
| `sqlite3_flutter_libs` | ^0.5.24 | Binarios SQLite para Drift native |
| `supabase_flutter` | 2.10.1 | Cliente Supabase |
| `uuid` | ^4.5.1 | Generación de IDs en cliente |
| `mocktail` | ^1.0.4 | Mocking en tests |

---

## Objetivos de Alto Nivel

1. **Offline-first confiable**: El usuario puede usar la app sin conexión. Ningún dato se pierde.
2. **Sync transparente**: La sincronización ocurre en background sin bloquear la UI.
3. **Performance en listados**: Paginación implementada. Carga inicial < 500ms en P90.
4. **Clean Architecture estricta**: Cualquier dev puede entender la capa de dominio sin leer UI.
5. **Cobertura de tests**: UseCases y modelos de dominio cubiertos. Providers con tests de integración.

## Métricas de Éxito del Sistema

- Auth exitoso en < 3s en red 4G.
- Progreso de hábito guardado en SQLite en < 100ms (respuesta UI inmediata).
- Sync pendiente completado en < 30s tras recuperar conexión.
- Zero pérdida de datos en escenario offline → online.
- Tests: 100% de UseCases con cobertura, 80% providers.

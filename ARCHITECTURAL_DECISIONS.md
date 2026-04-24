# ARCHITECTURAL_DECISIONS.md — Contrato Técnico

_Última actualización: 2026-04-24_

---

## Mapa de Clean Architecture

```
lib/
├── core/                          # Infraestructura transversal
│   ├── config/                    # DI, DB, Supabase config
│   ├── constants/                 # Strings, animaciones, app constants
│   ├── error/                     # Exceptions + Failures (dartz)
│   ├── network/                   # NetworkInfo (internet_connection_checker)
│   ├── services/                  # AuthService, SyncService (interfaces + impl)
│   └── utils/                     # AppLogger, validators, date_utils, map_utils
├── features/{feature}/
│   ├── domain/                    # ← NÚCLEO. Cero dependencias externas
│   │   ├── entities/              # Modelos puros de negocio (Equatable)
│   │   ├── repositories/          # Interfaces abstractas (contratos)
│   │   └── usecases/              # Lógica de negocio orquestada
│   ├── data/                      # ← IMPLEMENTACIÓN
│   │   ├── datasources/           # Remote (Supabase) + Local (SQLite/Drift)
│   │   ├── models/                # DTOs con fromJson/toJson + fromEntity/toEntity
│   │   └── repositories/          # Implementa interfaces de domain/
│   └── presentation/              # ← UI
│       ├── providers/             # ChangeNotifier con lógica de UI state
│       ├── screens/               # Páginas completas
│       └── widgets/               # Componentes reutilizables
├── shared/
│   └── presentation/              # Widgets/providers globales (nav, theme, fab)
└── config/
    ├── router/                    # app_router.dart (GoRouter)
    └── theme/                     # app_colors, app_text_styles, app_theme
```

### Flujo de datos (request)
```
Screen → Provider → UseCase → Repository (interface) → RepositoryImpl → DataSource → Supabase/SQLite
```

### Flujo de datos (response)
```
SQLite/Supabase → DataSource → Either<Exception, Model> → RepositoryImpl → Either<Failure, Entity> → UseCase → Provider (notifyListeners) → Screen rebuild
```

---

## ADR-001: Supabase sobre Firebase

**Estado**: ACTIVO

**Decisión**: Usar Supabase (PostgreSQL) en lugar de Firebase (Firestore).

**Razones**:
- SQL estructurado permite queries complejas (progress + habits joins) sin duplicación de datos.
- Row Level Security (RLS) nativo en PostgreSQL → seguridad por usuario sin lógica adicional.
- Supabase Auth soporta PKCE nativamente, crítico para Google OAuth en mobile.
- Pricing predecible vs. Firestore por operaciones.
- `supabase_flutter ^2.10.1` maneja reconexión y token refresh automáticamente.

**Trade-off aceptado**: Supabase tiene menor ecosistema de extensiones vs. Firebase. Sin Firestore offline SDK (por eso SQLite manual).

---

## ADR-002: Offline-First con SQLite

**Estado**: ACTIVO

**Decisión**: SQLite como fuente primaria. Supabase como destino de sincronización asíncrona.

**Implementación**:
- Toda escritura va primero a SQLite → UI responde inmediatamente.
- `SyncService` procesa cola `pending_sync` en background al recuperar conexión.
- Cola FIFO estricta: si un `habit` falla el sync, sus `habit_progress` dependientes se bloquean.
- Retry con conteo (`retry_count`). Threshold de abandono: definir en `SyncService`.

**Archivos clave**:
- `lib/core/config/database_helper.dart` — esquema SQLite + migraciones
- `lib/core/services/sync_service.dart` — lógica de cola y retry
- `lib/features/habits/data/datasources/habits_local_datasource.dart`
- `lib/shared/presentation/providers/sync_provider.dart`

---

## ADR-003: Provider sobre Riverpod/Bloc

**Estado**: ACTIVO

**Decisión**: `provider ^6.1.5` con ChangeNotifier. Sin Riverpod ni Bloc.

**Razones**:
- Proyecto iniciado con Provider. Migración no justificada por complejidad actual.
- HabitsProvider (~700 líneas) ya gestiona paginación, semáforos de race condition (`_activeLoadFuture`, `_ongoingDbOperations`) y error state.
- Costo de migración > beneficio en este momento.

**Restricción**: Si la complejidad de estado escala (ej. múltiples consumidores del mismo stream), evaluar Riverpod. Documentar esa decisión como ADR-XXX antes de migrar.

---

## ADR-004: GoRouter para Navegación

**Estado**: ACTIVO

**Decisión**: `go_router ^14.6.3` con StatefulShellRoute.

**Implementación**:
- `StatefulShellRoute` preserva estado de cada tab del bottom nav.
- Guards: redirect en `/` → `/auth` si no hay sesión activa (detectado via `AuthService`).
- Deep linking habilitado por GoRouter por defecto.

**Archivo clave**: `lib/config/router/app_router.dart`

---

## ADR-005: Drift para Esquema SQLite Tipado

**Estado**: ACTIVO (parcialmente — esquema definido, migrar queries progresivamente)

**Decisión**: Usar `drift ^2.23.0` para definir el esquema SQLite con tipos Dart en lugar de SQL strings manuales.

**Estado actual**: Drift instalado y configurado. `sqflite` aún se usa para algunas queries directas. La migración a Drift puro es deuda técnica controlada.

---

## Convenciones de Nomenclatura

### Archivos (snake_case)
```
habit_entity.dart
habit_repository_impl.dart
habits_local_datasource.dart
create_habit_usecase.dart      # ← usecase al final, no use_case
habits_provider.dart
habit_detail_screen.dart
```

### Clases (PascalCase + sufijo semántico)
| Tipo | Sufijo | Ejemplo |
|---|---|---|
| Entidad de dominio | `Entity` | `HabitEntity` |
| DTO/Model de datos | `Model` | `ItemHabitModel`, `ProgressHabitModel` |
| Interfaz repository | `Repository` | `HabitRepository` |
| Impl repository | `RepositoryImpl` | `HabitRepositoryImpl` |
| DataSource remoto | `RemoteDataSourceImpl` | `HabitsRemoteDataSourceImpl` |
| DataSource local | `LocalDatasourceImpl` | `HabitsLocalDatasourceImpl` |
| UseCase | `UseCase` | `CreateHabitUseCase` |
| Provider | `Provider` | `HabitsProvider` |
| Servicio | `Service` | `SyncService`, `AuthService` |
| Screen | `Screen` | `HabitDetailScreen` |

### Variables y métodos (camelCase)
- Privados: `_camelCase` (ej. `_habits`, `_isLoading`, `_activeLoadFuture`)
- Constantes de clase: `_SCREAMING` o `_camelCase` (ej. `_pageSize = 10`)
- Enums: PascalCase tipo, lowercase valores (ej. `TypeHabit.health`, `TypeHabit.none`)

---

## Inyección de Dependencias

**Patrón**: Singleton manual via `DependencyInjection` en `lib/core/config/dependency_injection.dart`.

```dart
// Registro (en main.dart o DI.initialize())
DependencyInjection.register<HabitRepository>(HabitRepositoryImpl(
  remoteDataSource: HabitsRemoteDataSourceImpl(),
  localDataSource: HabitsLocalDatasourceImpl(),
  networkInfo: NetworkInfoImpl(),
));

// Consumo (en Provider o UseCase)
final repo = DependencyInjection.get<HabitRepository>();
```

No se usa `get_it` ni `injectable`. La DI es explícita y manual.

---

## Manejo de Errores

### Jerarquía de Exceptions (capa data — se lanzan)
```
ServerException
NetworkException
NotFoundException
CacheException
```

### Jerarquía de Failures (capa domain — se retornan)
```
ServerFailure
NetworkFailure
CacheFailure
ValidationFailure
```

### Patrón Either
```dart
// Repository impl convierte Exception → Failure
Future<Either<Failure, HabitEntity>> getHabit(String id) async {
  try {
    final model = await localDataSource.getHabit(id);
    return Right(model.toEntity());
  } on CacheException catch (e) {
    return Left(CacheFailure(e.message));
  }
}

// UseCase solo propaga el Either
Future<Either<Failure, HabitEntity>> call(String id) =>
    repository.getHabit(id);

// Provider maneja el fold
final result = await getHabitUseCase(id);
result.fold(
  (failure) { _error = failure.message; notifyListeners(); },
  (entity) { _habit = entity; notifyListeners(); },
);
```

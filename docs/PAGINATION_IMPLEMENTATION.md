# Implementación de Paginación y Lazy Loading para Hábitos

## Problema Original
- `getHabitsByEmail` cargaba TODOS los hábitos de una vez
- Podía ser lento con muchos hábitos
- No había paginación ni lazy loading

## Solución Implementada

### 1. **Capa de Dominio (Repository)**
**Archivo**: `lib/features/habits/domain/repositories/habit_repository.dart`

Se añadió el método de paginación al contrato del repositorio:

```dart
Future<List<HabitEntity>> getHabitsByEmailPaginated({
  required String email,
  int limit = 10,
  int offset = 0,
});
```

**Parámetros**:
- `email`: Email del usuario
- `limit`: Cantidad de hábitos por página (default: 10)
- `offset`: Desplazamiento para la paginación (default: 0)

---

### 2. **Capa de Datos (Service)**
**Archivo**: `lib/core/data/supabase_habits_service.dart`

Se implementó el método `getHabitsByEmailPaginated` con optimizaciones:

**Mejoras clave**:
- ✅ Usa `range(offset, offset + limit - 1)` para paginación en Supabase
- ✅ Ordena por `created_at` descendente (más recientes primero)
- ✅ Limita el progreso a los últimos 30 días para optimizar la carga
- ✅ Ordena el progreso por fecha descendente

```dart
.order('created_at', ascending: false)
.range(offset, offset + limit - 1)
```

---

### 3. **Capa de Datos (Repository Implementation)**
**Archivo**: `lib/features/habits/data/repositories/habit_repository_impl.dart`

Se implementó el método en el repositorio concreto delegando al servicio:

```dart
@override
Future<List<HabitEntity>> getHabitsByEmailPaginated({
  required String email,
  int limit = 10,
  int offset = 0,
}) async {
  return await _habitsService.getHabitsByEmailPaginated(
    email: email,
    limit: limit,
    offset: offset,
  );
}
```

---

### 4. **Capa de Presentación (Provider)**
**Archivo**: `lib/features/habits/presentation/providers/habits_provider.dart`

Se añadió estado de paginación y método de lazy loading:

**Nuevo estado**:
```dart
bool _isLoading = false;       // Indica si se están cargando hábitos
bool _hasMore = true;          // Indica si hay más hábitos por cargar
int _currentPage = 0;          // Página actual
static const int _pageSize = 10; // Tamaño de página
```

**Métodos actualizados**:

1. **`loadHabits()`** - Carga inicial
   - Resetea el estado de paginación
   - Carga la primera página
   - Detecta si hay más páginas disponibles

2. **`loadMoreHabits()`** - Lazy loading
   - Verifica si no está cargando y si hay más items
   - Carga la siguiente página
   - Actualiza el estado de paginación
   - Previene cargas duplicadas

---

### 5. **Capa de Presentación (UI)**
**Archivo**: `lib/features/habits/presentation/screens/habits_screen.dart`

Se implementó scroll infinito con `ScrollController`:

**Características**:
- ✅ `ScrollController` para detectar scroll
- ✅ Carga automática al llegar al 80% del scroll
- ✅ Indicador de carga (`CircularProgressIndicator`) al final de la lista
- ✅ Limpieza adecuada del controller en `dispose()`

**Implementación del scroll listener**:
```dart
void _onScroll() {
  if (_scrollController.position.pixels >= 
      _scrollController.position.maxScrollExtent * 0.8) {
    habitsProvider.loadMoreHabits();
  }
}
```

---

## Beneficios de la Implementación

### 🚀 Rendimiento
- **Carga inicial más rápida**: Solo carga 10 hábitos en lugar de todos
- **Uso eficiente de memoria**: No carga todos los datos a la vez
- **Optimización de progreso**: Solo carga últimos 30 días de progreso

### 👤 Experiencia de Usuario
- **Scroll infinito**: Carga automática sin botones
- **Feedback visual**: Indicador de carga al final de la lista
- **Sin bloqueos**: La app sigue siendo responsive durante la carga

### 🔧 Escalabilidad
- **Preparado para muchos hábitos**: La app funcionará bien con 100+ hábitos
- **Configurable**: El tamaño de página se puede ajustar fácilmente
- **Extensible**: Fácil añadir filtros o búsqueda en el futuro

---

## Flujo de Carga

```
Usuario abre la app
    ↓
loadHabits() - Carga primeros 10 hábitos
    ↓
Usuario hace scroll hacia abajo
    ↓
Al llegar al 80% del scroll
    ↓
loadMoreHabits() - Carga siguientes 10 hábitos
    ↓
Se repite hasta que hasMore = false
```

---

## Configuración

Para ajustar el tamaño de página, modificar en `habits_provider.dart`:

```dart
static const int _pageSize = 10; // Cambiar este valor
```

Para ajustar el punto de activación del scroll, modificar en `habits_screen.dart`:

```dart
if (_scrollController.position.pixels >= 
    _scrollController.position.maxScrollExtent * 0.8) // Cambiar 0.8
```

---

## Notas Técnicas

1. **Método original preservado**: `getHabitsByEmail()` sigue disponible para compatibilidad
2. **Thread-safe**: Los checks de `_isLoading` previenen cargas concurrentes
3. **Gestión de errores**: Los errores se loguean sin romper la app
4. **Limpieza de recursos**: El ScrollController se dispone correctamente

---

## Próximas Mejoras Posibles

- [ ] Implementar pull-to-refresh para recargar
- [ ] Añadir cache local para mejorar rendimiento
- [ ] Implementar búsqueda con paginación
- [ ] Añadir filtros (por tipo, fecha, etc.)
- [ ] Optimizar con singleton pattern para los servicios
- [ ] Implementar retry logic en caso de errores de red

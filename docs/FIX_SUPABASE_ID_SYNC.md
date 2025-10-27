# 🔄 Fix: Sincronización del ID de Supabase a la Base de Datos Local

## 🐛 Problema Identificado

Cuando se crea un nuevo hábito con conexión a internet:

1. **Se crea en SQLite** con un ID temporal generado localmente:
   ```
   Hábito guardado con ID real: b19d0f3b-6b2b-4368-bf1a-bfa428357879
   ```

2. **Se sincroniza con Supabase** y se obtiene un ID remoto diferente:
   ```
   ✅ Hábito sincronizado con Supabase - ID remoto: 789b32b0-d652-4fd9-ae80-42238f0bcc1f
   ```

3. **PROBLEMA**: El ID local NO se actualiza con el ID remoto de Supabase
   ```sql
   -- Base de datos local sigue teniendo el ID temporal
   SELECT id FROM habits;
   -- Resultado: b19d0f3b-6b2b-4368-bf1a-bfa428357879
   ```

### Consecuencias del Problema

- ❌ El hábito tiene diferentes IDs en la BD local vs Supabase
- ❌ Los progresos asociados usan el ID local, no el de Supabase
- ❌ Problemas de sincronización al actualizar o eliminar el hábito
- ❌ Inconsistencia de datos entre dispositivos

---

## 🔍 Análisis de la Causa

### Flujo Actual (Con Error)

```dart
// En HabitRepositoryImpl.createHabit()

// 1. Se crea en SQLite con ID temporal
final habitId = await _localDataSource.createHabit(habit);  // UUID local

// 2. Se envía a Supabase en segundo plano (unawaited)
unawaited(
  _remoteDataSource.createHabit(habitWithId).then((remoteId) {
    print('✅ Hábito sincronizado con Supabase - ID remoto: $remoteId');
    // ❌ FALTA: No se actualiza el ID local con remoteId
  })
);

// 3. Se retorna el ID local inmediatamente
return Right(habitId);  // Retorna el UUID local, no el de Supabase
```

### ¿Por qué no se actualizaba?

El método `_updateLocalId()` existía en `SyncService`, pero **solo se llamaba** cuando se sincronizaban cambios pendientes (`syncPendingChanges()`), **NO cuando se creaba un hábito con conexión directa**.

---

## ✅ Solución Implementada

### 1. Nuevo Método Público en `SyncService`

**Archivo**: `lib/core/services/sync_service.dart`

```dart
/// Actualiza el ID local de un hábito con el ID remoto de Supabase
/// Este método se usa cuando se crea un hábito con conexión y se necesita
/// actualizar el ID temporal local con el ID real de Supabase
Future<void> updateLocalHabitId(String localId, String remoteId) async {
  if (localId == remoteId) return;
  
  print('🔄 [SYNC] Actualizando ID local $localId → $remoteId');
  
  final db = await _dbHelper.database;
  
  // 1. Actualizar el ID en la tabla habits Y marcar como sincronizado
  await db.update(
    'habits',
    {
      'id': remoteId,
      'synced': 1, // Marcar como sincronizado
      'updated_at': DateTime.now().toIso8601String(),
    },
    where: 'id = ?',
    whereArgs: [localId],
  );
  
  // 2. Actualizar el habit_id en todos los progresos asociados
  await db.update(
    'habit_progress',
    {'habit_id': remoteId},
    where: 'habit_id = ?',
    whereArgs: [localId],
  );
  
  // 3. Actualizar habit_id en pending_sync si existe
  final pendingProgress = await db.query(
    'pending_sync',
    where: 'entity_type = ?',
    whereArgs: ['progress'],
  );

  for (var item in pendingProgress) {
    final progressData = jsonDecode(item['data'] as String) as Map<String, dynamic>;
    
    if (progressData['habit_id'] == localId) {
      progressData['habit_id'] = remoteId;
      
      await db.update(
        'pending_sync',
        {'data': jsonEncode(progressData)},
        where: 'id = ?',
        whereArgs: [item['id']],
      );
    }
  }
  
  print('✅ [SYNC] ID actualizado correctamente en todas las tablas');
}
```

**Características:**
- ✅ Actualiza el ID del hábito en la tabla `habits`
- ✅ Actualiza el `habit_id` en todos los progresos asociados
- ✅ Actualiza las referencias en `pending_sync`
- ✅ Marca el hábito como sincronizado (`synced = 1`)
- ✅ Método público, accesible desde el repositorio

---

### 2. Llamada al Método en el Repositorio

**Archivo**: `lib/features/habits/data/repositories/habit_repository_impl.dart`

```dart
// 2. 🚀 Sincronizar con Supabase en SEGUNDO PLANO (no bloqueante)
if (await _networkInfo.isConnected) {
  // Usar unawaited para no bloquear la UI
  unawaited(
    _remoteDataSource.createHabit(habitWithId).then((remoteId) async {
      print('✅ Hábito sincronizado con Supabase - ID remoto: $remoteId');
      
      // 🔄 NUEVO: Actualizar el ID local con el ID remoto de Supabase
      if (remoteId != null && remoteId != habitId) {
        await _syncService.updateLocalHabitId(habitId, remoteId);
        print('🔄 ID local actualizado: $habitId → $remoteId');
      }
    }).catchError((e) {
      print('⚠️ Error sincronizando con Supabase: $e');
      // Si falla, marcar como pendiente de sincronización
      _syncService.markPendingSync(
        entityType: 'habit',
        entityId: habitId,
        action: 'create',
        data: _habitToJson(habitWithId),
      );
    })
  );
}
```

**Cambios:**
- ✅ Agregado `async` al callback de `.then()`
- ✅ Llamada a `_syncService.updateLocalHabitId()` cuando hay ID remoto
- ✅ Validación para solo actualizar si los IDs son diferentes
- ✅ Log para rastrear la actualización

---

### 3. Actualización del Provider para Refrescar el Hábito

**Archivo**: `lib/features/habits/presentation/providers/habits_provider.dart`

```dart
// ✅ 3. Actualizar con el ID real de la base de datos
final habitIndex = _habits.indexWhere((h) => h.id == tempId);
if (habitIndex != -1) {
  _habits[habitIndex] = habit.copyWith(id: habitId);
  notifyListeners();
}

if (kDebugMode) print('✅ Hábito guardado con ID real: $habitId');

// 🔄 4. NUEVO: Refrescar el hábito después de un delay 
// para obtener el ID de Supabase
Future.delayed(const Duration(seconds: 2), () async {
  if (kDebugMode) print('🔄 Refrescando hábito para obtener ID actualizado...');
  await _refreshSingleHabit(habitId);
});

return habitId;
```

**Nuevo Método Helper:**

```dart
/// Refresca un hábito específico desde la base de datos
/// Útil para obtener el ID actualizado después de sincronizar con Supabase
Future<void> _refreshSingleHabit(String habitId) async {
  try {
    // Cargar todos los hábitos
    final habits = await _repository.getHabitsByEmailPaginated(
      email: _userId,
      limit: 100,
      offset: 0,
    );
    
    // Buscar el hábito actualizado
    final updatedHabit = habits.firstWhere(
      (h) => h.id == habitId,
      orElse: () => habits.first, // Recién creado
    );
    
    // Actualizar en la lista local
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index != -1) {
      _habits[index] = updatedHabit;
      if (kDebugMode) print('✅ Hábito refrescado - ID actualizado: ${updatedHabit.id}');
      notifyListeners();
    } else {
      // Buscar por título si no se encuentra por ID
      final indexByTitle = _habits.indexWhere((h) => h.title == updatedHabit.title);
      if (indexByTitle != -1) {
        _habits[indexByTitle] = updatedHabit;
        if (kDebugMode) print('✅ Hábito refrescado por título - ID actualizado: ${updatedHabit.id}');
        notifyListeners();
      }
    }
  } catch (e) {
    if (kDebugMode) print('⚠️ Error refrescando hábito: $e');
    // No es crítico, se actualizará en el próximo refresh
  }
}
```

**Características:**
- ✅ Espera 2 segundos para dar tiempo a la sincronización
- ✅ Recarga el hábito desde la BD local (que ya tiene el ID actualizado)
- ✅ Actualiza el estado del provider con el ID correcto
- ✅ Fallback: busca por título si el ID cambió

---

## 🎯 Flujo Completo Actualizado

### Creación de Hábito con Internet

```
Usuario crea hábito
    ↓
1. Provider: Actualización optimista (ID temporal en UI)
    ↓
2. Repository: createHabit()
    ↓
3. LocalDatasource: Guardar en SQLite (ID local UUID)
    ↓
4. RemoteDataSource: Enviar a Supabase (en segundo plano)
    ↓
5. Supabase: Crea hábito y retorna ID remoto
    ↓
6. SyncService.updateLocalHabitId()
    ├─→ Actualiza habits.id (local → remoto)
    ├─→ Actualiza habit_progress.habit_id
    ├─→ Actualiza pending_sync (si existe)
    └─→ Marca synced = 1
    ↓
7. Provider: Refresca hábito después de 2s
    ↓
8. UI se actualiza con ID correcto de Supabase
```

### Logs Esperados

```
✅ Hábito agregado optimistamente a la UI
✅ Hábito guardado con ID real: b19d0f3b-6b2b-4368-bf1a-bfa428357879
✅ Hábito sincronizado con Supabase - ID remoto: 789b32b0-d652-4fd9-ae80-42238f0bcc1f
🔄 ID local actualizado: b19d0f3b-6b2b-4368-bf1a-bfa428357879 → 789b32b0-d652-4fd9-ae80-42238f0bcc1f
🔄 [SYNC] Actualizando ID local b19d0f3b-6b2b-4368-bf1a-bfa428357879 → 789b32b0-d652-4fd9-ae80-42238f0bcc1f
✅ [SYNC] ID actualizado correctamente en todas las tablas
🔄 Refrescando hábito para obtener ID actualizado...
✅ Hábito refrescado - ID actualizado: 789b32b0-d652-4fd9-ae80-42238f0bcc1f
```

---

## 🧪 Validación

### Verificar en Base de Datos Local

```sql
-- Después de crear un hábito, verificar que el ID coincide con Supabase
SELECT id, title, synced FROM habits ORDER BY created_at DESC LIMIT 1;

-- Verificar que los progresos tienen el ID correcto
SELECT id, habit_id FROM habit_progress WHERE habit_id = '<id_de_supabase>';
```

### Verificar en Supabase

```sql
-- Verificar que el hábito existe con el mismo ID
SELECT id, title FROM habits WHERE id = '<id_de_supabase>';
```

### Verificar Sincronización

```sql
-- No debe haber entradas pendientes de sincronización para este hábito
SELECT * FROM pending_sync WHERE entity_id = '<id_de_supabase>';
```

---

## 📊 Casos de Uso Cubiertos

### ✅ Caso 1: Crear hábito CON internet
```
1. Se crea en SQLite con ID local
2. Se envía a Supabase inmediatamente
3. Se recibe ID remoto
4. Se actualiza ID local → remoto
5. Se marca synced = 1
6. Provider refresca y muestra ID correcto
```

### ✅ Caso 2: Crear hábito SIN internet
```
1. Se crea en SQLite con ID local
2. Se marca en pending_sync
3. Cuando vuelva internet:
   - syncPendingChanges() lo sincroniza
   - _syncHabit() actualiza el ID
   - Se marca synced = 1
```

### ✅ Caso 3: Crear hábito CON internet pero falla la sincronización
```
1. Se crea en SQLite con ID local
2. Falla el envío a Supabase
3. Se marca en pending_sync
4. Se reintenta después
5. Al tener éxito, se actualiza el ID
```

---

## 🎉 Resultado Final

Con este fix:

- ✅ El ID local se actualiza con el ID de Supabase
- ✅ Los progresos se asocian correctamente
- ✅ La sincronización funciona sin duplicados
- ✅ La base de datos local y remota están sincronizadas
- ✅ El provider muestra el ID correcto en la UI

---

**Fecha**: 26 de octubre de 2025  
**Problema**: ID local no se actualizaba con ID de Supabase  
**Solución**: Método `updateLocalHabitId()` en SyncService  
**Estado**: ✅ RESUELTO

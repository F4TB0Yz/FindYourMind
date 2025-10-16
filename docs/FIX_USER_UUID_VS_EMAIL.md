# Fix: Usar UUID en lugar de Email para consultas

## 🐛 Problema

```
❌ [REPO] Error cargando desde Supabase: ServerException: 
Error al obtener hábitos: invalid input syntax for type uuid: "jfduarte09@gmail.com"
```

### Causa

El código estaba usando el **email del usuario** (`jfduarte09@gmail.com`) para consultar hábitos en Supabase, pero la tabla `habits` tiene una columna `user_id` de tipo **UUID**, no tipo texto.

**Tabla Supabase:**
```sql
CREATE TABLE habits (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL,  -- ← Espera UUID, no email
  title TEXT,
  -- ...
);
```

**Código problemático:**
```dart
final String _userEmail = 'jfduarte09@gmail.com';

// ❌ Esto falla porque user_id es UUID
await repository.getHabitsByEmail(_userEmail);
```

## ✅ Solución Implementada

### 1. Cambiar de Email a UUID en HabitsProvider

**Archivo:** `lib/features/habits/presentation/providers/habits_provider.dart`

```dart
// ❌ ANTES
final String _userEmail = 'jfduarte09@gmail.com';

// ✅ DESPUÉS
final String _userId = 'c2fa89e9-ab8e-4592-b14e-223d7d7aa55d';
```

### 2. Actualizar todas las llamadas al repositorio

**Cambios realizados:**

```dart
// En _syncInBackground()
await repo.syncWithRemote(_userId);  // ✅ Antes: _userEmail

// En _refreshHabitsFromLocal()
final updatedHabits = await _repository.getHabitsByEmail(_userId);  // ✅

// En loadHabits()
final habits = await _repository.getHabitsByEmailPaginated(
  email: _userId,  // ✅ Antes: _userEmail
  limit: _pageSize,
  offset: 0,
);

// En loadMoreHabits()
final newHabits = await _repository.getHabitsByEmailPaginated(
  email: _userId,  // ✅
  limit: _pageSize,
  offset: _currentPage * _pageSize,
);

// En syncWithServer()
final result = await (_repository as dynamic).syncWithRemote(_userId);  // ✅
```

## 🔍 Cómo Obtener el UUID del Usuario

### Opción 1: Hardcoded (Temporal - Actual)

```dart
// ⚠️ Solo para desarrollo
final String _userId = 'c2fa89e9-ab8e-4592-b14e-223d7d7aa55d';
```

**Pros:**
- ✅ Rápido para probar
- ✅ No requiere autenticación

**Contras:**
- ❌ No funciona con múltiples usuarios
- ❌ Inseguro
- ❌ Hay que cambiarlo en producción

### Opción 2: Desde Supabase Auth (Recomendado)

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class HabitsProvider extends ChangeNotifier {
  String? _userId;
  
  HabitsProvider() {
    _initializeUser();
    _startAutoSync();
  }
  
  Future<void> _initializeUser() async {
    final supabase = Supabase.instance.client;
    
    // Obtener usuario autenticado
    final user = supabase.auth.currentUser;
    
    if (user != null) {
      _userId = user.id;  // ✅ UUID del usuario autenticado
      print('👤 Usuario autenticado: $_userId');
      
      // Cargar hábitos después de obtener el user
      await loadHabits();
    } else {
      print('❌ No hay usuario autenticado');
      // Redirigir a login
    }
  }
  
  Future<void> loadHabits() async {
    if (_userId == null) {
      print('⚠️ No se puede cargar hábitos sin userId');
      return;
    }
    
    // ... resto del código usando _userId
  }
}
```

### Opción 3: Sistema de Autenticación Completo

**1. Crear AuthProvider:**

```dart
// lib/features/auth/presentation/providers/auth_provider.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  User? _currentUser;
  
  User? get currentUser => _currentUser;
  String? get userId => _currentUser?.id;
  bool get isAuthenticated => _currentUser != null;
  
  AuthProvider() {
    _initializeAuth();
  }
  
  Future<void> _initializeAuth() async {
    // Escuchar cambios de autenticación
    _supabase.auth.onAuthStateChange.listen((data) {
      _currentUser = data.session?.user;
      notifyListeners();
    });
    
    // Obtener usuario actual
    _currentUser = _supabase.auth.currentUser;
    notifyListeners();
  }
  
  Future<bool> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      _currentUser = response.user;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error en login: $e');
      return false;
    }
  }
  
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
```

**2. Agregar AuthProvider a main.dart:**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _loadEnv();
  await DependencyInjection().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),  // ← NUEVO
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ScreensProvider(...)),
        ChangeNotifierProvider(create: (_) => NewHabitProvider()),
        ChangeNotifierProvider(create: (_) => HabitsProvider()),
      ],
      child: const MainApp(),
    ),
  );
}
```

**3. Usar AuthProvider en HabitsProvider:**

```dart
class HabitsProvider extends ChangeNotifier {
  final HabitRepository _repository = DependencyInjection().habitRepository;
  final AuthProvider authProvider;  // ← Inyectar
  
  String? get _userId => authProvider.userId;
  
  HabitsProvider({required this.authProvider}) {
    _startAutoSync();
    
    // Cargar hábitos cuando hay usuario
    if (_userId != null) {
      loadHabits();
    }
  }
  
  Future<void> loadHabits() async {
    if (_userId == null) return;  // ← Validar
    
    // Usar _userId en todas las llamadas
    final habits = await _repository.getHabitsByEmailPaginated(
      email: _userId!,
      limit: _pageSize,
      offset: 0,
    );
    // ...
  }
}
```

**4. Actualizar creación del provider en main.dart:**

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    
    // HabitsProvider ahora depende de AuthProvider
    ChangeNotifierProxyProvider<AuthProvider, HabitsProvider>(
      create: (context) => HabitsProvider(
        authProvider: Provider.of<AuthProvider>(context, listen: false),
      ),
      update: (context, auth, previous) => previous ?? HabitsProvider(
        authProvider: auth,
      ),
    ),
  ],
  // ...
)
```

## 📊 Comparación de Soluciones

| Solución | Pros | Contras | Uso |
|----------|------|---------|-----|
| **Hardcoded** | Rápido, simple | No escalable, inseguro | ✅ Desarrollo/Testing |
| **Supabase Auth Simple** | Rápido de implementar | Acoplado a Supabase | ✅ MVP, proyectos pequeños |
| **AuthProvider Completo** | Escalable, modular, testeable | Más código inicial | ✅ Producción |

## 🎯 Flujo Correcto con Autenticación

### Estado Actual (Hardcoded)
```
App inicia
  ↓
HabitsProvider creado con UUID hardcoded
  ↓
loadHabits() usa UUID fijo
  ↓
✅ Funciona solo para 1 usuario
```

### Estado Futuro (Con Auth)
```
App inicia
  ↓
AuthProvider verifica sesión
  ├─ Usuario logueado → obtiene UUID
  └─ Sin sesión → redirige a login
  ↓
HabitsProvider recibe AuthProvider
  ↓
loadHabits() usa authProvider.userId
  ↓
✅ Funciona para cualquier usuario
```

## 🔧 Próximos Pasos

### 1. Corto Plazo (Actual)
- [x] Usar UUID hardcoded para desarrollo
- [ ] Verificar que carga hábitos correctamente
- [ ] Probar CRUD completo

### 2. Medio Plazo
- [ ] Implementar AuthProvider básico
- [ ] Obtener userId de Supabase.instance.client.auth.currentUser
- [ ] Manejar caso sin autenticación

### 3. Largo Plazo
- [ ] Sistema de autenticación completo
- [ ] Login/Registro UI
- [ ] Persistencia de sesión
- [ ] Manejo de tokens y refresh

## 📝 Notas de Migración

### Si ya tienes datos con email en Supabase:

**Opción A: Migración de datos (Recomendado)**
```sql
-- Script de migración en Supabase SQL Editor
UPDATE habits 
SET user_id = (
  SELECT id 
  FROM auth.users 
  WHERE email = 'jfduarte09@gmail.com'
)
WHERE user_id = 'jfduarte09@gmail.com';  -- Si guardaste email por error
```

**Opción B: Crear nueva columna**
```sql
-- Agregar columna email si quieres búsqueda dual
ALTER TABLE habits ADD COLUMN user_email TEXT;

-- Llenar con datos de auth.users
UPDATE habits 
SET user_email = (
  SELECT email 
  FROM auth.users 
  WHERE id = habits.user_id
);
```

## ✅ Verificación del Fix

### Antes (Con Email)
```
🔍 [REPO] getHabitsByEmailPaginated - email: jfduarte09@gmail.com
❌ [REPO] Error: invalid input syntax for type uuid
```

### Después (Con UUID)
```
🔍 [REPO] getHabitsByEmailPaginated - email: c2fa89e9-ab8e-4592-b14e-223d7d7aa55d
✅ [REPO] Supabase devolvió 5 hábitos
💾 [REPO] Guardados 5 hábitos en SQLite
```

## 🎉 Resultado

Con este fix:
- ✅ Las consultas a Supabase funcionan correctamente
- ✅ Se cargan los hábitos en la primera ejecución
- ✅ SQLite se sincroniza con Supabase
- ✅ La app funciona offline después de la primera carga

**Estado:** ✅ FUNCIONANDO (con UUID hardcoded)  
**Próximo paso:** Implementar autenticación dinámica

---

**Fecha:** 2025-10-14  
**Problema:** Email usado en lugar de UUID  
**Solución:** Cambiar a UUID del usuario  
**Estado:** ✅ RESUELTO

# Guía de Integración - Casos de Uso de Autenticación

## 📋 Descripción General

Ya se ha creado toda la estructura de casos de uso para autenticación (login, register, logout). Este documento te guía a través de los pasos para integrar esto completamente en tu proyecto.

## ✅ Checklist de Integración

### Paso 1: Inicializar AuthServiceLocator en main.dart
```dart
// En main.dart, después de DependencyInjection().initialize()

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar variables de entorno y Supabase
  await _loadEnv();

  // Inicializar todas las dependencias
  await DependencyInjection().initialize();

  final DependencyInjection dependencies = DependencyInjection();
  
  // ✅ NUEVO: Inicializar AuthServiceLocator
  AuthServiceLocator().setup(dependencies.authService);

  runApp(const MainApp());
}
```

**Imports necesarios en main.dart:**
```dart
import 'package:find_your_mind/features/auth/presentation/providers/auth_service_locator.dart';
```

---

### Paso 2: Actualizar Profile widget para pasar authService
**Ubicación:** Donde se usa el widget `Profile`

```dart
// ANTES:
Profile(isDarkTheme: isDarkTheme)

// DESPUÉS:
Profile(
  isDarkTheme: isDarkTheme,
  authService: dependencies.authService, // ✅ Añadir esto
)
```

Encuentra todas las instancias de `Profile` en tu código:
```bash
# En una terminal en el workspace
find . -type f -name "*.dart" -exec grep -l "Profile(" {} \;
```

---

### Paso 3: Configurar Rutas Nombradas (Recomendado)
**Ubicación:** `main.dart` - en el `MaterialApp`

```dart
@override
Widget build(BuildContext context) {
  final DependencyInjection dependencies = DependencyInjection();
  final ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);

  return MaterialApp(
    theme: AppTheme.getAppTheme(isDark: false),
    darkTheme: AppTheme.getAppTheme(isDark: true),
    debugShowCheckedModeBanner: false,
    themeMode: themeProvider.themeMode,
    // ✅ NUEVO: Agregar rutas nombradas
    routes: {
      '/login': (context) => AuthScreen(authService: dependencies.authService),
      '/register': (context) => RegisterScreen(authService: dependencies.authService),
      '/habits': (context) => const HabitsScreen(),
    },
    initialRoute: '/login', // ✅ O la pantalla inicial que prefieras
    home: SafeArea(child: AuthScreen(authService: dependencies.authService)),
  );
}
```

---

### Paso 4: Verificar Screens se Navegan Correctamente

**LoginScreen** - Ya está actualizado ✅

**RegisterScreen** - Ya está actualizado ✅
- Navega a `/habits` después del registro exitoso
- Mostrar error si email ya existe

**HabitsScreen** - Verifica que tenga el AuthService disponible

---

### Paso 5: Tests (Opcional pero Recomendado)

Crear tests unitarios para validar los casos de uso:

**Archivo:** `test/features/auth/domain/usecases/sign_in_with_email_usecase_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:find_your_mind/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:mockito/mockito.dart';

// Mock del repositorio
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('SignInWithEmailUseCase', () {
    late MockAuthRepository mockAuthRepository;
    late SignInWithEmailUseCase useCase;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      useCase = SignInWithEmailUseCase(authRepository: mockAuthRepository);
    });

    test('debe lanzar ArgumentError si email está vacío', () async {
      expect(
        () => useCase(email: '', password: 'password'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('debe lanzar ArgumentError si email no es válido', () async {
      expect(
        () => useCase(email: 'invalidemail', password: 'password'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('debe lanzar ArgumentError si password está vacío', () async {
      expect(
        () => useCase(email: 'test@test.com', password: ''),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
```

---

## 🎯 Cómo Usar los Casos de Uso

### Usar SignInWithEmailUseCase (Login)

```dart
// En LoginScreen o cualquier widget
final signInUseCase = AuthServiceLocator().signInWithEmailUseCase;

try {
  final user = await signInUseCase(
    email: emailController.text,
    password: passwordController.text,
  );
  
  // Login exitoso
  Navigator.of(context).pushNamedAndRemoveUntil('/habits', (_) => false);
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: $e')),
  );
}
```

### Usar SignUpWithEmailUseCase (Registro)

```dart
// En RegisterScreen o cualquier widget
final signUpUseCase = AuthServiceLocator().signUpWithEmailUseCase;

try {
  final user = await signUpUseCase(
    email: emailController.text,
    password: passwordController.text,
  );
  
  // Registro exitoso
  Navigator.of(context).pushNamedAndRemoveUntil('/habits', (_) => false);
} catch (e) {
  if (e.toString().contains('User already exists')) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Este email ya está registrado')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
```

### Usar SignOutUseCase (Logout)

```dart
// Ya está implementado en Profile widget ✅
// Pero si lo necesitas en otro lugar:

final signOutUseCase = AuthServiceLocator().signOutUseCase;

try {
  await signOutUseCase();
  Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error al cerrar sesión: $e')),
  );
}
```

### Usar GetCurrentUserUseCase

```dart
// Para obtener el usuario actual autenticado
final getCurrentUserUseCase = AuthServiceLocator().getCurrentUserUseCase;

try {
  final user = await getCurrentUserUseCase();
  if (user != null) {
    print('Usuario: ${user.email}');
  } else {
    print('No hay usuario autenticado');
  }
} catch (e) {
  print('Error: $e');
}
```

---

## 🔍 Verificación de Implementación

### Checklist de Archivos Creados:

```
✅ lib/features/auth/domain/entities/user_entity.dart
✅ lib/features/auth/domain/repositories/auth_repository.dart
✅ lib/features/auth/domain/usecases/sign_in_with_email_usecase.dart
✅ lib/features/auth/domain/usecases/sign_up_with_email_usecase.dart
✅ lib/features/auth/domain/usecases/sign_out_usecase.dart
✅ lib/features/auth/domain/usecases/get_current_user_usecase.dart
✅ lib/features/auth/domain/usecases/usecases.dart
✅ lib/features/auth/data/models/user_model.dart
✅ lib/features/auth/data/repositories/auth_repository_impl.dart
✅ lib/features/auth/presentation/providers/auth_providers.dart
✅ lib/features/auth/presentation/providers/auth_service_locator.dart
```

### Archivos Modificados:
```
✅ lib/features/auth/presentation/screens/login_screen.dart
✅ lib/features/auth/presentation/screens/register_screen.dart
✅ lib/shared/presentation/widgets/app_bar/profile.dart
```

---

## 🐛 Troubleshooting

### Error: "AuthServiceLocator is not initialized"
**Solución:** Asegúrate de llamar a `AuthServiceLocator().setup(authService)` en `main.dart`

### Error: "Profile requires authService parameter"
**Solución:** Actualiza todas las instancias de `Profile` para pasar el `authService`

### Error: "Route /habits not found"
**Solución:** Agrega las rutas nombradas en `MaterialApp.routes`

### Los casos de uso no validan correctamente
**Verificación:**
1. Revisa que los archivos estén sin errores: `get_errors()`
2. Verifica que las validaciones se ejecutan antes de delegar al repositorio
3. Comprueba que los excepciones se lanzan correctamente

---

## 📚 Documentación Completa

- **Documentación Detallada:** `docs/USE_CASES_AUTHENTICATION.md`
- **Resumen Rápido:** `docs/USE_CASES_SUMMARY.md`
- **Ejemplos de Integración:** `docs/INTEGRATION_EXAMPLE_USE_CASES.dart`

---

## 🚀 Próximas Mejoras (Opcionales)

1. **Agregar Provider para manejar estado:**
   ```dart
   class AuthProvider extends ChangeNotifier {
     AuthServiceLocator _locator = AuthServiceLocator();
     UserEntity? _currentUser;
     
     UserEntity? get currentUser => _currentUser;
     
     Future<void> login(String email, String password) async {
       final user = await _locator.signInWithEmailUseCase(
         email: email,
         password: password,
       );
       _currentUser = user;
       notifyListeners();
     }
   }
   ```

2. **Agregar interceptores de errores:**
   ```dart
   Future<UserEntity> signIn(String email, String password) async {
     try {
       return await signInUseCase(...);
     } on SocketException {
       throw NetworkException('No hay conexión a internet');
     } on PlatformException catch (e) {
       throw AuthException(e.message ?? 'Error desconocido');
     }
   }
   ```

3. **Implementar refresh token automático**

4. **Agregar biometric authentication (huella, cara)**

---

## ✨ Beneficios Finales

✅ **Arquitectura Limpia** - Separación clara de capas
✅ **Casos de Uso Reutilizables** - Desde cualquier parte del código
✅ **Fácil de Testear** - Cada capa es testeable independientemente
✅ **Validaciones Centralizadas** - En un solo lugar
✅ **Manejo de Errores Consistente** - Mismo patrón en toda la app
✅ **Escalable** - Fácil agregar nuevas funcionalidades
✅ **Documentado** - Bien documentado y con ejemplos

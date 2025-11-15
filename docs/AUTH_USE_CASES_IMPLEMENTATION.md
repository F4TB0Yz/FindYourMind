# Implementación de Casos de Uso de Autenticación

## Resumen
Se han implementado correctamente los casos de uso para las operaciones de autenticación (login, register y logout) siguiendo los principios de Clean Architecture.

## Casos de Uso Implementados

### 1. **SignInWithEmailUseCase**
- **Ubicación**: `lib/features/auth/domain/usecases/sign_in_with_email_usecase.dart`
- **Responsabilidad**: Gestionar el inicio de sesión con email y contraseña
- **Validaciones**:
  - Email no vacío
  - Contraseña no vacía
  - Formato válido del email
- **Retorna**: `UserEntity` si el login es exitoso
- **Lanza**: Excepciones en caso de error

### 2. **SignUpWithEmailUseCase**
- **Ubicación**: `lib/features/auth/domain/usecases/sign_up_with_email_usecase.dart`
- **Responsabilidad**: Gestionar el registro de nuevos usuarios
- **Validaciones**:
  - Email no vacío
  - Contraseña no vacía
  - Formato válido del email
  - Contraseña mínima de 6 caracteres
- **Retorna**: `UserEntity` si el registro es exitoso
- **Lanza**: Excepciones en caso de error

### 3. **SignOutUseCase**
- **Ubicación**: `lib/features/auth/domain/usecases/sign_out_usecase.dart`
- **Responsabilidad**: Gestionar el cierre de sesión
- **Retorna**: `void`
- **Lanza**: Excepciones en caso de error

### 4. **GetCurrentUserUseCase**
- **Ubicación**: `lib/features/auth/domain/usecases/get_current_user_usecase.dart`
- **Responsabilidad**: Obtener el usuario actualmente autenticado
- **Retorna**: `UserEntity?`

## Cambios Realizados

### 1. **LoginScreen** (`lib/features/auth/presentation/screens/login_screen.dart`)
**Antes:**
```dart
class LoginScreen extends StatelessWidget {
  final AuthService authService;
  // ...
  await authService.signInWithEmail(email, password);
}
```

**Después:**
```dart
class LoginScreen extends StatelessWidget {
  final SignInWithEmailUseCase signInUseCase;
  final SignUpWithEmailUseCase signUpUseCase;
  // ...
  await signInUseCase(email: email, password: password);
}
```

### 2. **RegisterScreen** (`lib/features/auth/presentation/screens/register_screen.dart`)
**Antes:**
```dart
class RegisterScreen extends StatelessWidget {
  final AuthService authService;
  // ...
  await authService.signUpWithEmail(email, password);
}
```

**Después:**
```dart
class RegisterScreen extends StatelessWidget {
  final SignUpWithEmailUseCase signUpUseCase;
  final SignInWithEmailUseCase signInUseCase;
  // ...
  await signUpUseCase(email: email, password: password);
}
```

### 3. **Profile Widget** (`lib/shared/presentation/widgets/app_bar/profile.dart`)
**Antes:**
```dart
class Profile extends StatefulWidget {
  final AuthService authService;
  // ...
  await authService.signOut();
}
```

**Después:**
```dart
class Profile extends StatefulWidget {
  final SignOutUseCase signOutUseCase;
  // ...
  await signOutUseCase();
}
```

### 4. **DependencyInjection** (`lib/core/config/dependency_injection.dart`)
Se agregaron:
- Repositorio de autenticación: `AuthRepository`
- Casos de uso:
  - `SignInWithEmailUseCase`
  - `SignUpWithEmailUseCase`
  - `SignOutUseCase`
  - `GetCurrentUserUseCase`

**Código agregado:**
```dart
// Repositorio
late final AuthRepository _authRepository;

// Casos de uso de Autenticación
late final SignInWithEmailUseCase _signInWithEmailUseCase;
late final SignUpWithEmailUseCase _signUpWithEmailUseCase;
late final SignOutUseCase _signOutUseCase;
late final GetCurrentUserUseCase _getCurrentUserUseCase;

// Inicialización
_authRepository = AuthRepositoryImpl(authService: _authService);
_signInWithEmailUseCase = SignInWithEmailUseCase(authRepository: _authRepository);
_signUpWithEmailUseCase = SignUpWithEmailUseCase(authRepository: _authRepository);
_signOutUseCase = SignOutUseCase(authRepository: _authRepository);
_getCurrentUserUseCase = GetCurrentUserUseCase(authRepository: _authRepository);

// Getters
SignInWithEmailUseCase get signInWithEmailUseCase => _signInWithEmailUseCase;
SignUpWithEmailUseCase get signUpWithEmailUseCase => _signUpWithEmailUseCase;
SignOutUseCase get signOutUseCase => _signOutUseCase;
GetCurrentUserUseCase get getCurrentUserUseCase => _getCurrentUserUseCase;
```

### 5. **AuthScreen** (`lib/features/auth/presentation/screens/auth_screen.dart`)
Se actualizó para recibir los casos de uso y pasarlos a las pantallas correspondientes:
```dart
class AuthScreen extends StatelessWidget {
  final AuthService authService;
  final SignInWithEmailUseCase signInUseCase;
  final SignUpWithEmailUseCase signUpUseCase;
  final SignOutUseCase signOutUseCase;
  // ...
}
```

### 6. **CustomAppBar** (`lib/shared/presentation/widgets/app_bar/custom_app_bar.dart`)
Se actualizó para recibir `SignOutUseCase` y pasarlo al widget `Profile`:
```dart
class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final SignOutUseCase signOutUseCase;
  // ...
}
```

### 7. **Main** (`lib/main.dart`)
Se actualizó para inyectar los casos de uso en `AuthScreen`:
```dart
home: SafeArea(
  child: AuthScreen(
    authService: dependencies.authService,
    signInUseCase: dependencies.signInWithEmailUseCase,
    signUpUseCase: dependencies.signUpWithEmailUseCase,
    signOutUseCase: dependencies.signOutUseCase,
  ),
),
```

## Mejoras Implementadas

### 1. **Feedback Visual Mejorado**
- Se agregaron `SnackBar` con colores apropiados para cada acción:
  - Verde para operaciones exitosas
  - Rojo para errores
  - Naranja para advertencias

### 2. **Validación de Campos**
- Todos los casos de uso incluyen validaciones robustas
- Mensajes de error descriptivos para el usuario

### 3. **Manejo de Errores**
- Captura de excepciones con mensajes apropiados
- Verificación de contexto montado antes de mostrar mensajes

### 4. **Confirmación de Logout**
- Se agregó un diálogo de confirmación antes de cerrar sesión
- Navegación apropiada después del logout

## Arquitectura

```
Presentation Layer (UI)
    ↓
Use Cases (Business Logic)
    ↓
Repository (Abstraction)
    ↓
Data Sources (Implementation)
```

## Beneficios de esta Implementación

1. **Separación de Responsabilidades**: La lógica de negocio está separada de la UI
2. **Testeable**: Los casos de uso pueden ser testeados de forma independiente
3. **Reutilizable**: Los casos de uso pueden ser utilizados en diferentes partes de la aplicación
4. **Mantenible**: Los cambios en la lógica de negocio no afectan directamente a la UI
5. **Escalable**: Fácil agregar nuevos casos de uso sin modificar código existente

## Testing

Los casos de uso pueden ser testeados con mocks del repositorio:

```dart
test('SignInWithEmailUseCase debe retornar UserEntity cuando login exitoso', () async {
  // Arrange
  final mockRepository = MockAuthRepository();
  final useCase = SignInWithEmailUseCase(authRepository: mockRepository);
  
  // Act
  final result = await useCase(email: 'test@test.com', password: '123456');
  
  // Assert
  expect(result, isA<UserEntity>());
});
```

## Próximos Pasos Sugeridos

1. Implementar tests unitarios para los casos de uso
2. Agregar manejo de estados con BLoC o Riverpod
3. Implementar autenticación con Google (ya existe el botón en la UI)
4. Agregar recuperación de contraseña
5. Implementar verificación de email

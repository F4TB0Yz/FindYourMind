# Arquitectura de Casos de Uso - Autenticación

## Descripción General

Se ha implementado una arquitectura limpia basada en casos de uso (Use Cases) para la autenticación en FindYourMind. Esta arquitectura separa claramente las responsabilidades entre capas y facilita el testing, mantenimiento y escalabilidad.

## Estructura de Capas

### 1. **Domain Layer** (Capa de Dominio)
Contiene la lógica de negocio pura, independiente de cualquier framework o librería externa.

#### Entidades:
- **`UserEntity`**: Representa un usuario autenticado con información básica (id, email, displayName, createdAt, lastSignInAt)

#### Repositorios Abstractos:
- **`AuthRepository`**: Interfaz que define el contrato para operaciones de autenticación
  - `getCurrentUser()`: Obtiene el usuario actualmente autenticado
  - `signInWithEmail(email, password)`: Inicia sesión
  - `signUpWithEmail(email, password)`: Registra un nuevo usuario
  - `signOut()`: Cierra la sesión
  - `onAuthStateChange`: Stream de cambios en el estado de autenticación

#### Casos de Uso:
Los casos de uso orquestan la lógica de negocio y son responsables de:
- Validaciones básicas
- Orchestración de operaciones
- Transformación de datos

**Casos implementados:**

1. **`SignInWithEmailUseCase`**
   - Valida email y contraseña
   - Delega al repositorio para autenticación
   - Retorna: `UserEntity`

2. **`SignUpWithEmailUseCase`**
   - Valida email, contraseña (mín. 6 caracteres) y formato
   - Delega al repositorio para registro
   - Retorna: `UserEntity`

3. **`SignOutUseCase`**
   - Cierra la sesión del usuario
   - Delega al repositorio para logout

4. **`GetCurrentUserUseCase`**
   - Obtiene el usuario actualmente autenticado
   - Retorna: `UserEntity?` (null si no hay sesión)

### 2. **Data Layer** (Capa de Datos)
Implementa los repositorios abstractos y maneja la comunicación con fuentes de datos externas.

#### Modelos:
- **`UserModel`**: Extiende `UserEntity` y proporciona:
  - Conversión desde objetos de Supabase (`fromSupabaseUser()`)
  - Serialización a JSON (`toJson()`, `fromJson()`)

#### Repositorios Concretos:
- **`AuthRepositoryImpl`**: Implementación concreta de `AuthRepository`
  - Adapta el `AuthService` al contrato del repositorio
  - Transforma respuestas de Supabase en entidades de dominio
  - Gestiona errores

### 3. **Presentation Layer** (Capa de Presentación)
Maneja la UI, navegación y comunicación con casos de uso.

#### Providers:
- **`auth_providers.dart`**: Factory functions para crear instancias de casos de uso
- **`auth_service_locator.dart`**: Service Locator que actúa como contenedor de inyección de dependencias

#### Pantallas Actualizadas:
- **`LoginScreen`**: 
  - Valida campos
  - Llama al `signInWithEmailUseCase` o directamente al `authService`
  - Manejo robusto de errores con SnackBar

- **`RegisterScreen`**:
  - Valida campos y contraseña mínima
  - Llama al `signUpWithEmailUseCase` o directamente al `authService`
  - Navegación con ruta nombrada `/habits`
  - Manejo de errores mejorado

- **`Profile` (Logout)**:
  - Requiere `authService` inyectado
  - Diálogo de confirmación antes de logout
  - Llama al `signOutUseCase` o directamente al `authService`
  - Navega a `/login` después del logout

## Flujo de Ejecución

### Flujo de Login:
```
LoginScreen
    ↓
onLoginPressed()
    ↓
SignInWithEmailUseCase.call(email, password)
    ↓
Validaciones (email, password no vacíos, formato válido)
    ↓
AuthRepository.signInWithEmail()
    ↓
AuthRepositoryImpl.signInWithEmail()
    ↓
AuthService.signInWithEmail() [Supabase]
    ↓
UserModel.fromSupabaseUser()
    ↓
UserEntity retornado y pantalla actualizada
```

### Flujo de Registro:
```
RegisterScreen
    ↓
onRegisterPressed()
    ↓
SignUpWithEmailUseCase.call(email, password)
    ↓
Validaciones (email, password no vacíos, formato válido, longitud mínima)
    ↓
AuthRepository.signUpWithEmail()
    ↓
AuthRepositoryImpl.signUpWithEmail()
    ↓
AuthService.signUpWithEmail() [Supabase]
    ↓
UserModel.fromSupabaseUser()
    ↓
UserEntity retornado y navegación a /habits
```

### Flujo de Logout:
```
Profile widget
    ↓
_showDropdownMenu()
    ↓
Click "Cerrar sesión"
    ↓
_handleSignOut()
    ↓
Confirmación del usuario
    ↓
SignOutUseCase.call()
    ↓
AuthRepository.signOut()
    ↓
AuthRepositoryImpl.signOut()
    ↓
AuthService.signOut() [Supabase]
    ↓
Navegación a /login y remoción del historial
```

## Inyección de Dependencias

Hay dos formas de usar los casos de uso:

### Opción 1: Usando AuthServiceLocator (Recomendado)

```dart
// En main.dart
void main() {
  final authService = SupabaseAuthService(); // Tu implementación
  AuthServiceLocator().setup(authService);
  
  runApp(const MyApp());
}

// En cualquier widget
final signInUseCase = AuthServiceLocator().signInWithEmailUseCase;
final user = await signInUseCase(email: email, password: password);
```

### Opción 2: Usando funciones factory

```dart
final authRepository = createAuthRepository(authService);
final signInUseCase = createSignInWithEmailUseCase(authRepository);
final user = await signInUseCase(email: email, password: password);
```

## Manejo de Errores

### Validaciones en Casos de Uso:
- Email vacío → `ArgumentError`
- Contraseña vacía → `ArgumentError`
- Email con formato inválido → `ArgumentError`
- Contraseña menor a 6 caracteres (SignUp) → `ArgumentError`

### Errores de Supabase:
- Se propagan desde el repositorio
- Se capturan en la pantalla y se muestran con SnackBar

### Confirmaciones en UI:
- Validación de campos antes de enviar
- Diálogo de confirmación antes de logout
- Mensajes de error descriptivos

## Testing

La arquitectura permite testing fácil:

```dart
// Test de caso de uso
test('SignInWithEmailUseCase valida email no vacío', () async {
  final mockRepository = MockAuthRepository();
  final useCase = SignInWithEmailUseCase(authRepository: mockRepository);
  
  expect(
    () => useCase(email: '', password: 'password'),
    throwsA(isA<ArgumentError>()),
  );
});

// Test de repositorio
test('AuthRepositoryImpl convierte User a UserEntity', () async {
  final mockAuthService = MockAuthService();
  final repository = AuthRepositoryImpl(authService: mockAuthService);
  
  // Configurar mock
  when(mockAuthService.signInWithEmail(any, any))
    .thenAnswer((_) async => mockUser);
  
  final user = await repository.signInWithEmail('test@test.com', 'password');
  
  expect(user, isA<UserEntity>());
});
```

## Archivos Creados/Modificados

### Domain Layer:
- ✅ `lib/features/auth/domain/entities/user_entity.dart`
- ✅ `lib/features/auth/domain/repositories/auth_repository.dart`
- ✅ `lib/features/auth/domain/usecases/sign_in_with_email_usecase.dart`
- ✅ `lib/features/auth/domain/usecases/sign_up_with_email_usecase.dart`
- ✅ `lib/features/auth/domain/usecases/sign_out_usecase.dart`
- ✅ `lib/features/auth/domain/usecases/get_current_user_usecase.dart`
- ✅ `lib/features/auth/domain/usecases/usecases.dart` (barrel export)

### Data Layer:
- ✅ `lib/features/auth/data/models/user_model.dart`
- ✅ `lib/features/auth/data/repositories/auth_repository_impl.dart`

### Presentation Layer:
- ✅ `lib/features/auth/presentation/providers/auth_providers.dart` (factory functions)
- ✅ `lib/features/auth/presentation/providers/auth_service_locator.dart`

### Updated Files:
- ✅ `lib/features/auth/presentation/screens/login_screen.dart` (mejorado)
- ✅ `lib/features/auth/presentation/screens/register_screen.dart` (mejorado)
- ✅ `lib/shared/presentation/widgets/app_bar/profile.dart` (logout implementado)

## Próximos Pasos

1. **Actualizar el widget Profile en donde se use:**
   - Pasar `authService` como parámetro

2. **Configurar rutas nombradas en main.dart:**
   ```dart
   routes: {
     '/login': (context) => const LoginScreen(...),
     '/register': (context) => const RegisterScreen(...),
     '/habits': (context) => const HabitsScreen(),
   }
   ```

3. **Inicializar AuthServiceLocator en main():**
   ```dart
   void main() async {
     await Supabase.initialize(...);
     final authService = SupabaseAuthService(); // o tu implementación
     AuthServiceLocator().setup(authService);
     runApp(const MyApp());
   }
   ```

4. **Tests unitarios** para cada caso de uso

## Beneficios de esta Arquitectura

✅ **Separación de Responsabilidades**: Cada capa tiene una responsabilidad clara
✅ **Testeable**: Fácil de testear con mocks y stubs
✅ **Escalable**: Fácil agregar nuevos casos de uso
✅ **Mantenible**: Cambios aislados sin afectar otras capas
✅ **Independente de Framework**: La lógica de negocio no depende de Flutter o Supabase
✅ **Reutilizable**: Los casos de uso pueden usarse desde cualquier parte de la aplicación

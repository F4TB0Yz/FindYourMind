```
╔══════════════════════════════════════════════════════════════════════════════╗
║           ARQUITECTURA DE CASOS DE USO - SISTEMA DE AUTENTICACIÓN           ║
╚══════════════════════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────────────────────┐
│                         PRESENTATION LAYER (UI)                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────┐    ┌──────────────┐    ┌─────────────┐                   │
│  │ LoginScreen │    │RegisterScreen│    │ Profile     │                   │
│  │             │    │              │    │ (Logout)    │                   │
│  └──────┬──────┘    └──────┬───────┘    └──────┬──────┘                   │
│         │                  │                   │                           │
│         ├──────────────────┼───────────────────┤                           │
│         │                  │                   │                           │
│         v                  v                   v                           │
│  ┌─────────────────────────────────────────────────────────┐              │
│  │    AuthServiceLocator (Service Locator / DI Container)  │              │
│  └─────────────────────────────────────────────────────────┘              │
│                           │                                                │
│         ┌─────────────────┼─────────────────┬─────────────────┐           │
│         │                 │                 │                 │           │
│         v                 v                 v                 v           │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐    │
│  │   SignIn     │ │   SignUp     │ │   SignOut    │ │  GetCurrent  │    │
│  │   UseCase    │ │   UseCase    │ │   UseCase    │ │   UseCase    │    │
│  └──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
                                     ▲
                                     │
┌─────────────────────────────────────────────────────────────────────────────┐
│                          DOMAIN LAYER (Lógica)                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────┐               │
│  │                  AuthRepository (Interface)             │               │
│  │  ────────────────────────────────────────────────────  │               │
│  │  + getCurrentUser()                                     │               │
│  │  + signInWithEmail(email, password)                     │               │
│  │  + signUpWithEmail(email, password)                     │               │
│  │  + signOut()                                            │               │
│  │  + Stream<UserEntity?> onAuthStateChange               │               │
│  └──────────────────┬──────────────────────────────────────┘               │
│                     │                                                      │
│                     │ implementa                                           │
│                     │                                                      │
│                     v                                                      │
│  ┌──────────────────────────────────────────────────────────┐              │
│  │           UserEntity (Domain Model)                      │              │
│  │  ────────────────────────────────────────────────────   │              │
│  │  - id: String                                            │              │
│  │  - email: String                                         │              │
│  │  - displayName: String?                                  │              │
│  │  - createdAt: DateTime                                   │              │
│  │  - lastSignInAt: DateTime?                               │              │
│  └──────────────────────────────────────────────────────────┘              │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
                                     ▲
                                     │
┌─────────────────────────────────────────────────────────────────────────────┐
│                          DATA LAYER (Implementación)                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────┐               │
│  │           AuthRepositoryImpl (Implements)                │               │
│  │  ────────────────────────────────────────────────────  │               │
│  │  - authService: AuthService                             │               │
│  │  + getCurrentUser()                                     │               │
│  │  + signInWithEmail(email, password)                     │               │
│  │  + signUpWithEmail(email, password)                     │               │
│  │  + signOut()                                            │               │
│  │  + Stream<UserEntity?> onAuthStateChange               │               │
│  └──────────────────┬──────────────────────────────────────┘               │
│                     │                                                      │
│                     │ usa / transforma                                    │
│                     │                                                      │
│                     v                                                      │
│  ┌──────────────────────────────────────────────────────────┐              │
│  │              UserModel (Data Model)                      │              │
│  │  ────────────────────────────────────────────────────   │              │
│  │  extends UserEntity                                      │              │
│  │  + fromSupabaseUser(User): UserModel                    │              │
│  │  + toJson(): Map<String, dynamic>                       │              │
│  │  + fromJson(Map): UserModel                             │              │
│  │  + copyWith(...): UserModel                             │              │
│  └──────────────────┬──────────────────────────────────────┘               │
│                     │                                                      │
│                     │ convierte de/a                                       │
│                     │                                                      │
│                     v                                                      │
│  ┌──────────────────────────────────────────────────────────┐              │
│  │           AuthService (External Interface)               │              │
│  │  ────────────────────────────────────────────────────   │              │
│  │  - signInWithEmail(email, password)                     │              │
│  │  - signUpWithEmail(email, password)                     │              │
│  │  - signOut()                                            │              │
│  │  - Stream<AuthState> onAuthStateChange                 │              │
│  └──────────────────┬──────────────────────────────────────┘               │
│                     │                                                      │
│                     │ usa                                                 │
│                     │                                                      │
│                     v                                                      │
│  ┌──────────────────────────────────────────────────────────┐              │
│  │              Supabase Flutter SDK                        │              │
│  │  (Autenticación externa)                                │              │
│  └──────────────────────────────────────────────────────────┘              │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘


╔══════════════════════════════════════════════════════════════════════════════╗
║                         FLUJOS DE EJECUCIÓN                                 ║
╚══════════════════════════════════════════════════════════════════════════════╝

┌────────────────────────────────────────────────────────────────────────────┐
│                          FLUJO DE LOGIN                                    │
└────────────────────────────────────────────────────────────────────────────┘

  User Input          onLoginPressed()
     │                      │
     ├─ email ────────────→ │
     └─ password ────────→ │
                           │
                    Validate Fields ✓
                           │
                    SignInWithEmailUseCase
                           │
                    Validate Email ✓
                    Validate Password ✓
                    Validate Format ✓
                           │
                    AuthRepository.signInWithEmail()
                           │
                    AuthRepositoryImpl
                           │
                    AuthService.signInWithEmail() [Supabase]
                           │
                    UserModel.fromSupabaseUser()
                           │
                    Return UserEntity
                           │
                    ✓ Navigate to /habits
                    ✓ Save User State


┌────────────────────────────────────────────────────────────────────────────┐
│                         FLUJO DE REGISTRO                                  │
└────────────────────────────────────────────────────────────────────────────┘

  User Input          onRegisterPressed()
     │                      │
     ├─ email ────────────→ │
     └─ password ────────→ │
                           │
                    Validate Fields ✓
                    Validate Min Length (6) ✓
                           │
                    SignUpWithEmailUseCase
                           │
                    Validate Email ✓
                    Validate Password ✓
                    Validate Format ✓
                    Validate Min Length (6) ✓
                           │
                    AuthRepository.signUpWithEmail()
                           │
                    AuthRepositoryImpl
                           │
                    AuthService.signUpWithEmail() [Supabase]
                           │
                    UserModel.fromSupabaseUser()
                           │
                    Return UserEntity
                           │
                    ✓ Navigate to /habits
                    ✓ Save User State


┌────────────────────────────────────────────────────────────────────────────┐
│                         FLUJO DE LOGOUT                                    │
└────────────────────────────────────────────────────────────────────────────┘

  User Clicks           Profile Widget
   Logout                   │
     │                      │
     └─────────────→ _showDropdownMenu()
                           │
                    User Confirms ✓
                           │
                    _handleSignOut()
                           │
                    SignOutUseCase
                           │
                    AuthRepository.signOut()
                           │
                    AuthRepositoryImpl
                           │
                    AuthService.signOut() [Supabase]
                           │
                    ✓ Clear User State
                    ✓ Navigate to /login
                    ✓ Clear Navigation Stack


╔══════════════════════════════════════════════════════════════════════════════╗
║                    VALIDACIONES POR CAPA                                    ║
╚══════════════════════════════════════════════════════════════════════════════╝

┌──────────────────────────────────────────────────────────────────────────────┐
│ PRESENTATION LAYER (UI)                                                      │
├──────────────────────────────────────────────────────────────────────────────┤
│ ✓ Campos no vacíos (email, password)                                        │
│ ✓ Validación de longitud mínima (password >= 6)                             │
│ ✓ Mensaje de error con SnackBar                                             │
│ ✓ Diálogo de confirmación antes de logout                                   │
│ ✓ context.mounted check para evitar errores                                 │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│ DOMAIN LAYER (Casos de Uso)                                                 │
├──────────────────────────────────────────────────────────────────────────────┤
│ ✓ Email no vacío                                                            │
│ ✓ Password no vacío                                                         │
│ ✓ Email formato válido (regex)                                              │
│ ✓ Password mínimo 6 caracteres (SignUp)                                    │
│ ✓ Lanzar ArgumentError si validación falla                                 │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│ DATA LAYER (Repositorio)                                                    │
├──────────────────────────────────────────────────────────────────────────────┤
│ ✓ Verificar que el usuario no sea null                                      │
│ ✓ Convertir User de Supabase a UserEntity                                   │
│ ✓ Propagar excepciones de Supabase                                          │
│ ✓ Traducir errores de Supabase a mensajes claros                            │
└──────────────────────────────────────────────────────────────────────────────┘


╔══════════════════════════════════════════════════════════════════════════════╗
║                    INYECCIÓN DE DEPENDENCIAS                                ║
╚══════════════════════════════════════════════════════════════════════════════╝

┌──────────────────────────────────────────────────────────────────────────────┐
│                    FORMA 1: Service Locator (RECOMENDADO)                    │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  // En main.dart                                                            │
│  AuthServiceLocator().setup(dependencies.authService);                     │
│                                                                              │
│  // En cualquier widget                                                     │
│  final signInUseCase = AuthServiceLocator().signInWithEmailUseCase;        │
│  final user = await signInUseCase(email: email, password: password);       │
│                                                                              │
│  Ventajas:                                                                  │
│  ✓ Acceso global                                                            │
│  ✓ Fácil de usar                                                            │
│  ✓ No requiere pasar providers                                              │
│  ✓ Singleton (instancia única)                                              │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│                    FORMA 2: Factory Functions                                │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  final authRepository = createAuthRepository(authService);                  │
│  final signInUseCase = createSignInWithEmailUseCase(authRepository);        │
│  final user = await signInUseCase(email: email, password: password);       │
│                                                                              │
│  Ventajas:                                                                  │
│  ✓ Más explícito                                                            │
│  ✓ Fácil de testear                                                         │
│  ✓ No usa singleton                                                         │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘


╔══════════════════════════════════════════════════════════════════════════════╗
║                         ESTRUCTURA DE ARCHIVOS                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

lib/features/auth/
├── domain/
│   ├── entities/
│   │   └── user_entity.dart ........................ Entidad de Usuario
│   ├── repositories/
│   │   └── auth_repository.dart ................... Interfaz del Repositorio
│   └── usecases/
│       ├── sign_in_with_email_usecase.dart ....... Caso de Uso: Login
│       ├── sign_up_with_email_usecase.dart ....... Caso de Uso: Registro
│       ├── sign_out_usecase.dart ................. Caso de Uso: Logout
│       ├── get_current_user_usecase.dart ......... Caso de Uso: Obtener Usuario
│       └── usecases.dart .......................... Barrel Export
│
├── data/
│   ├── models/
│   │   └── user_model.dart ........................ Modelo de Usuario (Conversiones)
│   └── repositories/
│       └── auth_repository_impl.dart ............. Implementación del Repositorio
│
└── presentation/
    ├── providers/
    │   ├── auth_providers.dart .................... Factory Functions
    │   └── auth_service_locator.dart ............. Service Locator (DI Container)
    ├── screens/
    │   ├── login_screen.dart ...................... ✓ MEJORADO
    │   └── register_screen.dart ................... ✓ MEJORADO
    └── widgets/
        └── [otros widgets]

shared/presentation/widgets/app_bar/
└── profile.dart ................................... ✓ LOGOUT IMPLEMENTADO

docs/
├── USE_CASES_AUTHENTICATION.md ................... Documentación Completa
├── USE_CASES_SUMMARY.md .......................... Resumen Rápido
├── INTEGRATION_GUIDE.md .......................... Guía de Integración
└── INTEGRATION_EXAMPLE_USE_CASES.dart ........... Ejemplos de Código


╔══════════════════════════════════════════════════════════════════════════════╗
║                      CHECKLIST DE VERIFICACIÓN                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

Domain Layer:
  ☑ user_entity.dart creado
  ☑ auth_repository.dart creado
  ☑ sign_in_with_email_usecase.dart creado
  ☑ sign_up_with_email_usecase.dart creado
  ☑ sign_out_usecase.dart creado
  ☑ get_current_user_usecase.dart creado
  ☑ Validaciones correctas

Data Layer:
  ☑ user_model.dart creado
  ☑ auth_repository_impl.dart creado
  ☑ Conversiones de Supabase a UserEntity
  ☑ Manejo de errores

Presentation Layer:
  ☑ auth_providers.dart creado
  ☑ auth_service_locator.dart creado
  ☑ login_screen.dart actualizado
  ☑ register_screen.dart actualizado
  ☑ profile.dart actualizado (logout)

Integración:
  ☐ main.dart actualizado con AuthServiceLocator.setup()
  ☐ Todas las instancias de Profile actualizadas
  ☐ Rutas nombradas configuradas
  ☐ Tests creados

```

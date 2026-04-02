/// Punto de entrada principal de la aplicación FindYourMind.
/// Configura el entorno, inicializa Supabase y establece el árbol de Providers.
import 'package:find_your_mind/config/theme/app_theme.dart';
import 'package:find_your_mind/core/config/dependency_injection.dart';
import 'package:find_your_mind/core/config/supabase_config.dart';
import 'package:find_your_mind/core/utils/app_logger.dart';
import 'package:find_your_mind/features/auth/presentation/screens/auth_screen.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/features/habits/presentation/providers/new_habit_provider.dart';
import 'package:find_your_mind/features/habits/presentation/screens/habits_screen.dart';
import 'package:find_your_mind/features/profile/presentation/screens/profile_screen.dart';
import 'package:find_your_mind/shared/domain/entities/screen_type.dart';
import 'package:find_your_mind/shared/presentation/providers/screen_provider.dart';
import 'package:find_your_mind/shared/presentation/providers/sync_provider.dart';
import 'package:find_your_mind/shared/presentation/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:find_your_mind/features/auth/presentation/providers/auth_service_locator.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar variables de entorno y Supabase
  await _loadEnv();

  // Inicializar todas las dependencias (incluye DatabaseHelper/SQLite)
  await DependencyInjection().initialize();

  final DependencyInjection dependencies = DependencyInjection();

  // 3. Inicializar el Service Locator de Autenticación
  AuthServiceLocator().setup(
    dependencies.authService,
    dependencies.usersRemoteDataSource,
    dependencies.databaseHelper,
  );

  //dependencies.authService.signOut();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) =>
              ScreensProvider(const HabitsScreen(), ScreenType.habits),
        ),
        ChangeNotifierProvider(create: (_) => NewHabitProvider()),
        ChangeNotifierProvider(
          create: (_) => HabitsProvider(
            createHabitUseCase: dependencies.createHabitUseCase,
            updateHabitUseCase: dependencies.updateHabitUseCase,
            deleteHabitUseCase: dependencies.deleteHabitUseCase,
            updateHabitCounterUseCase:
                dependencies.updateHabitCounterUseCase,
            decrementHabitProgressUseCase:
                dependencies.decrementHabitProgressUseCase,
            getCurrentUserUseCase: dependencies.getCurrentUserUseCase,
            repository: dependencies.habitRepository,
          ),
        ),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

Future<void> _loadEnv() async {
  await dotenv.load(fileName: ".env");

  SupabaseConfig.validateConfig();

  // Inicializar Supabase con configuración específica para OAuth
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl!,
    anonKey: SupabaseConfig.supabaseAnonKey!,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      autoRefreshToken: true,
    ),
  );

  // Configurar el listener de deep links para OAuth
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final session = data.session;
    if (session != null) {
      AppLogger.i('🔐 [MAIN] Sesión detectada: ${session.user.email}');
    }
  });

  AppLogger.i('✅ [MAIN] Supabase inicializado con soporte para OAuth/PKCE (Windows)');
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final habitsProvider = Provider.of<HabitsProvider>(
        context,
        listen: false,
      );
      final syncProvider = Provider.of<SyncProvider>(context, listen: false);

      // Conectar SyncProvider con HabitsProvider (bidireccional)
      syncProvider.setOnSyncCompleteCallback(() {
        habitsProvider.refreshHabitsFromLocal();
      });

      // Conectar HabitsProvider con SyncProvider para notificar cambios
      habitsProvider.setSyncProvider(syncProvider);

      // Cargar hábitos iniciales
      habitsProvider.loadHabits();
    });
  }

  @override
  Widget build(BuildContext context) {
    final DependencyInjection dependencies = DependencyInjection();
    final ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      theme: AppTheme.getAppTheme(isDark: false),
      darkTheme: AppTheme.getAppTheme(isDark: true),
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      home: SafeArea(
        child: AuthScreen(
          authService: dependencies.authService,
          signInUseCase: AuthServiceLocator().signInWithEmailUseCase,
          signUpUseCase: AuthServiceLocator().signUpWithEmailUseCase,
          signInWithGoogleUseCase: AuthServiceLocator().signInWithGoogleUseCase,
          signOutUseCase: AuthServiceLocator().signOutUseCase,
        ),
      ),
      routes: {
        '/login': (context) => AuthScreen(
          authService: dependencies.authService,
          signInUseCase: AuthServiceLocator().signInWithEmailUseCase,
          signUpUseCase: AuthServiceLocator().signUpWithEmailUseCase,
          signInWithGoogleUseCase: AuthServiceLocator().signInWithGoogleUseCase,
          signOutUseCase: AuthServiceLocator().signOutUseCase,
        ),
        '/register': (context) => AuthScreen(
          authService: dependencies.authService,
          signInUseCase: AuthServiceLocator().signInWithEmailUseCase,
          signUpUseCase: AuthServiceLocator().signUpWithEmailUseCase,
          signInWithGoogleUseCase: AuthServiceLocator().signInWithGoogleUseCase,
          signOutUseCase: AuthServiceLocator().signOutUseCase,
        ),
        '/habits': (context) => const HabitsScreen(),
        '/profile': (context) => ProfileScreen(
          getCurrentUserUseCase: AuthServiceLocator().getCurrentUserUseCase,
          signOutUseCase: AuthServiceLocator().signOutUseCase,
        ),
      },
    );
  }
}

import 'package:find_your_mind/config/router/app_router.dart';
import 'package:find_your_mind/config/theme/app_theme.dart';
import 'package:find_your_mind/core/config/dependency_injection.dart';
import 'package:find_your_mind/core/config/supabase_config.dart';
import 'package:find_your_mind/core/utils/app_logger.dart';
import 'package:find_your_mind/features/auth/presentation/providers/auth_service_locator.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/features/habits/presentation/providers/new_habit_provider.dart';
import 'package:find_your_mind/shared/presentation/providers/sync_provider.dart';
import 'package:find_your_mind/shared/presentation/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _loadEnv();

  await DependencyInjection().initialize();

  final DependencyInjection dependencies = DependencyInjection();

  AuthServiceLocator().setup(
    dependencies.authService,
    dependencies.usersRemoteDataSource,
    dependencies.databaseHelper,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NewHabitProvider()),
        ChangeNotifierProvider(
          create: (_) => HabitsProvider(
            createHabitUseCase: dependencies.createHabitUseCase,
            updateHabitUseCase: dependencies.updateHabitUseCase,
            deleteHabitUseCase: dependencies.deleteHabitUseCase,
            saveHabitProgressUseCase: dependencies.saveHabitProgressUseCase,
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

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl!,
    anonKey: SupabaseConfig.supabaseAnonKey!,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      autoRefreshToken: true,
    ),
  );

  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final session = data.session;
    if (session != null) {
      AppLogger.i('🔐 [MAIN] Sesión detectada: ${session.user.email}');
    }
  });

  AppLogger.i(
    '✅ [MAIN] Supabase inicializado con soporte para OAuth/PKCE (Windows)',
  );
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

      syncProvider.setOnSyncCompleteCallback(() {
        habitsProvider.refreshHabitsFromLocal();
      });

      habitsProvider.setSyncProvider(syncProvider);
      habitsProvider.loadHabits();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp.router(
      routerConfig: AppRouter.router,
      theme: AppTheme.getAppTheme(isDark: false),
      darkTheme: AppTheme.getAppTheme(isDark: true),
      themeMode: themeProvider.themeMode,
      themeAnimationDuration: Duration.zero,
      debugShowCheckedModeBanner: false,
    );
  }
}

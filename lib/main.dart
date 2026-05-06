import 'dart:ui' show FrameTiming;

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
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  final Stopwatch startupTimer = Stopwatch()..start();
  int startupFramesLogged = 0;

  void onFrameTimings(List<FrameTiming> timings) {
    for (final timing in timings) {
      if (startupFramesLogged >= 5) {
        WidgetsBinding.instance.removeTimingsCallback(onFrameTimings);
        return;
      }

      startupFramesLogged++;
      AppLogger.i(
        '[STARTUP_FRAME] #$startupFramesLogged '
        'build=${timing.buildDuration.inMilliseconds}ms '
        'raster=${timing.rasterDuration.inMilliseconds}ms '
        'total=${timing.totalSpan.inMilliseconds}ms',
      );
    }
  }

  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addTimingsCallback(onFrameTimings);
  AppLogger.i(
    '[STARTUP] Binding listo en ${startupTimer.elapsedMilliseconds}ms',
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final firstFrameMs = startupTimer.elapsedMilliseconds;
    AppLogger.i('[STARTUP] Tiempo hasta primer frame: ${firstFrameMs}ms');
  });

  runApp(BootstrapApp(startupTimer: startupTimer));

  AppLogger.i(
    '[STARTUP] runApp llamado en ${startupTimer.elapsedMilliseconds}ms',
  );
}

class BootstrapApp extends StatefulWidget {
  final Stopwatch startupTimer;

  const BootstrapApp({super.key, required this.startupTimer});

  @override
  State<BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<BootstrapApp> {
  DependencyInjection? _dependencies;
  bool _bootstrapStarted = false;
  bool _showMainApp = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _bootstrapStarted) return;
      _bootstrapStarted = true;
      _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    await _loadEnv();
    AppLogger.i(
      '[STARTUP] _loadEnv completo en ${widget.startupTimer.elapsedMilliseconds}ms',
    );

    final dependencies = DependencyInjection();
    await dependencies.initialize();

    AppLogger.i(
      '[STARTUP] DependencyInjection completo en '
      '${widget.startupTimer.elapsedMilliseconds}ms',
    );

    AuthServiceLocator().setup(
      dependencies.authService,
      dependencies.usersRemoteDataSource,
      dependencies.databaseHelper,
    );

    _warmUpUiRuntime();
    await _precacheStartupAssets();

    if (!mounted) return;
    setState(() {
      _dependencies = dependencies;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _showMainApp) return;
      setState(() {
        _showMainApp = true;
      });
    });

    AppLogger.i(
      '[STARTUP] App lista para providers en '
      '${widget.startupTimer.elapsedMilliseconds}ms',
    );
  }

  void _warmUpUiRuntime() {
    // Fuerza inicialización de singletons costosos de UI fuera del frame de montaje principal.
    AppRouter.router;
    AppTheme.getAppTheme(isDark: false);
    AppTheme.getAppTheme(isDark: true);
    AppLogger.i(
      '[STARTUP] Warm-up UI runtime en ${widget.startupTimer.elapsedMilliseconds}ms',
    );
  }

  Future<void> _precacheStartupAssets() async {
    if (!mounted) return;

    try {
      await precacheImage(
        const AssetImage('assets/images/app_logo.png'),
        context,
      );
      AppLogger.i(
        '[STARTUP] Assets precargados en ${widget.startupTimer.elapsedMilliseconds}ms',
      );
    } catch (e) {
      AppLogger.w('[STARTUP] No se pudo precargar logo', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = _dependencies;

    if (dependencies == null) {
      return const Directionality(
        textDirection: TextDirection.ltr,
        child: ColoredBox(color: Colors.black, child: SizedBox.expand()),
      );
    }

    return MultiProvider(
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
      child: _showMainApp
          ? const MainApp()
          : const Directionality(
              textDirection: TextDirection.ltr,
              child: ColoredBox(color: Colors.black, child: SizedBox.expand()),
            ),
    );
  }
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

  AppLogger.i('✅ [MAIN] Supabase inicializado con soporte para OAuth/PKCE');
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _routerReady = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _routerReady) return;
      setState(() {
        _routerReady = true;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;

        final habitsProvider = Provider.of<HabitsProvider>(
          context,
          listen: false,
        );
        final syncProvider = Provider.of<SyncProvider>(context, listen: false);

        syncProvider.setOnSyncCompleteCallback(() {
          habitsProvider.refreshHabitsFromLocal();
        });

        habitsProvider.setSyncProvider(syncProvider);
        // Fire-and-forget para no encadenar trabajo adicional al callback de frame.
        habitsProvider.loadHabits(startupMode: true);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_routerReady) {
      return const Directionality(
        textDirection: TextDirection.ltr,
        child: ColoredBox(color: Colors.black, child: SizedBox.expand()),
      );
    }

    final ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp.router(
      routerConfig: AppRouter.router,
      locale: const Locale('es'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'),
        Locale('en'),
      ],
      theme: AppTheme.getAppTheme(isDark: false),
      darkTheme: AppTheme.getAppTheme(isDark: true),
      themeMode: themeProvider.themeMode,
      themeAnimationDuration: Duration.zero,
      debugShowCheckedModeBanner: false,
    );
  }
}

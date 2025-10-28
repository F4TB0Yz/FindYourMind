import 'package:find_your_mind/config/theme/app_theme.dart';
import 'package:find_your_mind/core/config/dependency_injection.dart';
import 'package:find_your_mind/core/config/supabase_config.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/features/habits/presentation/providers/new_habit_provider.dart';
import 'package:find_your_mind/features/habits/presentation/screens/habits_screen.dart';
import 'package:find_your_mind/shared/domain/screen_type.dart';
import 'package:find_your_mind/shared/presentation/providers/screen_provider.dart';
import 'package:find_your_mind/shared/presentation/providers/sync_provider.dart';
import 'package:find_your_mind/features/notes/presentation/providers/theme_provider.dart';
import 'package:find_your_mind/shared/presentation/widgets/animated_screen_transition.dart';
import 'package:find_your_mind/shared/presentation/widgets/bottom_nav_bar/custom_bottom_bar.dart';
import 'package:find_your_mind/shared/presentation/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar variables de entorno y Supabase
  await _loadEnv();

  // Inicializar todas las dependencias (incluye DatabaseHelper/SQLite)
  await DependencyInjection().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) =>
              ScreensProvider(const HabitsScreen(), ScreenType.habits),
        ),
        ChangeNotifierProvider(create: (_) => NewHabitProvider()),
        ChangeNotifierProvider(create: (_) => HabitsProvider()),
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
    final ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    final ScreensProvider screensProvider = Provider.of<ScreensProvider>(
      context,
    );

    return MaterialApp(
      theme: AppTheme.getAppTheme(isDark: false),
      darkTheme: AppTheme.getAppTheme(isDark: true),
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      home: SafeArea(
        child: Scaffold(
          appBar: const CustomAppBar(),
          body: Padding(
            padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
            child: AnimatedScreenTransition(
              child: screensProvider.currentPageWidget,
            ),
          ),
          bottomNavigationBar: const CustomBottomBar(),
        ),
      ),
    );
  }
}

import 'package:find_your_mind/core/constants/string_constants.dart';
import 'package:find_your_mind/core/data/supabase_habits_service.dart';
import 'package:find_your_mind/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_progress.dart';
import 'package:find_your_mind/features/habits/domain/usecases/delete_habit_usecase.dart';
import 'package:find_your_mind/features/habits/domain/usecases/update_habit_usecase.dart';
import 'package:flutter/foundation.dart';

class HabitsProvider extends ChangeNotifier {
  String _titleScreen = AppStrings.habitsTitle;
  final List<HabitEntity> _habits = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  static const int _pageSize = 10;
  
  // Casos de uso - inicialización directa
  final UpdateHabitUseCase _updateHabitUseCase = UpdateHabitUseCase(
    HabitRepositoryImpl(SupabaseHabitsService())
  );
  
  final DeleteHabitUseCase _deleteHabitUseCase = DeleteHabitUseCase(
    HabitRepositoryImpl(SupabaseHabitsService())
  );

  String get titleScreen => _titleScreen;
  List<HabitEntity> get habits => _habits;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  void changeTitle(String newTitle) {
    if (_titleScreen == newTitle) return;
    _titleScreen = newTitle;
    notifyListeners();
  }

  void resetTitle() {
    if ( _titleScreen != AppStrings.habitsTitle) {
      _titleScreen = AppStrings.habitsTitle;
      // No es necesario notificar ya que se llama en initState
      // por lo que se cambia antes de construir el widget
      // notifyListeners();
    }
  }

  void addHabit(HabitEntity habit) {
    _habits.add(habit);
    notifyListeners();
  }

  /// Carga la primera página de hábitos
  Future<void> loadHabits() async {
    if (_isLoading) return;
    
    _isLoading = true;
    _currentPage = 0;
    _habits.clear();
    notifyListeners();

    try {
      final SupabaseHabitsService supabaseService = SupabaseHabitsService();
      final HabitRepositoryImpl repository = HabitRepositoryImpl(supabaseService);
      
      final List<HabitEntity> habits = await repository.getHabitsByEmailPaginated(
        email: 'jfduarte09@gmail.com',
        limit: _pageSize,
        offset: 0,
      );
      
      _habits.addAll(habits);
      _hasMore = habits.length == _pageSize;
      _currentPage = 1;
    } catch (e) {
      if (kDebugMode) print('Error loadHabits: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carga más hábitos (lazy loading)
  Future<void> loadMoreHabits() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final SupabaseHabitsService supabaseService = SupabaseHabitsService();
      final HabitRepositoryImpl repository = HabitRepositoryImpl(supabaseService);
      
      final List<HabitEntity> newHabits = await repository.getHabitsByEmailPaginated(
        email: 'jfduarte09@gmail.com',
        limit: _pageSize,
        offset: _currentPage * _pageSize,
      );
      
      _habits.addAll(newHabits);
      _hasMore = newHabits.length == _pageSize;
      _currentPage++;
    } catch (e) {
      if (kDebugMode) print('Error loadMoreHabits: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateHabitProgress(HabitProgress todayProgress) async {
    // Buscar el hábito por ID  
    final habitIndex = _habits.indexWhere(
      (habit) => habit.id == todayProgress.habitId);

    if (habitIndex == -1) return; // Hábito no encontrado

    // Verificar si el progreso ya existe
    final progressIndex = _habits[habitIndex]
      .progress
      .indexWhere((p) => p.id == todayProgress.id);

    if (progressIndex == -1) {
      // Agregar nuevo progreso
      final updatedHabit = _habits[habitIndex]
        .copyWith( progress: [..._habits[habitIndex].progress, todayProgress] );
      _habits[habitIndex] = updatedHabit;
    } else {
      // Actualizar progreso existente
      final updatedProgress = [..._habits[habitIndex].progress];
      updatedProgress[progressIndex] = todayProgress;

      final updatedHabit = _habits[habitIndex]
        .copyWith( progress: updatedProgress );
      _habits[habitIndex] = updatedHabit;
    }
    
    notifyListeners();
  }

  /// Actualiza un hábito existente
  /// 
  /// Utiliza el caso de uso UpdateHabitUseCase que incluye validaciones
  /// y actualiza tanto la base de datos como el estado local
  Future<bool> updateHabit(HabitEntity updatedHabit) async {
    try {
      // Ejecutar el caso de uso (incluye validaciones)
      await _updateHabitUseCase.execute(updatedHabit);
      
      // Actualizar el estado local
      final habitIndex = _habits.indexWhere((h) => h.id == updatedHabit.id);
      if (habitIndex != -1) {
        _habits[habitIndex] = updatedHabit;
        notifyListeners();
      }
      return true;
    } catch (e) {
      if (kDebugMode) print('Error updateHabit: $e');
      return false;
    }
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      await _deleteHabitUseCase.execute(habitId);
      _habits.removeWhere((h) => h.id == habitId);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error deleteHabit: $e');
    }
  }
}

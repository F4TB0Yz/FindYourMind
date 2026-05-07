import 'package:find_your_mind/core/constants/string_constants.dart';
import 'package:find_your_mind/core/utils/app_logger.dart';
import 'package:find_your_mind/core/utils/date_utils.dart';
import 'package:find_your_mind/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_log.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_tracking_type.dart';
import 'package:find_your_mind/features/habits/domain/repositories/habit_repository.dart';
import 'package:find_your_mind/features/habits/domain/usecases/create_habit.dart';
import 'package:find_your_mind/features/habits/domain/usecases/delete_habit_usecase.dart';
import 'package:find_your_mind/features/habits/domain/usecases/save_habit_progress_usecase.dart';
import 'package:find_your_mind/features/habits/domain/usecases/update_habit_usecase.dart';
import 'package:find_your_mind/shared/presentation/providers/sync_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

enum HabitFilter { todos, completados, incompletos }

class HabitsProvider extends ChangeNotifier {
  final CreateHabitUseCase _createHabitUseCase;
  final UpdateHabitUseCase _updateHabitUseCase;
  final DeleteHabitUseCase _deleteHabitUseCase;
  final SaveHabitProgressUseCase _saveHabitProgressUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final HabitRepository _repository;

  String _titleScreen = AppStrings.habitsTitle;
  String? _lastError;
  DateTime? _lastErrorTime;
  bool _isEditing = false;
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  final List<HabitEntity> _habits = [];
  Future<void>? _activeLoadFuture;
  final Map<String, Future<void>> _ongoingDbOperations = {};
  SyncProvider? _syncProvider;
  HabitFilter _activeFilter = HabitFilter.incompletos;
  final Set<String> _completingIds = {};
  final Set<String> _uncompletingIds = {};
  String? _expandedHabitId;
  bool _disposed = false;
  Set<String>? _cachedVisibleIds;

  static const int _pageSize = 10;

  HabitsProvider({
    required CreateHabitUseCase createHabitUseCase,
    required UpdateHabitUseCase updateHabitUseCase,
    required DeleteHabitUseCase deleteHabitUseCase,
    required SaveHabitProgressUseCase saveHabitProgressUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required HabitRepository repository,
  }) : _createHabitUseCase = createHabitUseCase,
       _updateHabitUseCase = updateHabitUseCase,
       _deleteHabitUseCase = deleteHabitUseCase,
       _saveHabitProgressUseCase = saveHabitProgressUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       _repository = repository;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  String get titleScreen => _titleScreen;
  String? get lastError => _lastError;
  DateTime? get lastErrorTime => _lastErrorTime;
  bool get isEditing => _isEditing;
  List<HabitEntity> get habits => List.unmodifiable(_habits);
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  bool get hasError => _lastError != null;

  HabitFilter get activeFilter => _activeFilter;
  String? get expandedHabitId => _expandedHabitId;

  bool isCompletingAnimation(String habitId) => _completingIds.contains(habitId);
  bool isUncompletingAnimation(String habitId) => _uncompletingIds.contains(habitId);

  bool isHabitVisible(String habitId) => _visibleIds.contains(habitId);

  int get visibleHabitCount => _visibleIds.length;

  void _invalidateVisibleIds() {
    _cachedVisibleIds = null;
  }

  Set<String> get _visibleIds {
    return _cachedVisibleIds ??= _habits.where((h) {
      if (_completingIds.contains(h.id)) return true;
      if (_uncompletingIds.contains(h.id)) return true;
      switch (_activeFilter) {
        case HabitFilter.completados:
          return h.isCompletedToday;
        case HabitFilter.incompletos:
          return !h.isCompletedToday;
        case HabitFilter.todos:
          return true;
      }
    }).map((h) => h.id).toSet();
  }

  void setFilter(HabitFilter filter) {
    if (_activeFilter == filter) return;
    _activeFilter = filter;
    _invalidateVisibleIds();
    notifyListeners();
  }

  void toggleExpanded(String habitId) {
    _expandedHabitId = _expandedHabitId == habitId ? null : habitId;
    notifyListeners();
  }

  void triggerCompletionAnimation(String habitId) {
    _completingIds.add(habitId);
    _invalidateVisibleIds();
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (_disposed) return;
      _completingIds.remove(habitId);
      _invalidateVisibleIds();
      notifyListeners();
    });
  }

  void triggerUncompletionAnimation(String habitId) {
    _uncompletingIds.add(habitId);
    _invalidateVisibleIds();
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (_disposed) return;
      _uncompletingIds.remove(habitId);
      _invalidateVisibleIds();
      notifyListeners();
    });
  }

  Future<String?> getUserId() async {
    try {
      final user = await _getCurrentUserUseCase();
      if (user != null && user.id.isNotEmpty) {
        return user.id;
      }
      AppLogger.w('No hay usuario autenticado');
      return null;
    } catch (e) {
      AppLogger.e('Error al obtener usuario', error: e);
      return null;
    }
  }

  int getTodayCount(String habitId) {
    final habitIndex = _habits.indexWhere((habit) => habit.id == habitId);
    if (habitIndex == -1) return 0;
    return _habits[habitIndex].todayValue;
  }

  double get globalTodayProgress => todayProgressSummary.progress;

  TodayProgressSummary get todayProgressSummary {
    if (_habits.isEmpty) {
      return const TodayProgressSummary(
        completedHabits: 0,
        totalHabits: 0,
        progress: 0.0,
      );
    }

    int completedHabits = 0;
    int totalTarget = 0;
    int totalValue = 0;

    for (final habit in _habits) {
      totalTarget += habit.targetValue;
      totalValue += habit.todayValue;

      if (habit.isCompletedToday) {
        completedHabits++;
      }
    }

    final progress = totalTarget == 0
        ? 0.0
        : (totalValue / totalTarget).clamp(0.0, 1.0);

    return TodayProgressSummary(
      completedHabits: completedHabits,
      totalHabits: _habits.length,
      progress: progress,
    );
  }

  WeeklyHabitsStatsSummary get weeklyHabitsStatsSummary {
    final now = DateTime.now();
    final todayIndex = now.weekday - 1;

    if (_habits.isEmpty) {
      return WeeklyHabitsStatsSummary(
        completedHabitsByDay: List<int>.filled(7, 0),
        todayIndex: todayIndex,
      );
    }

    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: now.weekday - 1));
    final weekDates = List.generate(7, (index) {
      final day = monday.add(Duration(days: index));
      return day.toIso8601String().substring(0, 10);
    });

    final completedHabitsByDay = List<int>.filled(7, 0);

    for (int dayIndex = 0; dayIndex < weekDates.length; dayIndex++) {
      final date = weekDates[dayIndex];
      int completedCount = 0;

      for (final habit in _habits) {
        for (final log in habit.logs) {
          if (log.date == date && log.value >= habit.targetValue) {
            completedCount++;
            break;
          }
        }
      }

      completedHabitsByDay[dayIndex] = completedCount;
    }

    return WeeklyHabitsStatsSummary(
      completedHabitsByDay: completedHabitsByDay,
      todayIndex: todayIndex,
    );
  }

  bool canIncrement(String habitId) {
    final habitIndex = _habits.indexWhere((habit) => habit.id == habitId);
    if (habitIndex == -1) return false;

    final habit = _habits[habitIndex];
    if (habit.trackingType == HabitTrackingType.timed) {
      return false;
    }

    return habit.todayValue < habit.targetValue;
  }

  bool canDecrement(String habitId) {
    final habitIndex = _habits.indexWhere((habit) => habit.id == habitId);
    if (habitIndex == -1) return false;

    final habit = _habits[habitIndex];
    if (habit.trackingType != HabitTrackingType.counter) {
      return false;
    }

    return habit.todayValue > 0;
  }

  void _setError(String error) {
    _lastError = error;
    _lastErrorTime = DateTime.now();
    notifyListeners();
    AppLogger.e('Error: $error');
  }

  void clearError() {
    if (_lastError == null) return;
    _lastError = null;
    _lastErrorTime = null;
    notifyListeners();
  }

  Future<void> refreshHabitsFromLocal() async {
    try {
      final userId = await getUserId();
      if (userId == null) return;

      final updatedHabits = await _repository.getHabitsByEmail(userId);
      _habits
        ..clear()
        ..addAll(updatedHabits);
      _invalidateVisibleIds();
      notifyListeners();
    } catch (e) {
      AppLogger.w('Error al refrescar desde SQLite', error: e);
    }
  }

  void setSyncProvider(SyncProvider syncProvider) {
    _syncProvider = syncProvider;
  }

  void _notifyPendingChanges() {
    _syncProvider?.markPendingChanges();
  }

  void handleOneTimeToggle(String habitId, bool isCompletedToday) {
    if (isCompletedToday) {
      triggerUncompletionAnimation(habitId);
      setHabitLogValue(habitId, 0);
    } else {
      triggerCompletionAnimation(habitId);
      updateHabitCounter(habitId);
    }
  }

  void handleTimerTick(String habitId, int seconds, int targetValue) {
    setHabitLogValue(habitId, seconds);
    if (seconds >= targetValue) {
      triggerCompletionAnimation(habitId);
    }
  }

  void handleCounterIncrement(String habitId) {
    final habitIndex = _habits.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) return;
    final habit = _habits[habitIndex];
    if (habit.todayValue + 1 >= habit.targetValue) {
      triggerCompletionAnimation(habitId);
    }
    updateHabitCounter(habitId);
  }

  void handleCounterDecrement(String habitId) {
    final habitIndex = _habits.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) return;
    if (_habits[habitIndex].isCompletedToday) {
      triggerUncompletionAnimation(habitId);
    }
    decrementHabitProgress(habitId);
  }

  void clearAllData() {
    _habits.clear();
    notifyListeners();
  }

  void changeTitle(String newTitle) {
    if (_titleScreen == newTitle) return;
    _titleScreen = newTitle;
    notifyListeners();
  }

  void resetTitle() {
    if (_titleScreen == AppStrings.habitsTitle) return;
    _titleScreen = AppStrings.habitsTitle;
    notifyListeners();
  }

  void changeIsEditing(bool editing) {
    if (_isEditing == editing) return;
    _isEditing = editing;
    notifyListeners();
  }

  Future<void> loadHabits({bool startupMode = false}) async {
    if (_activeLoadFuture != null) {
      return _activeLoadFuture;
    }

    _activeLoadFuture = (() async {
      _isLoading = true;
      clearError();
      if (!startupMode) {
        notifyListeners();
      }

      try {
        final userId = await getUserId();
        if (userId == null) {
          _isLoading = false;
          notifyListeners();
          return;
        }

        final habits = await _repository.getHabitsByEmailPaginated(
          email: userId,
          limit: _pageSize,
          offset: 0,
        );

        _habits.clear();
        for (final habit in habits) {
          if (!_habits.any((item) => item.id == habit.id)) {
            _habits.add(habit);
          }
        }

        _hasMore = habits.length == _pageSize;
        _currentPage = 1;
        _invalidateVisibleIds();
      } catch (e) {
        _setError('Error al cargar los hábitos: ${e.toString()}');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    })();

    try {
      await _activeLoadFuture;
    } finally {
      _activeLoadFuture = null;
    }
  }

  Future<void> loadMoreHabits() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final userId = await getUserId();
      if (userId == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final habits = await _repository.getHabitsByEmailPaginated(
        email: userId,
        limit: _pageSize,
        offset: _currentPage * _pageSize,
      );

      for (final habit in habits) {
        if (!_habits.any((item) => item.id == habit.id)) {
          _habits.add(habit);
        }
      }

      _hasMore = habits.length == _pageSize;
      _currentPage++;
    } catch (e) {
      _setError('Error al cargar más hábitos: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateHabitLogOptimistic(HabitLog todayLog) {
    final habitIndex = _habits.indexWhere((habit) => habit.id == todayLog.habitId);
    if (habitIndex == -1) return;

    final existingHabit = _habits[habitIndex];
    final logIndex = existingHabit.logs.indexWhere((log) => log.date == todayLog.date);

    if (logIndex == -1) {
      _habits[habitIndex] = existingHabit.copyWith(
        logs: [...existingHabit.logs, todayLog],
      );
    } else {
      final updatedLogs = [...existingHabit.logs];
      updatedLogs[logIndex] = todayLog;
      _habits[habitIndex] = existingHabit.copyWith(logs: updatedLogs);
    }

    _invalidateVisibleIds();
    notifyListeners();
  }

  void _queueDbOperation(String habitId, Future<void> Function() operation) {
    final previousOperation = _ongoingDbOperations[habitId] ?? Future.value();
    final newOperation = previousOperation.then((_) => operation());
    _ongoingDbOperations[habitId] = newOperation;

    newOperation.whenComplete(() {
      if (_ongoingDbOperations[habitId] == newOperation) {
        _ongoingDbOperations.remove(habitId);
      }
    });
  }

  Future<bool> updateHabitCounter(String habitId) async {
    try {
      final habitIndex = _habits.indexWhere((habit) => habit.id == habitId);
      if (habitIndex == -1) return false;

      final habit = _habits[habitIndex];
      if (habit.trackingType == HabitTrackingType.timed) {
        return false;
      }

      final todayString = DateInfoUtils.todayString();
      final todayLog = habit.todayLog;
      final isNew = todayLog == null;

      if (!isNew && todayLog.value >= habit.targetValue) {
        return false;
      }

      final optimisticLog = HabitLog(
        id: todayLog?.id ?? const Uuid().v4(),
        habitId: habitId,
        date: todayString,
        value: (todayLog?.value ?? 0) + 1,
      );

      _updateHabitLogOptimistic(optimisticLog);

      _queueDbOperation(habitId, () async {
        final result = await _saveHabitProgressUseCase.execute(
          progress: optimisticLog,
          isNew: isNew,
        );

        result.fold(
          (failure) {
            if (todayLog == null) {
              final index = _habits.indexWhere((item) => item.id == habitId);
              if (index != -1) {
                final updatedLogs = [..._habits[index].logs]
                  ..removeWhere((log) => log.id == optimisticLog.id);
                _habits[index] = _habits[index].copyWith(logs: updatedLogs);
                notifyListeners();
              }
            } else {
              _updateHabitLogOptimistic(todayLog);
            }
            AppLogger.e('Error al guardar log: ${failure.message}');
          },
          (_) => _notifyPendingChanges(),
        );
      });

      return true;
    } catch (e) {
      AppLogger.e('Error inesperado en incremento', error: e);
      return false;
    }
  }

  Future<bool> setHabitLogValue(String habitId, int value) async {
    try {
      final habitIndex = _habits.indexWhere((habit) => habit.id == habitId);
      if (habitIndex == -1) return false;

      final habit = _habits[habitIndex];
      final todayString = DateInfoUtils.todayString();
      final todayLog = habit.todayLog;
      final sanitizedValue = value < 0 ? 0 : value;
      final isNew = todayLog == null;

      final optimisticLog = HabitLog(
        id: todayLog?.id ?? const Uuid().v4(),
        habitId: habitId,
        date: todayString,
        value: sanitizedValue,
      );

      _updateHabitLogOptimistic(optimisticLog);

      _queueDbOperation(habitId, () async {
        final result = await _saveHabitProgressUseCase.execute(
          progress: optimisticLog,
          isNew: isNew,
        );

        result.fold(
          (failure) {
            if (todayLog == null) {
              final index = _habits.indexWhere((item) => item.id == habitId);
              if (index != -1) {
                final updatedLogs = [..._habits[index].logs]
                  ..removeWhere((log) => log.id == optimisticLog.id);
                _habits[index] = _habits[index].copyWith(logs: updatedLogs);
                notifyListeners();
              }
            } else {
              _updateHabitLogOptimistic(todayLog);
            }
            AppLogger.e('Error al guardar log: ${failure.message}');
          },
          (_) => _notifyPendingChanges(),
        );
      });

      return true;
    } catch (e) {
      AppLogger.e('Error inesperado al fijar valor de log', error: e);
      return false;
    }
  }

  Future<bool> decrementHabitProgress(String habitId) async {
    try {
      final habitIndex = _habits.indexWhere((habit) => habit.id == habitId);
      if (habitIndex == -1) return false;

      final habit = _habits[habitIndex];
      if (habit.trackingType != HabitTrackingType.counter) {
        return false;
      }

      final todayLog = habit.todayLog;
      if (todayLog == null || todayLog.value <= 0) {
        return false;
      }

      final optimisticLog = todayLog.copyWith(value: todayLog.value - 1);
      _updateHabitLogOptimistic(optimisticLog);

      _queueDbOperation(habitId, () async {
        final result = await _saveHabitProgressUseCase.execute(
          progress: optimisticLog,
          isNew: false,
        );

        result.fold(
          (failure) {
            _updateHabitLogOptimistic(todayLog);
            AppLogger.e('Error al decrementar: ${failure.message}');
          },
          (_) => _notifyPendingChanges(),
        );
      });

      return true;
    } catch (e) {
      AppLogger.e('Error inesperado en decremento', error: e);
      return false;
    }
  }

  Future<bool> updateHabit(HabitEntity updatedHabit) async {
    try {
      final habitIndex = _habits.indexWhere((habit) => habit.id == updatedHabit.id);
      if (habitIndex == -1) return false;

      if (updatedHabit.targetValue < updatedHabit.todayValue) {
        _setError(
          'La meta no puede ser menor que el valor actual de hoy (${updatedHabit.todayValue})',
        );
        return false;
      }

      final originalHabit = _habits[habitIndex];
      _habits[habitIndex] = updatedHabit;
      notifyListeners();

      _updateHabitUseCase.execute(habit: updatedHabit).then((result) {
        result.fold(
          (failure) {
            final index = _habits.indexWhere((habit) => habit.id == updatedHabit.id);
            if (index != -1) {
              _habits[index] = originalHabit;
              notifyListeners();
            }
            _setError('Error al actualizar hábito: ${failure.message}');
          },
          (_) => _notifyPendingChanges(),
        );
      });

      return true;
    } catch (e) {
      _setError('Error inesperado al actualizar hábito: ${e.toString()}');
      return false;
    }
  }

  String? createHabit(HabitEntity habit) {
    final habitId = const Uuid().v4();
    final logId = const Uuid().v4();
    final today = DateInfoUtils.todayString();

    final initialLog = HabitLog(
      id: logId,
      habitId: habitId,
      date: today,
      value: 0,
    );

    final habitWithId = habit.copyWith(
      id: habitId,
      logs: [initialLog],
    );

    _habits.insert(0, habitWithId);
    notifyListeners();

    _createHabitUseCase.execute(habit: habitWithId).then((result) {
      result.fold(
        (failure) {
          _habits.removeWhere((item) => item.id == habitId);
          notifyListeners();
          _setError('Error al crear hábito: ${failure.message}');
        },
        (_) => _notifyPendingChanges(),
      );
    });

    return habitId;
  }

  Future<bool> deleteHabit(String habitId) async {
    try {
      final habitIndex = _habits.indexWhere((habit) => habit.id == habitId);
      final deletedHabit = habitIndex != -1 ? _habits[habitIndex] : null;

      _habits.removeWhere((habit) => habit.id == habitId);
      notifyListeners();

      _deleteHabitUseCase.execute(habitId: habitId).then((result) {
        result.fold(
          (failure) {
            if (deletedHabit != null && habitIndex != -1) {
              _habits.insert(habitIndex, deletedHabit);
              notifyListeners();
            }
            _setError('Error al eliminar hábito: ${failure.message}');
          },
          (_) => _notifyPendingChanges(),
        );
      });

      return true;
    } catch (e) {
      _setError('Error inesperado al eliminar hábito: ${e.toString()}');
      return false;
    }
  }
}

class TodayProgressSummary {
  final int completedHabits;
  final int totalHabits;
  final double progress;

  const TodayProgressSummary({
    required this.completedHabits,
    required this.totalHabits,
    required this.progress,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TodayProgressSummary &&
        other.completedHabits == completedHabits &&
        other.totalHabits == totalHabits &&
        other.progress == progress;
  }

  @override
  int get hashCode => completedHabits.hashCode ^ totalHabits.hashCode ^ progress.hashCode;
}

class WeeklyHabitsStatsSummary {
  final List<int> completedHabitsByDay;
  final int todayIndex;

  const WeeklyHabitsStatsSummary({
    required this.completedHabitsByDay,
    required this.todayIndex,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WeeklyHabitsStatsSummary &&
        other.todayIndex == todayIndex &&
        listEquals(other.completedHabitsByDay, completedHabitsByDay);
  }

  @override
  int get hashCode => Object.hash(todayIndex, Object.hashAll(completedHabitsByDay));
}

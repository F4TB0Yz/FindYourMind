import 'package:mocktail/mocktail.dart';
import 'package:find_your_mind/features/habits/data/datasources/habits_remote_datasource.dart';
import 'package:find_your_mind/features/habits/data/datasources/habits_local_datasource.dart';
import 'package:find_your_mind/core/network/network_info.dart';
import 'package:find_your_mind/core/network/supabase_client_wrapper.dart';
import 'package:find_your_mind/core/services/sync_service.dart';
import 'package:find_your_mind/features/habits/domain/repositories/habit_repository.dart';

class MockHabitsRemoteDataSource extends Mock implements HabitsRemoteDataSource {}

class MockHabitsLocalDatasource extends Mock implements HabitsLocalDatasource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockSyncService extends Mock implements SyncService {}

class MockHabitRepository extends Mock implements HabitRepository {}

class MockSupabaseClientWrapper extends Mock implements SupabaseClientWrapper {}
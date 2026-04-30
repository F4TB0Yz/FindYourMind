import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:find_your_mind/features/habits/data/datasources/habits_remote_datasource.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_category.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_tracking_type.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_log.dart';
import 'package:find_your_mind/core/error/exceptions.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Cargamos config real del .env
  await dotenv.load(fileName: ".env");
  final realUrl = dotenv.env['SUPABASE_URL'] ?? 'https://fake.supabase.co';
  final realKey = dotenv.env['SUPABASE_ANON_KEY'] ?? 'fake-key';

  late HabitsRemoteDataSourceImpl dataSource;
  late SupabaseClient supabaseClient;

  const tUserId = 'user123';
  final tHabitEntity = HabitEntity(
    id: 'habit123',
    userId: tUserId,
    title: 'Test Habit',
    description: 'Description',
    icon: '🏃',
    category: HabitCategory.health,
    trackingType: HabitTrackingType.single,
    targetValue: 1,
    initialDate: '2025-01-01',
    logs: [],
  );

  group('HabitsRemoteDataSource (Unit tests con config real de .env)', () {
    
    test('createHabit: inserta correctamente (Mocked HTTP)', () async {
      final mockHttpClient = http_testing.MockClient((request) async {
        if (request.url.path.contains('/habits')) {
          return http.Response(
            jsonEncode([{'id': 'habit123'}]), 
            201,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('', 404);
      });

      // Usamos el cliente real pero con transport mockeado para evitar MissingPluginException
      supabaseClient = SupabaseClient(realUrl, realKey, httpClient: mockHttpClient);
      dataSource = HabitsRemoteDataSourceImpl(client: supabaseClient);

      final result = await dataSource.createHabit(tHabitEntity);
      expect(result, 'habit123');
    });

    test('getHabitsByUserId: retorna lista (Mocked HTTP)', () async {
      final mockHttpClient = http_testing.MockClient((request) async {
        if (request.url.path.endsWith('/habits')) {
          return http.Response(jsonEncode([{
            'id': 'h1',
            'user_id': tUserId,
            'title': 'Test',
            'description': 'Desc',
            'icon': '🏃',
            'category': 'health',
            'tracking_type': 'single',
            'target_value': 1,
            'initial_date': '2025-01-01',
            'created_at': '2025-01-01T00:00:00Z',
            'updated_at': '2025-01-01T00:00:00Z',
          }]), 200, headers: {'content-type': 'application/json'});
        }
        if (request.url.path.endsWith('/habit_logs')) {
          return http.Response(jsonEncode([]), 200, headers: {'content-type': 'application/json'});
        }
        return http.Response('', 404);
      });

      supabaseClient = SupabaseClient(realUrl, realKey, httpClient: mockHttpClient);
      dataSource = HabitsRemoteDataSourceImpl(client: supabaseClient);

      final result = await dataSource.getHabitsByUserId(tUserId);
      expect(result.length, 1);
      expect(result.first.id, 'h1');
    });
  });
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:find_your_mind/features/habits/data/datasources/habits_remote_datasource.dart';
import 'package:find_your_mind/core/error/exceptions.dart';
import '../../../../fixtures/habit_fixtures.dart';
import '../../../../fixtures/mocks.dart';

void main() {
  late HabitsRemoteDataSourceImpl dataSource;
  late MockSupabaseClientWrapper mockWrapper;

  setUp(() {
    mockWrapper = MockSupabaseClientWrapper();
    dataSource = HabitsRemoteDataSourceImpl(client: mockWrapper);
  });

  setUpAll(() {
    registerFallbackValue(tHabitEntity);
    registerFallbackValue(tHabitLog);
  });

  group('HabitsRemoteDataSource', () {
    group('createHabit', () {
      test('returns habit id on success', () async {
        when(() => mockWrapper.insertHabit(any())).thenAnswer(
          (_) async => {'id': tHabitId},
        );

        final result = await dataSource.createHabit(tHabitEntity);
        expect(result, tHabitId);
        verify(() => mockWrapper.insertHabit(any())).called(1);
      });

      test('throws ServerException on FormatException', () async {
        when(() => mockWrapper.insertHabit(any())).thenThrow(
          FormatException('Invalid data'),
        );

        expect(
          () => dataSource.createHabit(tHabitEntity),
          throwsA(isA<ServerException>()),
        );
      });

      test('throws NetworkException on SocketException', () async {
        when(() => mockWrapper.insertHabit(any())).thenThrow(
          const SocketException('No internet'),
        );

        expect(
          () => dataSource.createHabit(tHabitEntity),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('getHabitsByUserId', () {
      test('returns list of habits on success', () async {
        when(() => mockWrapper.queryHabits(userId: any(named: 'userId'))).thenAnswer(
          (_) async => [tHabitJson],
        );
        when(() => mockWrapper.queryHabitLogs(habitId: any(named: 'habitId'))).thenAnswer(
          (_) async => [],
        );

        final result = await dataSource.getHabitsByUserId(tUserId);
        expect(result.length, 1);
        expect(result.first.id, tHabitId);
      });

      test('throws ServerException on FormatException', () async {
        when(() => mockWrapper.queryHabits(userId: any(named: 'userId'))).thenThrow(
          FormatException('error'),
        );

        expect(
          () => dataSource.getHabitsByUserId(tUserId),
          throwsA(isA<ServerException>()),
        );
      });

      test('throws NetworkException on SocketException', () async {
        when(() => mockWrapper.queryHabits(userId: any(named: 'userId'))).thenThrow(
          const SocketException('No internet'),
        );

        expect(
          () => dataSource.getHabitsByUserId(tUserId),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('getHabitsByUserIdPaginated', () {
      test('returns paginated habits', () async {
        when(() => mockWrapper.queryHabits(
          userId: any(named: 'userId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        )).thenAnswer(
          (_) async => [tHabitJson],
        );
        when(() => mockWrapper.queryHabitLogs(
          habitId: any(named: 'habitId'),
          limit: any(named: 'limit'),
        )).thenAnswer(
          (_) async => [],
        );

        final result = await dataSource.getHabitsByUserIdPaginated(
          userId: tUserId,
          limit: 10,
          offset: 0,
        );
        expect(result.length, 1);
      });

      test('throws ServerException on FormatException', () async {
        when(() => mockWrapper.queryHabits(
          userId: any(named: 'userId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        )).thenThrow(FormatException('error'));

        expect(
          () => dataSource.getHabitsByUserIdPaginated(userId: tUserId),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('updateHabit', () {
      test('completes successfully', () async {
        when(() => mockWrapper.updateHabit(any(), any())).thenAnswer((_) async {});

        await dataSource.updateHabit(tHabitEntity);
        verify(() => mockWrapper.updateHabit(any(), any())).called(1);
      });

      test('throws ServerException on FormatException', () async {
        when(() => mockWrapper.updateHabit(any(), any())).thenThrow(
          FormatException('error'),
        );

        expect(
          () => dataSource.updateHabit(tHabitEntity),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('deleteHabit', () {
      test('completes successfully', () async {
        when(() => mockWrapper.deleteHabit(any())).thenAnswer((_) async {});

        await dataSource.deleteHabit(tHabitId);
        verify(() => mockWrapper.deleteHabit(tHabitId)).called(1);
      });

      test('throws ServerException on FormatException', () async {
        when(() => mockWrapper.deleteHabit(any())).thenThrow(
          FormatException('error'),
        );

        expect(
          () => dataSource.deleteHabit(tHabitId),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('createHabitLog', () {
      test('returns log id on success', () async {
        when(() => mockWrapper.queryHabitLogs(
          habitId: any(named: 'habitId'),
          date: any(named: 'date'),
        )).thenAnswer((_) async => []);
        when(() => mockWrapper.insertHabitLog(any())).thenAnswer(
          (_) async => {'id': tLogId},
        );

        final result = await dataSource.createHabitLog(tHabitLog);
        expect(result, tLogId);
      });

      test('returns existing log id when duplicate exists', () async {
        when(() => mockWrapper.queryHabitLogs(
          habitId: any(named: 'habitId'),
          date: any(named: 'date'),
        )).thenAnswer(
          (_) async => [{'id': tLogId, 'habit_id': tHabitId, 'date': '2025-01-20', 'value': 1}],
        );

        final result = await dataSource.createHabitLog(tHabitLog);
        expect(result, tLogId);
        verifyNever(() => mockWrapper.insertHabitLog(any()));
      });

      test('throws ServerException on FormatException', () async {
        when(() => mockWrapper.queryHabitLogs(
          habitId: any(named: 'habitId'),
          date: any(named: 'date'),
        )).thenThrow(FormatException('error'));

        expect(
          () => dataSource.createHabitLog(tHabitLog),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('updateHabitLogValue', () {
      test('completes successfully', () async {
        when(() => mockWrapper.updateHabitLog(any(), any(), any())).thenAnswer((_) async {});

        await dataSource.updateHabitLogValue(
          habitId: tHabitId,
          logId: tLogId,
          value: 5,
        );
        verify(() => mockWrapper.updateHabitLog(tHabitId, tLogId, {'value': 5})).called(1);
      });

      test('throws ServerException on FormatException', () async {
        when(() => mockWrapper.updateHabitLog(any(), any(), any())).thenThrow(
          FormatException('error'),
        );

        expect(
          () => dataSource.updateHabitLogValue(
            habitId: tHabitId,
            logId: tLogId,
            value: 5,
          ),
          throwsA(isA<ServerException>()),
        );
      });
    });
  });
}
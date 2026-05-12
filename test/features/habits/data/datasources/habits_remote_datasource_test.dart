import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:find_your_mind/features/habits/data/datasources/habits_remote_datasource.dart';
import 'package:find_your_mind/core/error/exceptions.dart';

import '../../../../test_utils/test_output_style.dart';
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

  group(label('HabitsRemoteDataSource'), () {
    group(label('createHabit'), () {
      test(label('devuelve id de hábito si éxito'), () async {
        when(
          () => mockWrapper.insertHabit(any()),
        ).thenAnswer((_) async => {'id': tHabitId});

        final result = await dataSource.createHabit(tHabitEntity);
        expect(result, tHabitId);
        verify(() => mockWrapper.insertHabit(any())).called(1);
      });

      test(label('lanza ServerException ante FormatException'), () async {
        when(
          () => mockWrapper.insertHabit(any()),
        ).thenThrow(const FormatException('Invalid data'));

        expect(
          () => dataSource.createHabit(tHabitEntity),
          throwsA(isA<ServerException>()),
        );
      });

      test(label('lanza NetworkException ante SocketException'), () async {
        when(
          () => mockWrapper.insertHabit(any()),
        ).thenThrow(const SocketException('No internet'));

        expect(
          () => dataSource.createHabit(tHabitEntity),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group(label('getHabitsByUserId'), () {
      test(label('devuelve lista de hábitos si éxito'), () async {
        when(
          () => mockWrapper.queryHabits(userId: any(named: 'userId')),
        ).thenAnswer((_) async => [tHabitJson]);
        when(
          () => mockWrapper.queryHabitLogs(habitId: any(named: 'habitId')),
        ).thenAnswer((_) async => []);

        final result = await dataSource.getHabitsByUserId(tUserId);
        expect(result.length, 1);
        expect(result.first.id, tHabitId);
      });

      test(label('lanza ServerException ante FormatException'), () async {
        when(
          () => mockWrapper.queryHabits(userId: any(named: 'userId')),
        ).thenThrow(const FormatException('error'));

        expect(
          () => dataSource.getHabitsByUserId(tUserId),
          throwsA(isA<ServerException>()),
        );
      });

      test(label('lanza NetworkException ante SocketException'), () async {
        when(
          () => mockWrapper.queryHabits(userId: any(named: 'userId')),
        ).thenThrow(const SocketException('No internet'));

        expect(
          () => dataSource.getHabitsByUserId(tUserId),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group(label('getHabitsByUserIdPaginated'), () {
      test(label('devuelve hábitos paginados'), () async {
        when(
          () => mockWrapper.queryHabits(
            userId: any(named: 'userId'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => [tHabitJson]);
        when(
          () => mockWrapper.queryHabitLogs(
            habitId: any(named: 'habitId'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => []);

        final result = await dataSource.getHabitsByUserIdPaginated(
          userId: tUserId,
          limit: 10,
          offset: 0,
        );
        expect(result.length, 1);
      });

      test(label('lanza ServerException ante FormatException'), () async {
        when(
          () => mockWrapper.queryHabits(
            userId: any(named: 'userId'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenThrow(const FormatException('error'));

        expect(
          () => dataSource.getHabitsByUserIdPaginated(userId: tUserId),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group(label('updateHabit'), () {
      test(label('completa sin error'), () async {
        when(
          () => mockWrapper.updateHabit(any(), any()),
        ).thenAnswer((_) async {});

        await dataSource.updateHabit(tHabitEntity);
        verify(() => mockWrapper.updateHabit(any(), any())).called(1);
      });

      test(label('lanza ServerException ante FormatException'), () async {
        when(
          () => mockWrapper.updateHabit(any(), any()),
        ).thenThrow(const FormatException('error'));

        expect(
          () => dataSource.updateHabit(tHabitEntity),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group(label('deleteHabit'), () {
      test(label('completa sin error'), () async {
        when(() => mockWrapper.deleteHabit(any())).thenAnswer((_) async {});

        await dataSource.deleteHabit(tHabitId);
        verify(() => mockWrapper.deleteHabit(tHabitId)).called(1);
      });

      test(label('lanza ServerException ante FormatException'), () async {
        when(
          () => mockWrapper.deleteHabit(any()),
        ).thenThrow(const FormatException('error'));

        expect(
          () => dataSource.deleteHabit(tHabitId),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group(label('createHabitLog'), () {
      test(label('devuelve id de log si éxito'), () async {
        when(
          () => mockWrapper.queryHabitLogs(
            habitId: any(named: 'habitId'),
            date: any(named: 'date'),
          ),
        ).thenAnswer((_) async => []);
        when(
          () => mockWrapper.insertHabitLog(any()),
        ).thenAnswer((_) async => {'id': tLogId});

        final result = await dataSource.createHabitLog(tHabitLog);
        expect(result, tLogId);
      });

      test(label('devuelve id existente cuando hay duplicado'), () async {
        when(
          () => mockWrapper.queryHabitLogs(
            habitId: any(named: 'habitId'),
            date: any(named: 'date'),
          ),
        ).thenAnswer(
          (_) async => [
            {
              'id': tLogId,
              'habit_id': tHabitId,
              'date': '2025-01-20',
              'value': 1,
            },
          ],
        );

        final result = await dataSource.createHabitLog(tHabitLog);
        expect(result, tLogId);
        verifyNever(() => mockWrapper.insertHabitLog(any()));
      });

      test(label('lanza ServerException ante FormatException'), () async {
        when(
          () => mockWrapper.queryHabitLogs(
            habitId: any(named: 'habitId'),
            date: any(named: 'date'),
          ),
        ).thenThrow(const FormatException('error'));

        expect(
          () => dataSource.createHabitLog(tHabitLog),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group(label('updateHabitLogValue'), () {
      test(label('completa sin error'), () async {
        when(
          () => mockWrapper.updateHabitLog(any(), any(), any()),
        ).thenAnswer((_) async {});

        await dataSource.updateHabitLogValue(
          habitId: tHabitId,
          logId: tLogId,
          value: 5,
        );
        verify(
          () => mockWrapper.updateHabitLog(tHabitId, tLogId, {'value': 5}),
        ).called(1);
      });

      test(label('lanza ServerException ante FormatException'), () async {
        when(
          () => mockWrapper.updateHabitLog(any(), any(), any()),
        ).thenThrow(const FormatException('error'));

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

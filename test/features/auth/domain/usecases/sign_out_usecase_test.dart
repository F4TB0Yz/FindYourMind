import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:find_your_mind/core/database/app_database.dart';
import 'package:find_your_mind/core/error/failures.dart';
import 'package:find_your_mind/features/auth/domain/repositories/auth_repository.dart';
import 'package:find_your_mind/features/auth/domain/usecases/sign_out_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockDatabaseHelper extends Mock implements AppDatabase {}

void main() {
  late SignOutUseCase usecase;
  late MockAuthRepository mockRepository;
  late MockDatabaseHelper mockDatabaseHelper;

  setUp(() {
    mockRepository = MockAuthRepository();
    mockDatabaseHelper = MockDatabaseHelper();
    usecase = SignOutUseCase(
      authRepository: mockRepository,
      databaseHelper: mockDatabaseHelper,
    );
  });

  test('should clear local tables and sign out from repository', () async {
    // Arrange
    when(() => mockDatabaseHelper.clearAllTables()).thenAnswer((_) async {});
    when(() => mockRepository.signOut()).thenAnswer((_) async => const Right(null));

    // Act
    final result = await usecase();

    // Assert
    expect(result, const Right(null));
    verify(() => mockDatabaseHelper.clearAllTables()).called(1);
    verify(() => mockRepository.signOut()).called(1);
    verifyNoMoreInteractions(mockRepository);
    verifyNoMoreInteractions(mockDatabaseHelper);
  });

  test('should return CacheFailure when database helper fails to clear tables', () async {
    // Arrange
    when(() => mockDatabaseHelper.clearAllTables()).thenThrow(Exception('DB Error'));

    // Act
    final result = await usecase();

    // Assert
    expect(result.isLeft(), true);
    result.fold(
      (failure) {
        expect(failure, isA<CacheFailure>());
        expect(failure.message, contains('Error al limpiar datos locales'));
      },
      (_) => fail('Should have returned a Left'),
    );
    verify(() => mockDatabaseHelper.clearAllTables()).called(1);
    verifyNever(() => mockRepository.signOut());
  });

  test('should return ServerFailure when repository fails to sign out', () async {
    // Arrange
    when(() => mockDatabaseHelper.clearAllTables()).thenAnswer((_) async {});
    const tErrorMessage = 'Connection error during logout';
    when(() => mockRepository.signOut())
        .thenAnswer((_) async => Left(ServerFailure(message: tErrorMessage)));

    // Act
    final result = await usecase();

    // Assert
    expect(result, Left(ServerFailure(message: tErrorMessage)));
    verify(() => mockDatabaseHelper.clearAllTables()).called(1);
    verify(() => mockRepository.signOut()).called(1);
  });
}

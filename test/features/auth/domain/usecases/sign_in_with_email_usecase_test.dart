import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:find_your_mind/core/error/failures.dart';
import 'package:find_your_mind/features/auth/domain/entities/user_entity.dart';
import 'package:find_your_mind/features/auth/domain/repositories/auth_repository.dart';
import 'package:find_your_mind/features/auth/domain/usecases/sign_in_with_email_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignInWithEmailUseCase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = SignInWithEmailUseCase(authRepository: mockRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  final tUser = UserEntity(
    id: '123',
    email: 'test@example.com',
    createdAt: DateTime.now(),
  );

  test('should return UserEntity from the repository when sign in is successful', () async {
    // Arrange
    when(() => mockRepository.signInWithEmail(any(), any()))
        .thenAnswer((_) async => Right(tUser));

    // Act
    final result = await usecase(email: tEmail, password: tPassword);

    // Assert
    expect(result, Right(tUser));
    verify(() => mockRepository.signInWithEmail(tEmail, tPassword)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ServerFailure when repository fails', () async {
    // Arrange
    when(() => mockRepository.signInWithEmail(any(), any()))
        .thenAnswer((_) async => Left(ServerFailure(message: 'Error de servidor')));

    // Act
    final result = await usecase(email: tEmail, password: tPassword);

    // Assert
    expect(result, Left(ServerFailure(message: 'Error de servidor')));
    verify(() => mockRepository.signInWithEmail(tEmail, tPassword)).called(1);
  });

  test('should return ValidationFailure when email is empty', () async {
    // Act
    final result = await usecase(email: '', password: tPassword);

    // Assert
    expect(result, Left(ValidationFailure('El email no puede estar vacío')));
    verifyNever(() => mockRepository.signInWithEmail(any(), any()));
  });

  test('should return ValidationFailure when password is empty', () async {
    // Act
    final result = await usecase(email: tEmail, password: '');

    // Assert
    expect(result, Left(ValidationFailure('La contraseña no puede estar vacía')));
    verifyNever(() => mockRepository.signInWithEmail(any(), any()));
  });

  test('should return ValidationFailure when email format is invalid', () async {
    // Act
    final result = await usecase(email: 'invalid-email', password: tPassword);

    // Assert
    expect(result, Left(ValidationFailure('El formato del email no es válido')));
    verifyNever(() => mockRepository.signInWithEmail(any(), any()));
  });
}

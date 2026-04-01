import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:find_your_mind/core/error/failures.dart';
import 'package:find_your_mind/features/auth/domain/entities/user_entity.dart';
import 'package:find_your_mind/features/auth/domain/repositories/auth_repository.dart';
import 'package:find_your_mind/features/auth/domain/usecases/sign_up_with_email_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignUpWithEmailUseCase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = SignUpWithEmailUseCase(authRepository: mockRepository);
  });

  final tEmail = 'test@example.com';
  final tPassword = 'password123';
  final tUser = UserEntity(
    id: '123',
    email: 'test@example.com',
    createdAt: DateTime.now(),
  );

  test('should return UserEntity from the repository when registration is successful', () async {
    // Arrange
    when(() => mockRepository.signUpWithEmail(any(), any()))
        .thenAnswer((_) async => Right(tUser));

    // Act
    final result = await usecase(email: tEmail, password: tPassword);

    // Assert
    expect(result, Right(tUser));
    verify(() => mockRepository.signUpWithEmail(tEmail, tPassword)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ValidationFailure when password is too short', () async {
    // Act
    final result = await usecase(email: tEmail, password: '123'); // < 6 characters

    // Assert
    expect(result, Left(ValidationFailure('La contraseña debe tener al menos 6 caracteres')));
    verifyNever(() => mockRepository.signUpWithEmail(any(), any()));
  });

  test('should return ValidationFailure when email is invalid', () async {
    // Act
    final result = await usecase(email: 'invalid-email', password: tPassword);

    // Assert
    expect(result, Left(ValidationFailure('El formato del email no es válido')));
    verifyNever(() => mockRepository.signUpWithEmail(any(), any()));
  });

  test('should return ServerFailure when registration fails in repository', () async {
    // Arrange
    const tErrorMessage = 'Este correo ya está registrado.';
    when(() => mockRepository.signUpWithEmail(any(), any()))
        .thenAnswer((_) async => Left(ServerFailure(message: tErrorMessage)));

    // Act
    final result = await usecase(email: tEmail, password: tPassword);

    // Assert
    expect(result, Left(ServerFailure(message: tErrorMessage)));
    verify(() => mockRepository.signUpWithEmail(tEmail, tPassword)).called(1);
  });
}

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:find_your_mind/core/error/failures.dart';
import 'package:find_your_mind/features/auth/domain/entities/user_entity.dart';
import 'package:find_your_mind/features/auth/domain/repositories/auth_repository.dart';
import 'package:find_your_mind/features/auth/domain/usecases/sign_in_with_email_usecase.dart';

import '../../../../test_utils/test_output_style.dart';

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

  test(label('devuelve UserEntity cuando inicio sesión es exitoso'), () async {
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

  test(label('devuelve ServerFailure cuando repositorio falla'), () async {
    // Arrange
    when(() => mockRepository.signInWithEmail(any(), any()))
        .thenAnswer((_) async => Left(ServerFailure(message: 'Error de servidor')));

    // Act
    final result = await usecase(email: tEmail, password: tPassword);

    // Assert
    expect(result, Left(ServerFailure(message: 'Error de servidor')));
    verify(() => mockRepository.signInWithEmail(tEmail, tPassword)).called(1);
  });

  test(label('devuelve ValidationFailure cuando email está vacío'), () async {
    // Act
    final result = await usecase(email: '', password: tPassword);

    // Assert
    expect(result, Left(ValidationFailure('El email no puede estar vacío')));
    verifyNever(() => mockRepository.signInWithEmail(any(), any()));
  });

  test(label('devuelve ValidationFailure cuando contraseña está vacía'), () async {
    // Act
    final result = await usecase(email: tEmail, password: '');

    // Assert
    expect(result, Left(ValidationFailure('La contraseña no puede estar vacía')));
    verifyNever(() => mockRepository.signInWithEmail(any(), any()));
  });

  test(label('devuelve ValidationFailure cuando formato email es inválido'), () async {
    // Act
    final result = await usecase(email: 'invalid-email', password: tPassword);

    // Assert
    expect(result, Left(ValidationFailure('El formato del email no es válido')));
    verifyNever(() => mockRepository.signInWithEmail(any(), any()));
  });
}

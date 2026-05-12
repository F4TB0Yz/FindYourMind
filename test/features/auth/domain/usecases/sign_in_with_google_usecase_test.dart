import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:find_your_mind/core/error/failures.dart';
import 'package:find_your_mind/features/auth/domain/entities/user_entity.dart';
import 'package:find_your_mind/features/auth/domain/repositories/auth_repository.dart';
import 'package:find_your_mind/features/auth/domain/usecases/sign_in_with_google_usecase.dart';

import '../../../../test_utils/test_output_style.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignInWithGoogleUseCase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = SignInWithGoogleUseCase(authRepository: mockRepository);
  });

  final tUser = UserEntity(
    id: 'google-123',
    email: 'google@gmail.com',
    createdAt: DateTime.now(),
  );

  test(label('devuelve UserEntity cuando Google sign-in es exitoso'), () async {
    // Arrange
    when(() => mockRepository.signInWithGoogle())
        .thenAnswer((_) async => Right(tUser));

    // Act
    final result = await usecase();

    // Assert
    expect(result, Right(tUser));
    verify(() => mockRepository.signInWithGoogle()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test(label('devuelve ServerFailure cuando Google sign-in falla'), () async {
    // Arrange
    const tErrorMessage = 'Canceled by user';
    when(() => mockRepository.signInWithGoogle())
        .thenAnswer((_) async => Left(ServerFailure(message: tErrorMessage)));

    // Act
    final result = await usecase();

    // Assert
    expect(result, Left(ServerFailure(message: tErrorMessage)));
    verify(() => mockRepository.signInWithGoogle()).called(1);
  });
}

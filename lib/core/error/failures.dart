import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  /// Mensaje de error descriptivo
  String get message;
  
  @override
  List<Object?> get props => [];
}

/// Falla del servidor
class ServerFailure extends Failure {
  @override
  final String message;

  ServerFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Falla de red (sin conexión)
class NetworkFailure extends Failure {
  @override
  final String message;

  NetworkFailure({this.message = 'Sin conexión a internet'});

  @override
  List<Object?> get props => [message];
}

/// Falla de caché
class CacheFailure extends Failure {
  @override
  final String message;

  CacheFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Falla de validación (datos inválidos)
class ValidationFailure extends Failure {
  @override
  final String message;

  ValidationFailure(this.message);

  @override
  List<Object?> get props => [message];
}

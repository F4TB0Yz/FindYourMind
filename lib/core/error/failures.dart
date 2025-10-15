import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Falla del servidor
class ServerFailure extends Failure {
  final String message;

  ServerFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Falla de red (sin conexión)
class NetworkFailure extends Failure {
  final String message;

  NetworkFailure({this.message = 'Sin conexión a internet'});

  @override
  List<Object?> get props => [message];
}

/// Falla de caché
class CacheFailure extends Failure {
  final String message;

  CacheFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

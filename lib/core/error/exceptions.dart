/// Excepción lanzada cuando hay un error en el servidor
class ServerException implements Exception {
  final String message;
  
  ServerException([this.message = 'Error del servidor']);
  
  @override
  String toString() => 'ServerException: $message';
}

/// Excepción lanzada cuando no hay conexión a internet
class NetworkException implements Exception {
  final String message;
  
  NetworkException([this.message = 'Sin conexión a internet']);
  
  @override
  String toString() => 'NetworkException: $message';
}

/// Excepción lanzada cuando no se encuentra un recurso
class NotFoundException implements Exception {
  final String message;
  
  NotFoundException([this.message = 'Recurso no encontrado']);
  
  @override
  String toString() => 'NotFoundException: $message';
}

/// Excepción de caché
class CacheException implements Exception {
  final String message;
  
  CacheException([this.message = 'Error de caché']);
  
  @override
  String toString() => 'CacheException: $message';
}
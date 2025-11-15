/// Entidad que representa un usuario autenticado
/// Esta es una entidad del dominio (domain layer), independiente de cualquier framework externo
class UserEntity {
  final String id;
  final String email;
  final String? displayName;
  final DateTime createdAt;
  final DateTime? lastSignInAt;

  UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    required this.createdAt,
    this.lastSignInAt,
  });

  /// Copia el usuario con nuevos valores (útil para updates)
  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    DateTime? createdAt,
    DateTime? lastSignInAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
    );
  }

  @override
  String toString() => 'UserEntity(id: $id, email: $email, displayName: $displayName)';
}

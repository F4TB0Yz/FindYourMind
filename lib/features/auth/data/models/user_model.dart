import 'package:find_your_mind/features/auth/domain/entities/user_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Modelo de usuario que extiende UserEntity
/// Responsable de la conversión entre datos de Supabase y la entidad de dominio
class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.email,
    super.displayName,
    required super.createdAt,
    super.lastSignInAt,
  });

  /// Convierte un objeto User de Supabase a UserModel
  factory UserModel.fromSupabaseUser(User user) {
    // createdAt siempre viene como String desde Supabase
    final DateTime createdAt = DateTime.parse(user.createdAt);

    // Convertir lastSignInAt a DateTime si existe
    DateTime? lastSignInAt;
    if (user.lastSignInAt != null) {
      lastSignInAt = DateTime.parse(user.lastSignInAt!);
    }

    return UserModel(
      id: user.id,
      email: user.email ?? '',
      displayName: user.userMetadata?['display_name'] as String?,
      createdAt: createdAt,
      lastSignInAt: lastSignInAt,
    );
  }

  /// Convierte el UserModel a JSON (para persistencia local si es necesario)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt.toIso8601String(),
      'lastSignInAt': lastSignInAt?.toIso8601String(),
    };
  }

  /// Crea un UserModel desde JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastSignInAt: json['lastSignInAt'] != null
          ? DateTime.parse(json['lastSignInAt'] as String)
          : null,
    );
  }

  @override
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    DateTime? createdAt,
    DateTime? lastSignInAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
    );
  }
}

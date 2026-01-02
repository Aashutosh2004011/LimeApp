import 'package:hive/hive.dart';

part 'user.g.dart';

enum UserRole {
  operator,
  supervisor,
}

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final String email;

  @HiveField(1)
  final String token;

  @HiveField(2)
  final String role;

  @HiveField(3)
  final String tenantId;

  User({
    required this.email,
    required this.token,
    required this.role,
    required this.tenantId,
  });

  UserRole get userRole => role == 'supervisor' ? UserRole.supervisor : UserRole.operator;

  User copyWith({
    String? email,
    String? token,
    String? role,
    String? tenantId,
  }) {
    return User(
      email: email ?? this.email,
      token: token ?? this.token,
      role: role ?? this.role,
      tenantId: tenantId ?? this.tenantId,
    );
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'token': token,
        'role': role,
        'tenantId': tenantId,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        email: json['email'],
        token: json['token'],
        role: json['role'],
        tenantId: json['tenantId'],
      );
}
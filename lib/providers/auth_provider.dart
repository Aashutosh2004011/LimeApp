import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_floor_lite/models/user.dart';
import 'package:shop_floor_lite/services/database_service.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class AuthNotifier extends StateNotifier<User?> {
  AuthNotifier() : super(null) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final box = DatabaseService.getUserBox();
    if (box.isNotEmpty) {
      state = box.values.first;
    }
  }

  Future<void> login(String email, String role) async {
    final tenantId = 'TENANT-${_uuid.v4().substring(0, 8).toUpperCase()}';
    final user = User(
      email: email,
      token: 'mock_jwt_token_${_uuid.v4()}',
      role: role,
      tenantId: tenantId,
    );

    final box = DatabaseService.getUserBox();
    await box.clear();
    await box.add(user);

    state = user;
  }

  Future<void> logout() async {
    final box = DatabaseService.getUserBox();
    await box.clear();
    state = null;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});
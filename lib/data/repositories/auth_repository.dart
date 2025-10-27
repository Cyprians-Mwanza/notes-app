import '../../domain/repositories/auth_repository_interface.dart';
import '../../domain/entities/user_entity.dart';
import '../local/shared_prefs/shared_prefs_helper.dart';
class AuthRepository implements AuthRepositoryInterface {
  @override
  Future<UserEntity> login(String email, String password) async {
    try {

      await Future.delayed(const Duration(seconds: 1));

      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password are required');
      }
      if (!email.contains('@')) {
        throw Exception('Please enter a valid email');
      }
      if (password.length < 3) {
        throw Exception('Password must be at least 3 characters');
      }

      final user = UserEntity(
        id: DateTime.now().millisecondsSinceEpoch,
        email: email,
        name: _getNameFromEmail(email),
        token: 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
      );

      await SharedPrefsHelper.saveUserData(
        token: user.token,
        userId: user.id,
        email: user.email,
        name: user.name,
      );

      return user;
    } catch (e) {
      rethrow;
    }
  }

  String _getNameFromEmail(String email) {
    final namePart = email.split('@').first;
    return namePart
        .split('.')
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }

  @override
  Future<void> logout() async {
    await SharedPrefsHelper.clearUserData();
  }

  @override
  Future<bool> checkAuthStatus() async {
    final isLoggedIn = SharedPrefsHelper.isLoggedIn;
    return isLoggedIn;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    if (SharedPrefsHelper.isLoggedIn) {
      final user = UserEntity(
        id: SharedPrefsHelper.userId!,
        email: SharedPrefsHelper.userEmail!,
        name: SharedPrefsHelper.userName!,
        token: SharedPrefsHelper.token!,
      );
      return user;
    };
    return null;
  }
}
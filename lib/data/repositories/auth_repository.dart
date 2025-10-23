import '../../domain/repositories/auth_repository_interface.dart';
import '../../domain/entities/user_entity.dart';
import '../local/shared_prefs/shared_prefs_helper.dart';

class AuthRepository implements AuthRepositoryInterface {
  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      print('AuthRepository - Login attempt with: $email');

      // Mock authentication - simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Simple validation
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password are required');
      }

      if (!email.contains('@')) {
        throw Exception('Please enter a valid email');
      }

      if (password.length < 3) {
        throw Exception('Password must be at least 3 characters');
      }

      // Create user with provided email
      final user = UserEntity(
        id: DateTime.now().millisecondsSinceEpoch,
        email: email,
        name: _getNameFromEmail(email),
        token: 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
      );

      print('AuthRepository - Login successful, saving user data');

      await SharedPrefsHelper.saveUserData(
        token: user.token,
        userId: user.id,
        email: user.email,
        name: user.name,
      );

      return user;
    } catch (e) {
      print('AuthRepository - Login error: $e');
      rethrow;
    }
  }

  String _getNameFromEmail(String email) {
    final namePart = email.split('@').first;
    // Capitalize first letter of each word
    return namePart
        .split('.')
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }

  @override
  Future<void> logout() async {
    print('AuthRepository - Logging out user');
    await SharedPrefsHelper.clearUserData();
    print('AuthRepository - User data cleared successfully');
  }

  @override
  Future<bool> checkAuthStatus() async {
    final isLoggedIn = SharedPrefsHelper.isLoggedIn;
    print('AuthRepository - Check auth status: $isLoggedIn');
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
      print('AuthRepository - Current user: ${user.email}');
      return user;
    }
    print('AuthRepository - No current user');
    return null;
  }
}
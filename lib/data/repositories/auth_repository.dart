import '../../domain/repositories/auth_repository_interface.dart';
import '../../domain/entities/user_entity.dart';
import '../local/shared_prefs/shared_prefs_helper.dart';

class AuthRepository implements AuthRepositoryInterface {
  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      print('AuthRepository - Login attempt with: $email');

      // Mock authentication - simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Simple validation for demo
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password are required');
      }

      // For demo purposes, we'll accept any valid email and password
      // In a real app, you would verify against a database/API
      if (!email.contains('@') || password.length < 6) {
        throw Exception('Invalid email or password');
      }

      // Mock successful login
      final user = UserEntity(
        id: DateTime.now().millisecondsSinceEpoch,
        email: email,
        name: 'User ${email.split('@')[0]}',
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

  @override
  Future<UserEntity> register(String email, String password, String name) async {
    try {
      print('AuthRepository - Register attempt with: $email, $name');

      // Mock registration
      await Future.delayed(const Duration(seconds: 2));

      // Simple validation
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        throw Exception('All fields are required');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      final user = UserEntity(
        id: DateTime.now().millisecondsSinceEpoch,
        email: email,
        name: name,
        token: '', // Empty token since we're not logging in
      );

      print('AuthRepository - Registration successful, but NOT saving user data');

      return user;
    } catch (e) {
      print('AuthRepository - Registration error: $e');
      rethrow;
    }
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
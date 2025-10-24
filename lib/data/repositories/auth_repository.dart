import '../../domain/repositories/auth_repository_interface.dart';
import '../../domain/entities/user_entity.dart';
import '../local/shared_prefs/shared_prefs_helper.dart';

// Authentication repository - implements the auth interface with mock authentication and local storage
class AuthRepository implements AuthRepositoryInterface {
  @override
  // Mock login implementation - validates credentials, creates user, and persists session data
  Future<UserEntity> login(String email, String password) async {
    try {
      print('AuthRepository - Login attempt with: $email');

      // Simulate API call delay for realistic user experience
      await Future.delayed(const Duration(seconds: 1));

      // Input validation
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password are required');
      }
      if (!email.contains('@')) {
        throw Exception('Please enter a valid email');
      }
      if (password.length < 3) {
        throw Exception('Password must be at least 3 characters');
      }

      // Create mock user entity with generated data (no real backend)
      final user = UserEntity(
        id: DateTime.now().millisecondsSinceEpoch, // Use timestamp as unique ID
        email: email,
        name: _getNameFromEmail(email), // Generate display name from email
        token: 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}', // Mock JWT token
      );

      print('AuthRepository - Login successful, saving user data');

      // Persist user data to local storage for session management
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

  // Helper method to generate display name from email address (e.g., john.doe@gmail.com → John Doe)
  String _getNameFromEmail(String email) {
    final namePart = email.split('@').first;
    return namePart
        .split('.')
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }

  @override
  // Logout implementation - clears all persisted user data from local storage
  Future<void> logout() async {
    print('AuthRepository - Logging out user');
    await SharedPrefsHelper.clearUserData();
    print('AuthRepository - User data cleared successfully');
  }

  @override
  // Check if user is currently logged in by verifying local storage flag
  Future<bool> checkAuthStatus() async {
    final isLoggedIn = SharedPrefsHelper.isLoggedIn;
    print('AuthRepository - Check auth status: $isLoggedIn');
    return isLoggedIn;
  }

  @override
  // Retrieve current user data from local storage if user is logged in
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
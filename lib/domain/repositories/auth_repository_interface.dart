import '../entities/user_entity.dart';

// AuthRepositoryInterface - defines the contract for authentication operations (abstraction layer)
abstract class AuthRepositoryInterface {
  Future<UserEntity> login(String email, String password); // Authenticate user and return user entity
  Future<void> logout(); // End user session and clear authentication data
  Future<bool> checkAuthStatus(); // Check if user is currently logged in
  Future<UserEntity?> getCurrentUser(); // Retrieve current user data if authenticated
}
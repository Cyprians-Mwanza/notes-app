import '../entities/user_entity.dart';

abstract class AuthRepositoryInterface {
  Future<UserEntity> login(String email, String password);
  Future<void> logout();
  Future<bool> checkAuthStatus();
  Future<UserEntity?> getCurrentUser();
}
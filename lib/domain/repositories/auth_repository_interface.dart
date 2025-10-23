import '../entities/user_entity.dart';

abstract class AuthRepositoryInterface {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register(String email, String password, String name);
  Future<void> logout();
  Future<bool> checkAuthStatus();
  Future<UserEntity?> getCurrentUser();
}
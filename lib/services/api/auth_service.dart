import '../../models/user.dart';
import '../local/hive_helper.dart';
import '../local/prefs_helper.dart';

class AuthService {
  final HiveHelper _hiveHelper = HiveHelper();
  final PrefsHelper _prefsHelper = PrefsHelper();

  /// Simulate signup (create user and save locally)
  Future<User> signup(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      token: _generateFakeToken(email),
    );

    await _hiveHelper.saveUser(user);
    await _prefsHelper.setLoggedIn(true);
    return user;
  }

  /// Simulate login (check saved user)
  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // simulate network delay

    final user = await _hiveHelper.getUser();
    if (user == null || user.email != email) {
      throw Exception('Invalid email or user not found');
    }

    // Refresh token for realism
    final updatedUser = User(
      id: user.id,
      name: user.name,
      email: user.email,
      token: _generateFakeToken(email),
    );

    await _hiveHelper.saveUser(updatedUser);
    await _prefsHelper.setLoggedIn(true);
    return updatedUser;
  }

  Future<void> logout() async {
    await _prefsHelper.setLoggedIn(false);
  }

  Future<bool> isLoggedIn() async {
    return _prefsHelper.isLoggedIn();
  }

  Future<User?> getCurrentUser() async {
    return _hiveHelper.getUser();
  }

  String _generateFakeToken(String seed) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'token_${seed.hashCode}_$timestamp';
  }
}

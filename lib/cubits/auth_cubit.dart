import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/user.dart';
import '../services/api/auth_service.dart';
import '../services/local/hive_helper.dart';
import '../services/local/prefs_helper.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService = AuthService();
  final HiveHelper _hiveHelper = HiveHelper();
  final PrefsHelper _prefsHelper = PrefsHelper();

  AuthCubit() : super(AuthInitial());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authService.login(email, password);
      await _saveUserSession(user);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signup(String name, String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authService.signup(name, email, password);
      await _saveUserSession(user);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> checkAuthStatus() async {
    final isLoggedIn = await _prefsHelper.isLoggedIn();
    final user = await _hiveHelper.getUser();

    if (isLoggedIn && user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthLoggedOut());
    }
  }

  Future<void> logout() async {
    await _prefsHelper.setLoggedIn(false);
    await _hiveHelper.deleteUser();
    emit(AuthLoggedOut());
  }

  Future<void> _saveUserSession(User user) async {
    await _hiveHelper.saveUser(user);
    await _prefsHelper.setLoggedIn(true);
  }
}

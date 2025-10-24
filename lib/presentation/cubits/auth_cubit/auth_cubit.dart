import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

// AuthCubit - manages authentication state and coordinates login/logout flows
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  // Constructor automatically checks auth status when cubit is created (app startup)
  AuthCubit()
      : _authRepository = AuthRepository(),
        super(AuthInitial()) {
    checkAuthStatus(); // Auto-check authentication on app launch
  }

  // Check if user is logged in by querying local storage - used during app startup
  Future<void> checkAuthStatus() async {
    emit(AuthLoading()); // Show loading state while checking
    try {
      final isLoggedIn = await _authRepository.checkAuthStatus();
      if (isLoggedIn) {
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          emit(AuthAuthenticated(user)); // User is logged in with valid data
        } else {
          emit(AuthUnauthenticated()); // Data inconsistency - treat as not logged in
        }
      } else {
        emit(AuthUnauthenticated()); // User is not logged in
      }
    } catch (e) {
      print('Error checking auth status: $e');
      emit(AuthUnauthenticated()); // Fallback to unauthenticated on error
    }
  }

  // Handle user login flow - validates credentials and creates user session
  Future<void> login(String email, String password) async {
    emit(AuthLoading()); // Show loading state during authentication
    try {
      final user = await _authRepository.login(email, password); // Create and save user
      emit(AuthAuthenticated(user)); // Login successful - update state with user
    } catch (e) {
      emit(AuthError('Login failed: ${e.toString()}')); // Login failed - show error
    }
  }

  // Handle user logout - clears session data and updates authentication state
  Future<void> logout() async {
    try {
      await _authRepository.logout(); // Clear user data from storage
      emit(AuthUnauthenticated()); // Update state to unauthenticated
    } catch (e) {
      emit(AuthError('Logout failed: $e')); // Logout failed - show error
    }
  }
}
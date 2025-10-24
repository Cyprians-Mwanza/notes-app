import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

// AuthState - defines all possible authentication states in the app using Equatable for value equality
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => []; // Equatable requirement for value-based equality
}

class AuthInitial extends AuthState {} // Initial state before any authentication check

class AuthLoading extends AuthState {} // Loading state during authentication operations

class AuthAuthenticated extends AuthState {
  final UserEntity user; // Contains the authenticated user data

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user]; // Equality based on user object
}

class AuthUnauthenticated extends AuthState {} // User is not logged in

class AuthError extends AuthState {
  final String message; // Error message to display to user

  const AuthError(this.message);

  @override
  List<Object?> get props => [message]; // Equality based on error message
}
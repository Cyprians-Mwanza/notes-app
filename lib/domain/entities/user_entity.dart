import 'package:equatable/equatable.dart';

// UserEntity - domain entity representing an authenticated user in business logic
class UserEntity extends Equatable {
  final int id; // Unique user identifier (timestamp-based in current implementation)
  final String email; // User's email address used for authentication
  final String name; // User's display name (generated from email for personalization)
  final String token; // Authentication token for session management (mock JWT in current implementation)

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.token,
  });

  @override
  List<Object> get props => [id, email, name, token]; // Equatable for value-based equality
}
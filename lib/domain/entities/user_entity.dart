import 'package:equatable/equatable.dart';
// import '../../data/models/user.dart' as model;

class UserEntity extends Equatable {
  final int id;
  final String email;
  final String name;
  final String token;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.token,
  });

  @override
  List<Object> get props => [id, email, name, token];
}
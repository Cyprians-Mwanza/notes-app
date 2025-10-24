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

  // factory UserEntity.fromModel(model.User user) {
  //   return UserEntity(
  //     id: user.id,
  //     email: user.email,
  //     name: user.name,
  //     token: user.token,
  //   );
  // }

  // model.User toModel() {
  //   return model.User(
  //     id: id,
  //     email: email,
  //     name: name,
  //     token: token,
  //   );
  // }

  @override
  List<Object> get props => [id, email, name, token];
}
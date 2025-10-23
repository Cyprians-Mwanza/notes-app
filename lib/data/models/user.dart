import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User extends Equatable {
  final int id;
  final String email;
  final String name;
  final String token;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  List<Object> get props => [id, email, name, token];
}
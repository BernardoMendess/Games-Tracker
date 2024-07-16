import 'dart:convert';

class User {

  final int? id;
  final String username;
  final String email;
  final String password;

  User({this.id, required this.username, required this.email, required this.password});

  Map<String, dynamic> toMap() {
    return <String, dynamic> {
      "id": this.id,
      "username": this.username,
      "email": this.email,
      "password": this.password
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map["id"] ??= map["id"],
      username: map["username"] as String,
      email: map["email"] as String,
      password: map["password"] as String
    );
  }

  String toJson() => jsonEncode(toMap());

  factory User.fromJson(String source) => User.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
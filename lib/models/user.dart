import 'note.dart';

class User {
  int? id;
  String email;
  String username;
  String password;
  List<Note> notes;

  User({this.id, required this.email, required this.username, required this.password,required this.notes});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      password: json['password'],
      notes: List<Note>.from(json['notes'].map((x) => Note.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'password': password,
      'notes':  notes.map((x) => x.toJson()).toList() ,
    };
  }
}

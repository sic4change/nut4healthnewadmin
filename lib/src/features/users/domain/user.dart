
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

typedef UserID = String;

@immutable
class User extends Equatable {

  const User({required this.userId, this.username, this.name,
  this.surname, required this.email, this.phone, required this.status,
  required this. role});

  final UserID userId;
  final String? username;
  final String? name;
  final String? surname;
  final String email;
  final String? phone;
  final bool status;
  final String role;

  @override
  List<Object> get props => [userId, username==null, name==null, surname==null, email, phone==null,
    status, role];

  @override
  bool get stringify => true;


  factory User.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for userId: $documentId');
    }
    final username = data['username'] as String?;
    final name = data['name'] as String?;
    final surname = data['surname'] as String?;
    final email = data['email'] as String?;
    final phone = data['phone'] as String?;

    var statusPrev = true;
    if (!data['active']) {
      statusPrev = false;
    }
    final status = statusPrev;
    final role = data['role'] as String;
    if (email == null) {
      throw StateError('missing email for userId: $documentId');
    }
    return User(userId: documentId, username: username, name: name, surname : surname, email : email, phone : phone, status : status, role : role);
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'name': name,
      'surname': surname,
      'email': email,
      'phone': phone,
      'status': status,
      'role': role,
    };
  }
}

/*class User {
  /// Creates the user class with required details.
  User(
      this.username,
      this.surname,
      this.name,
      this.email,
      this.phone,
      this.status,
  );

  /// Name of an user.
  final String name;

  /// Surname of an user.
  final String surname;

  /// Username of an user.
  final String username;

  /// Status of an user.
  final bool status;

  /// Phone of an user.
  final String phone;

  /// Email of an user.
  final String email;

}*/


import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

typedef UserID = String;

@immutable
class User extends Equatable {

  const User({required this.userId, this.username, this.name,
  this.surname, required this.email, this.phone, required this. role, this.dni,
  this.photo, this.point, this.configuration, this.points});

  final UserID userId;
  final String? username;
  final String? name;
  final String? surname;
  final String? dni;
  final String email;
  final String? phone;
  final String role;
  final String? photo;
  final String? point;
  final String? configuration;
  final int? points;

  @override
  List<Object> get props => [userId, username ?? "", name ?? "", surname ?? "",
    role, dni ?? "", email, phone ?? "", photo ?? "", point ?? "",
    configuration ?? "", points ?? 0];

  @override
  bool get stringify => true;


  factory User.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for userId: $documentId');
    }
    final username = data['username'] as String?;
    final name = data['name'] ?? "";
    final surname = data['surname'] ?? "";
    final email = data['email'] as String;
    final phone = data['phone'] ?? "";

    final role = data['role'] as String;
    if (email == null) {
      throw StateError('missing email for userId: $documentId');
    }
    final dni = data['dni'] ?? "";
    final photo = data['photo'] ?? "";
    final point = data['point'] ?? "";
    final configuration = data['configuration'] ?? "";
    final points = data['points'] ?? 0;
    return User(userId: documentId, username: username, name: name,
        surname : surname, email : email, phone : phone, role : role, dni : dni,
    photo : photo, point: point, configuration: configuration, points: points);
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'name': name,
      'surname': surname,
      'email': email,
      'phone': phone,
      'role': role,
      'dni': dni,
      'photo': photo,
      'point': point,
      'configuration': configuration,
      'points': points,
    };
  }
}


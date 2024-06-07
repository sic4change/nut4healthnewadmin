
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

typedef UserID = String;

@immutable
class User extends Equatable {

  const User({
    required this.userId, this.username, this.name,
    this.surname, required this.email, this.phone, required this. role, this.dni,
    this.photo, this.point, this.regionId, this.provinceId, this.configuration, this.points, this.createdate,
    this.active, this.emptyUser, this.address, this.pointTransactionHash,
    this.roleTransactionHash, this.configurationTransactionHash});

  static String currentRegionId = "", currentProvinceId = "", currentRole = "";
  static bool needValidation = false;

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
  final String? regionId;
  final String? provinceId;
  final String? configuration;
  final int? points;
  final DateTime? createdate;
  final bool? active;
  final bool? emptyUser;
  final String? address;
  final String? pointTransactionHash;
  final String? roleTransactionHash;
  final String? configurationTransactionHash;

  @override
  List<Object> get props => [userId, username ?? "", name ?? "", surname ?? "",
    role, dni ?? "", email, phone ?? "", photo ?? "", point ?? "", regionId ?? "", provinceId ?? "",
    configuration ?? "", points ?? 0, createdate ?? DateTime(0, 0, 0),
    active ?? false, emptyUser ?? false,address?? "",  pointTransactionHash ?? "",
    roleTransactionHash ?? "", configurationTransactionHash?? ""];

  @override
  bool get stringify => true;


  factory User.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for userId: $documentId');
    }
    final username = data['username'] as String?;
    final name = data['name'] ?? "";
    final surname = data['surname'] ?? "";
    final email = data['email'] ?? "";
    final phone = data['phone'] ?? "";

    final role = data['role'] ?? "";
    if (email == null) {
      throw StateError('missing email for userId: $documentId');
    }
    final dni = data['dni'] ?? "";
    final photo = data['photo'] ?? "";
    final point = data['point'] ?? "";
    final regionId = data['regionId'] ?? "";
    final provinceId = data['provinceId'] ?? "";
    final configuration = data['configuration'] ?? "";
    final points = data['points'] ?? 0;
    final Timestamp createdateFirebase = data['createdate'] ?? Timestamp(0, 0);
    final createdate = createdateFirebase.toDate();
    final active = data['active'] ?? false;
    final emptyUser = data['emptyUser'] ?? false;
    final address = data ['address'] ?? "";
    final pointTransactionHash = data['pointTransactionHash'] ?? "";
    final roleTransactionHash = data['roleTransactionHash'] ?? "";
    final configurationTransactionHash = data['configurationTransactionHash']?? "";

    return User(
        userId: documentId,
        username: username,
        name: name,
        surname: surname,
        email: email,
        phone: phone,
        role: role,
        dni: dni,
        photo: photo,
        point: point,
        regionId: regionId,
        provinceId: provinceId,
        configuration: configuration,
        points: points,
        createdate: createdate,
        active: active,
        emptyUser: emptyUser,
        address: address,
        pointTransactionHash: pointTransactionHash,
        roleTransactionHash: roleTransactionHash,
        configurationTransactionHash: configurationTransactionHash,
    );
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
      'regionId': regionId,
      'provinceId': provinceId,
      'configuration': configuration,
      'points': points,
      'createdate': createdate,
      'active': active,
      'emptyUser': emptyUser,
      'address': address,
      'pointTransactionHash': pointTransactionHash,
      'roleTransactionHash': roleTransactionHash,
      'configurationTransactionHash': configurationTransactionHash,
    };
  }
}


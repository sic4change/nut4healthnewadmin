import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

typedef TutorID = String;

@immutable
class Tutor extends Equatable {
  const Tutor({
    required this.tutorId,
    required this.pointId,
    required this.name,
    required this.surnames,
    required this.address,
    required this.phone,
    required this.birthdate,
    required this.lastDate,
    required this.ethnicity,
    required this.sex,
    required this.weight,
    required this.height,
    required this.status,
    required this.pregnant,
    required this.weeks,
    required this.childMinor,
    required this.observations,
    required this.active,
  });

  final TutorID tutorId;
  final String pointId;
  final String name;
  final String surnames;
  final String address;
  final String phone;
  final DateTime birthdate;
  final DateTime lastDate;
  final String ethnicity;
  final String sex;
  final double weight;
  final double height;
  final String status;
  final String pregnant;
  final int weeks;
  final String childMinor;
  final String observations;
  final bool active;

  @override
  List<Object> get props => [tutorId, pointId, name, surnames, address, phone,
    birthdate,lastDate, ethnicity, sex, weight, height, status, weeks,
    observations, active, ];

  @override
  bool get stringify => true;

  factory Tutor.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for tutorId: $documentId');
    }
    final pointId = data['point'] as String;
    final name = data['name'] as String;
    final surnames = data['surnames'] as String;
    final address = data['address'] as String;
    final phone = data['phone'] as String;
    final Timestamp birthdateFirebase = data['birthdate'] ?? Timestamp(0, 0);
    final birthdate = birthdateFirebase.toDate();
    final Timestamp lastDateFirebase = data['lastDate'] ?? Timestamp(0, 0);
    final lastDate = lastDateFirebase.toDate();
    final ethnicity = data['ethnicity'] as String;
    final sex = data['sex'] as String;
    final weight = data['weight']?? 0.0;
    final height = data['height']?? 0.0;
    final status = data['status']?? "";
    final pregnant = data['pregnant'] as String;
    final weeks = data['weeks'] as int;
    final childMinor = data['childMinor']?? "";
    final observations = data['observations'] as String;
    final active = data['active'] as bool;

    return Tutor(
      tutorId: documentId,
      pointId: pointId,
      name: name,
      surnames: surnames,
      address: address,
      phone: phone,
      birthdate: birthdate,
      lastDate: lastDate,
      ethnicity: ethnicity,
      sex: sex,
      weight: weight,
      height: height,
      status: status,
      pregnant: pregnant,
      weeks: weeks,
      childMinor: childMinor,
      observations: observations,
      active: active,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'point': pointId,
      'name': name,
      'surnames': surnames,
      'address': address,
      'phone': phone,
      'birthdate': birthdate,
      'lastDate': lastDate,
      'ethnicity': ethnicity,
      'sex': sex,
      'weight': weight,
      'height': height,
      'status': status,
      'pregnant': pregnant,
      'weeks': weeks,
      'childMinor': childMinor,
      'observations': observations,
      'active': active,
    };
  }
}

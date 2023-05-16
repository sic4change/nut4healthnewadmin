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
    required this.createDate,
    required this.ethnicity,
    required this.sex,
    required this.maleRelation,
    required this.womanStatus,
    required this.armCircunference,
    required this.status,
    required this.babyAge,
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
  final DateTime createDate;
  final String ethnicity;
  final String sex;
  final String maleRelation;
  final String womanStatus;
  final double armCircunference;
  final String status;
  final int babyAge;
  final int weeks;
  final String childMinor;
  final String observations;
  final bool active;

  @override
  List<Object> get props => [tutorId, pointId, name, surnames, address, phone,
    birthdate,createDate, ethnicity, sex, maleRelation, womanStatus, babyAge,
    armCircunference, status, weeks, observations, active, ];

  @override
  bool get stringify => true;

  factory Tutor.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for tutorId: $documentId');
    }
    final pointId = data['point']?? "";
    final name = data['name']?? "";
    final surnames = data['surnames']?? "";
    final address = data['address']?? "";
    final phone = data['phone']?? "";
    final Timestamp birthdateFirebase = data['birthdate'] ?? Timestamp(0, 0);
    final birthdate = birthdateFirebase.toDate();
    final Timestamp createDateFirebase = data['createDate'] ?? Timestamp(0, 0);
    final createDate = createDateFirebase.toDate();
    final ethnicity = data['ethnicity']?? "";
    final sex = data['sex']?? "";
    final maleRelation = data['maleRelation']?? "";
    final womanStatus = data['womanStatus']?? "";
    final armCircunference = data ['armCircunference']?? 0.0;
    final status = data['status']?? "";
    final babyAge = data['babyAge']?? 0;
    final weeks = data['weeks']?? 0;
    final childMinor = data['childMinor']?? "";
    final observations = data['observations']?? "";
    final active = data['active']?? false;

    return Tutor(
      tutorId: documentId,
      pointId: pointId,
      name: name,
      surnames: surnames,
      address: address,
      phone: phone,
      birthdate: birthdate,
      createDate: createDate,
      ethnicity: ethnicity,
      sex: sex,
      maleRelation: maleRelation,
      womanStatus: womanStatus,
      armCircunference: armCircunference,
      status: status,
      babyAge: babyAge,
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
      'createDate': createDate,
      'ethnicity': ethnicity,
      'sex': sex,
      'maleRelation': maleRelation,
      'womanStatus': womanStatus,
      'armCircunference': armCircunference,
      'status': status,
      'babyAge': babyAge,
      'weeks': weeks,
      'childMinor': childMinor,
      'observations': observations,
      'active': active,
    };
  }
}

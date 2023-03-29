import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

typedef ChildID = String;

@immutable
class Child extends Equatable {
  const Child({
    required this.childId,
    required this.tutorId,
    required this.pointId,
    required this.name,
    required this.surnames,
    required this.birthdate,
    required this.createDate,
    required this.lastDate,
    required this.ethnicity,
    required this.sex,
    required this.observations,
  });

  final ChildID childId;
  final String tutorId;
  final String pointId;
  final String name;
  final String surnames;
  final DateTime birthdate;
  final DateTime createDate;
  final DateTime lastDate;
  final String ethnicity;
  final String sex;
  final String observations;

  @override
  List<Object> get props => [childId, tutorId, pointId, name, surnames,
    birthdate, createDate, lastDate, ethnicity, sex, observations,];

  @override
  bool get stringify => true;

  factory Child.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for childId: $documentId');
    }
    final tutorId = data['tutorId']?? "";
    final pointId = data['point']?? "";
    final name = data['name']?? "";
    final surnames = data['surnames']?? "";
    final Timestamp birthdateFirebase = data['birthdate'] ?? Timestamp(0, 0);
    final birthdate = birthdateFirebase.toDate();
    final Timestamp createtDateFirebase = data['createDate'] ?? Timestamp(0, 0);
    final createtDate = createtDateFirebase.toDate();
    final Timestamp lastDateFirebase = data['lastDate'] ?? Timestamp(0, 0);
    final lastDate = lastDateFirebase.toDate();
    final ethnicity = data['ethnicity']?? "";
    final sex = data['sex']?? "";
    final observations = data['observations']?? "";

    return Child(
      childId: documentId,
      tutorId: tutorId,
      pointId: pointId,
      name: name,
      surnames: surnames,
      birthdate: birthdate,
      createDate: createtDate,
      lastDate: lastDate,
      ethnicity: ethnicity,
      sex: sex,
      observations: observations,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tutorId': tutorId,
      'point': pointId,
      'name': name,
      'surnames': surnames,
      'birthdate': birthdate,
      'createDate': createDate,
      'lastDate': lastDate,
      'ethnicity': ethnicity,
      'sex': sex,
      'observations': observations,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

typedef CaseID = String;

@immutable
class Case extends Equatable {
  const Case({
    required this.caseId,
    required this.pointId,
    required this.childId,
    required this.tutorId,
    required this.fefaId,
    required this.name,
    required this.createDate,
    required this.lastDate,
    required this.observations,
    required this.status,
    required this.visits,
    required this.chefValidation,
    required this.regionalValidation,
    required this.admissionType,
    required this.admissionTypeServer,
    required this.closedReason,
  });

  final CaseID caseId;
  final String pointId;
  final String childId;
  final String tutorId;
  final String fefaId;
  final String name;
  final DateTime createDate;
  final DateTime lastDate;
  final String observations;
  final String status;
  final int visits;
  final bool chefValidation;
  final bool regionalValidation;
  final String admissionType;
  final String admissionTypeServer;
  final String closedReason;

  @override
  List<Object> get props => [caseId, pointId, childId, tutorId, fefaId, name,
    createDate, lastDate, observations, status, visits, chefValidation, regionalValidation,
    admissionType, admissionTypeServer, closedReason];

  @override
  bool get stringify => true;

  factory Case.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for caseId: $documentId');
    }
    final pointId = data['point']?? "";
    final childId = data['childId']?? "";
    final tutorId = data['tutorId']?? "";
    final fefaId = data['fefaId']?? "";
    final name = data['name']?? "";
    final Timestamp createtDateFirebase = data['createdate'] ?? Timestamp(0, 0);
    final createDate = createtDateFirebase.toDate();
    final Timestamp lastDateFirebase = data['lastdate'] ?? Timestamp(0, 0);
    final lastDate = lastDateFirebase.toDate();
    final observations = data['observations']?? "";
    final status = data['status']?? "";
    final visits = data['visits']?? 0;
    final chefValidation = data['chefValidation']?? false;
    final regionalValidation = data['regionalValidation']?? false;
    final admissionType = data['admissionType']?? "";
    String admissionTypeServer = data['admissionTypeServer']?? "New Admission";
    if (admissionTypeServer.isEmpty) admissionTypeServer = "New Admission";
    // Si closedReason es NULL lo escribimos como null para distinguirlo de las que vienen cadenas vacías del servidor
    final closedReason = data['closedReason']?? "null";

    return Case(
      caseId: documentId,
      pointId: pointId,
      childId: childId,
      tutorId: tutorId,
      fefaId: fefaId,
      name: name,
      createDate: createDate,
      lastDate: lastDate,
      observations: observations,
      status: status,
      visits: visits,
      chefValidation: chefValidation,
      regionalValidation: regionalValidation,
      admissionType: admissionType,
      admissionTypeServer: admissionTypeServer,
      closedReason: closedReason,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'point': pointId,
      'childId': childId,
      'tutorId': tutorId,
      'fefaId': fefaId,
      'name': name,
      'createDate': createDate,
      'lastDate': lastDate,
      'observations': observations,
      'status': status,
      'visits': visits,
      'chefValidation': chefValidation,
      'regionalValidation': regionalValidation,
      'admissionType': admissionType,
      'admissionTypeServer': admissionTypeServer,
      'closedReason': closedReason,
    };
  }
}

class CaseType {
  // admissionTypeServer
  static String newAdmission = 'New Admission';
  static String relapse = 'Relapse'; // TODO: Not using for now
  static String reAdmission = 'Readmission';
  // closedReason
  static String recovered = 'Recovered';
  static String unresponsive = 'Unresponsive';
  static String death = 'Death';
  static String abandonment = 'Abandonment';
  // Both
  static String referred = 'Referred';
  static String transfered = 'Transfered';
}

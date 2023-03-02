
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

typedef ContractID = String;

@immutable
class Contract extends Equatable {

  const Contract({required this.contractId, this.status, this.code, this.point,
    this.screenerId, this.medicalId, this.armCircunference, this.armCircumferenceMedical});

  final ContractID contractId;
  final String? status;
  final String? code;
  final String? point;
  final String? screenerId;
  final String? medicalId;
  final double? armCircunference;
  final double? armCircumferenceMedical;

  @override
  List<Object> get props => [contractId, status ?? "", code ?? "", point ?? "",
    screenerId ?? "", medicalId ?? "", armCircunference ?? 0.0, armCircumferenceMedical ?? 0.0];

  @override
  bool get stringify => true;


  factory Contract.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for contractId: $documentId');
    }

    final status = data['status'] ?? "";
    final code = data['code'] ?? "";
    final point = data['point'] ?? "";
    final screenerId = data['screenerId'] ?? "";
    final medicalId = data['medicalId'] ?? "";
    final armCircunference = data['arm_circumference']  ?? 0.0;
    final armCircumferenceMedical = data['arm_circumference_medical']  ?? 0.0;


    return Contract(
        contractId: documentId,
        status: status,
        code: code,
        point: point,
        screenerId: screenerId,
        medicalId: medicalId,
        armCircunference: armCircunference,
        armCircumferenceMedical: armCircumferenceMedical,
    );
  }

  Map<String, dynamic> toMap() {
    return {

      'status': status,
      'code': code,
      'point': point,
      'screenerId': screenerId,
      'medicalId': medicalId,
      'arm_circumference': armCircunference,
      'arm_circumference_medical': armCircumferenceMedical
      /*
      'arm_circumference_medical': armCircumferenceMedical,

      'height': height,
      'weight': weight,
      'childName': childName,
      'childSurname': childSurname,
      'childPhoneContract': childPhoneContract,
      'childDNI': childDNI,
      'childTutor': childTutor,
      'sex': sex,
      'childAddress': childAddress,
      'medicalId': medicalId,

      'smsSent': smsSent,
      'duration': duration*/
    };
  }
}


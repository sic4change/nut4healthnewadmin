
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

typedef ContractID = String;

@immutable
class Contract extends Equatable {

  const Contract({required this.contractId, this.status, this.code, this.point,
    this.screenerId, this.medicalId, this.armCircunference, this.armCircumferenceMedical,
    this.weight, this.height, this.childName, this.childSurname, this.sex, this.childDNI,
    this.childTutor, this.childPhoneContract, this.childAddress, this.creationDate,
    this.medicalDate, this.smsSent, this.duration, this.percentage,
  });

  final ContractID contractId;
  final String? status;
  final String? code;
  final String? point;
  final String? screenerId;
  final String? medicalId;
  final double? armCircunference;
  final double? armCircumferenceMedical;
  final double? weight;
  final double? height;
  final String? childName;
  final String? childSurname;
  final String? sex;
  final String? childDNI;
  final String? childTutor;
  final String? childPhoneContract;
  final String? childAddress;
  final DateTime? creationDate;
  final DateTime? medicalDate;
  final bool? smsSent;
  final String? duration;
  final int? percentage;

  @override
  List<Object> get props => [contractId, status ?? "", code ?? "", point ?? "",
    screenerId ?? "", medicalId ?? "", armCircunference ?? 0.0, armCircumferenceMedical ?? 0.0,
    weight ?? 0.0, height ?? 0.0, childName ?? "", childSurname ?? "", sex ?? "",
    childDNI ?? "", childTutor ?? "", childPhoneContract ?? "", childAddress ?? "",
    creationDate ?? DateTime(0, 0, 0,), medicalDate ?? DateTime(0, 0, 0), smsSent ?? false,
    duration ?? "0", percentage ?? 0
  ];

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
    final weight = data['weight']  ?? 0.0;
    final height = data['height']  ?? 0.0;
    final childName = data['childName'] ?? "";
    final childSurname = data['childSurname'] ?? "";
    final sex = data['sex'] ?? "";
    final childDNI = data['childDNI'] ?? "";
    final childTutor = data['childTutor'] ?? "";
    final childPhoneContract = data['childPhoneContract'] ?? "";
    final childAddress = data['childAddress']?? "";
    final creationDate = DateTime.fromMillisecondsSinceEpoch( data['creationDateMiliseconds']);
    final medicalDate = DateTime.fromMillisecondsSinceEpoch( data['medicalDateMiliseconds']);
    final smsSent = data['smsSent'] ?? false;
    final duration = data['duration'] ?? "0";
    final percentage = data['percentage'] ?? 0;

    return Contract(
        contractId: documentId,
        status: status,
        code: code,
        point: point,
        screenerId: screenerId,
        medicalId: medicalId,
        armCircunference: armCircunference,
        armCircumferenceMedical: armCircumferenceMedical,
        weight: weight,
        height: height,
        childName: childName,
        childSurname: childSurname,
        sex: sex,
        childDNI: childDNI,
        childTutor: childTutor,
        childPhoneContract: childPhoneContract,
        childAddress: childAddress,
        creationDate: creationDate,
        medicalDate: medicalDate,
        smsSent: smsSent,
        duration: duration,
        percentage: percentage
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
      'arm_circumference_medical': armCircumferenceMedical,
      'weight': weight,
      'height': height,
      'childName': childName,
      'childSurname': childSurname,
      'sex': sex,
      'childDNI': childDNI,
      'childTutor': childTutor,
      'childPhoneContract': childPhoneContract,
      'childAddress': childAddress,
      'creationDate': creationDate,
      'medicalDate': medicalDate,
      'smsSent': smsSent,
      'duration': duration,
      'percentage': percentage
    };
  }
}

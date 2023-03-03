
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

typedef ContractID = String;

@immutable
class Contract extends Equatable {

  const Contract({required this.contractId, this.status, this.code, this.point,
    this.screenerId, this.medicalId, this.armCircunference, this.armCircumferenceMedical,
    this.weight, this.height, this.childName, this.childSurname, this.sex, this.childDNI,
    this.childTutor, this.childPhoneContract, this.childAddress, this.creationDate
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

  @override
  List<Object> get props => [contractId, status ?? "", code ?? "", point ?? "",
    screenerId ?? "", medicalId ?? "", armCircunference ?? 0.0, armCircumferenceMedical ?? 0.0,
    weight ?? 0.0, height ?? 0.0, childName ?? "", childSurname ?? "", sex ?? "",
    childDNI ?? "", childTutor ?? "", childPhoneContract ?? "", childAddress ?? "",
    creationDate ?? DateTime(0, 0, 0)
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
    final childName = data['childName']  ?? "";
    final childSurname = data['childSurname'] ?? "";
    final sex = data['sex'] ?? "";
    final childDNI = data['childDNI'] ?? "";
    final childTutor = data['childTutor'] ?? "";
    final childPhoneContract = data['childPhoneContract'] ?? "";
    final childAddress = data['childAddress'] ?? "";
    final creationDate = DateTime.fromMillisecondsSinceEpoch( data['creationDateMiliseconds']);
    print("Aqui $childName");
    print("Aqui $creationDate");

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
        creationDate: creationDate
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
      'creationDate': creationDate

      /*
      'medicalId': medicalId,
      'smsSent': smsSent,
      'duration': duration*/
    };
  }
}



import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

typedef ContractID = String;

@immutable
class Contract extends Equatable {

  const Contract({required this.contractId, this.status, this.code, this.isFEFA,
    this.point, this.screenerId, this.medicalId, this.armCircunference,
    this.armCircumferenceMedical, this.weight, this.height, this.childName,
    this.childSurname, this.sex, this.childBirthdate, this.childDNI, this.childTutor,
    this.tutorBirthdate, this.tutorDNI, this.tutorStatus, this.weeks, this.childMinor,
    this.childPhoneContract, this.childAddress, this.creationDate, this.medicalDate,
    this.smsSent, this.duration, this.percentage, this.transactionHash,
    this.transactionValidateHash,required this.chefValidation, required this.regionalValidation,
  });

  final ContractID contractId;
  final String? status;
  final String? code;
  final bool? isFEFA;
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
  final DateTime? childBirthdate;
  final String? childDNI;
  final String? childTutor;
  final DateTime? tutorBirthdate;
  final String? tutorDNI;
  final String? tutorStatus;
  final int? weeks;
  final bool? childMinor;
  final String? childPhoneContract;
  final String? childAddress;
  final DateTime? creationDate;
  final DateTime? medicalDate;
  final bool? smsSent;
  final String? duration;
  final int? percentage;
  final String? transactionHash;
  final String? transactionValidateHash;
  final bool chefValidation;
  final bool regionalValidation;

  @override
  List<Object> get props => [contractId, status ?? "", code ?? "", point ?? "",
    (code != null && code!.contains("-99")) ? true : false,
    screenerId ?? "", medicalId ?? "", armCircunference ?? 0.0, armCircumferenceMedical ?? 0.0,
    weight ?? 0.0, height ?? 0.0, childName ?? "", childSurname ?? "", sex ?? "",
    childBirthdate ?? DateTime(0, 0, 0,), childDNI ?? "", childTutor ?? "",
    tutorBirthdate ?? DateTime(0, 0, 0,), tutorDNI ?? "", tutorStatus ?? "",
    weeks ?? 0, childMinor ?? false, childPhoneContract ?? "", childAddress ?? "",
    creationDate ?? DateTime(0, 0, 0,), medicalDate ?? DateTime(0, 0, 0),
    smsSent ?? false, duration ?? "0", percentage ?? 0, transactionHash?? "",
    transactionValidateHash?? "", chefValidation, regionalValidation,
  ];

  @override
  bool get stringify => true;


  factory Contract.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for contractId: $documentId');
    }

    DateTime convertStringToDate(String dateString) {
      List<String> parts = dateString.split('/');
      String formattedDate = '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
      return DateTime.parse(formattedDate);
    }

    final status = data['status'] ?? "";
    final code = data['code'] ?? "";
    final isFEFA = (code != null && code.contains("-99")) ? true : false;
    final point = data['point'] ?? "";
    final screenerId = data['screenerId'] ?? "";
    final medicalId = data['medicalId'] ?? "";
    final armCircunference = data['arm_circumference']  ?? 0.0;
    final armCircumferenceMedical = data['arm_circumference_medical'] ?? 0.0;
    final weight = data['weight']  ?? 0.0;
    final height = data['height']  ?? 0.0;
    final childName = data['childName'] ?? "";
    final childSurname = data['childSurname'] ?? "";
    final sex = data['sex'] ?? "";
    final childBirthdate = (data['childBirthdateMiliseconds'] != null) ? convertStringToDate(data['childBirthdate']) : DateTime(0, 0, 0,);
    final childDNI = data['childDNI'] ?? "";
    final childTutor = data['childTutor'] ?? "";
    final tutorBirthdate = (data['tutorBirthdateMiliseconds'] != null) ? convertStringToDate(data['tutorBirthdate']) : DateTime(0, 0, 0,);
    final tutorDNI = data['tutorDNI'] ?? "";
    final tutorStatus = data['tutorStatus'] ?? "";
    final weeks = data['weeks'] ?? 0;
    final childMinor = data['childMinor'];
    final childPhoneContract = data['childPhoneContract'] ?? "";
    final childAddress = data['childAddress']?? "";
    final creationDate = DateTime.fromMillisecondsSinceEpoch( data['creationDateMiliseconds']);
    final medicalDate = DateTime.fromMillisecondsSinceEpoch( data['medicalDateMiliseconds']);
    final smsSent = data['smsSent'] ?? false;
    final duration = data['duration'] ?? "0";
    final percentage = data['percentage'] ?? 0;
    final transactionHash = data['transactionHash']?? "";
    final transactionValidateHash = data['transactionValidateHash']?? "";
    final chefValidation = data['chefValidation']?? false;
    final regionalValidation = data['regionalValidation']?? false;

    return Contract(
      contractId: documentId,
      status: status,
      code: code,
      isFEFA: isFEFA,
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
      childBirthdate: childBirthdate,
      childDNI: childDNI,
      childTutor: childTutor,
      tutorBirthdate: tutorBirthdate,
      tutorDNI: tutorDNI,
      tutorStatus: tutorStatus,
      weeks: weeks,
      childMinor: childMinor,
      childPhoneContract: childPhoneContract,
      childAddress: childAddress,
      creationDate: creationDate,
      medicalDate: medicalDate,
      smsSent: smsSent,
      duration: duration,
      percentage: percentage,
      transactionHash: transactionHash,
      transactionValidateHash: transactionValidateHash,
      chefValidation: chefValidation,
      regionalValidation: regionalValidation,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'code': code,
      'isFEFA': isFEFA,
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
      'childBirthdate': childBirthdate,
      'childDNI': childDNI,
      'childTutor': childTutor,
      'tutorBirthdate': tutorBirthdate,
      'tutorDNI': tutorDNI,
      'tutorStatus': tutorStatus,
      'weeks': weeks,
      'childMinor': childMinor,
      'childPhoneContract': childPhoneContract,
      'childAddress': childAddress,
      'creationDate': creationDate,
      'medicalDate': medicalDate,
      'smsSent': smsSent,
      'duration': duration,
      'percentage': percentage,
      'transactionHash': transactionHash,
      'transactionValidateHash': transactionValidateHash,
      'chefValidation': chefValidation,
      'regionalValidation': regionalValidation,
    };
  }

}

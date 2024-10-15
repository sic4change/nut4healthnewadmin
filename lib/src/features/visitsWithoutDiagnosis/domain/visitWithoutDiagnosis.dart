import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class VisitWithoutDiagnosis extends Equatable {
  const VisitWithoutDiagnosis({
    required this.id,
    required this.pointId,
    required this.childId,
    required this.fefaId,
    required this.tutorId,
    required this.createDate,
    required this.height,
    required this.weight,
    required this.imc,
    required this.armCircunference,
    required this.observations,
    required this.chefValidation,
    required this.regionalValidation,
  });

  final String id, pointId, childId, fefaId, tutorId, observations;
  final DateTime createDate;
  final double height, weight, imc, armCircunference;
  final bool chefValidation, regionalValidation;


  @override
  List<Object> get props => [id];

  @override
  bool get stringify => true;

  factory VisitWithoutDiagnosis.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for visitId: $documentId');
    }
    final pointId = data['point']?? "";
    final childId = data['childId']?? "";
    final fefaId = data['fefaId']?? "";
    final tutorId = data['tutorId']?? "";
    final Timestamp createtDateFirebase = data['createdate'] ?? Timestamp(0, 0);
    final createDate = createtDateFirebase.toDate();
    final height = data['height']?? 0.0;
    final weight = data['weight']?? 0.0;
    final imc = data['imc']?? 0.0;
    final armCircunference = data['armCircunference']?? 0.0;
    final observations = data['observations']?? "";
    final chefValidation = data['chefValidation']?? false;
    final regionalValidation = data['regionalValidation']?? false;

    return VisitWithoutDiagnosis(
      id: documentId,
      pointId: pointId,
      childId: childId,
      fefaId: fefaId,
      tutorId: tutorId,
      createDate: createDate,
      height: height,
      weight: weight,
      imc: imc,
      armCircunference: armCircunference,
      observations: observations,
      chefValidation: chefValidation,
      regionalValidation: regionalValidation,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'point': pointId,
      'childId': childId,
      'fefaId': fefaId,
      'tutorId': tutorId,
      'createDate': createDate,
      'height': height,
      'weight': weight,
      'imc': imc,
      'armCircunference': armCircunference,
      'observations': observations,
      'chefValidation': chefValidation,
      'regionalValidation': regionalValidation,
    };
  }

  static VisitWithoutDiagnosis getEmptVisitWithoutDiagnosis() {
    return VisitWithoutDiagnosis(
      id: '',
      pointId: '',
      childId: '',
      fefaId: '',
      tutorId: '',
      createDate: DateTime(1900, 1, 1), // Fecha muy antigua como valor por defecto
      height: 0.0,
      weight: 0.0,
      imc: 0.0,
      armCircunference: 0.0,
      observations: '',
      chefValidation: false,
      regionalValidation: false,
    );
  }

}

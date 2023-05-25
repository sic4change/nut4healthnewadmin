import 'dart:collection';

import 'package:adminnut4health/src/features/symptoms/domain/symptom.dart';
import 'package:adminnut4health/src/features/treatments/domain/treatment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

typedef VisitID = String;

@immutable
class Visit extends Equatable {
  const Visit({
    required this.visitId,
    required this.pointId,
    required this.childId,
    required this.tutorId,
    required this.caseId,
    required this.createDate,
    required this.height,
    required this.weight,
    required this.imc,
    required this.armCircunference,
    required this.status,
    required this.measlesVaccinated,
    required this.vitamineAVaccinated,
    required this.symptoms,
    required this.treatments,
    required this.observations,
  });

  final VisitID visitId;
  final String pointId;
  final String childId;
  final String tutorId;
  final String caseId;
  final DateTime createDate;
  final double height;
  final double weight;
  final double imc;
  final double armCircunference;
  final String status;
  final bool measlesVaccinated;
  final bool vitamineAVaccinated;
  final List<Symptom> symptoms;
  final List<Treatment> treatments;
  final String observations;

  @override
  List<Object> get props => [visitId, pointId, childId, tutorId, caseId, createDate,
    height, weight, imc, armCircunference, status, measlesVaccinated,
    vitamineAVaccinated, symptoms, treatments, observations,
  ];

  @override
  bool get stringify => true;

  factory Visit.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for visitId: $documentId');
    }
    final pointId = data['point']?? "";
    final childId = data['childId']?? "";
    final tutorId = data['tutorId']?? "";
    final caseId = data['caseId']?? "";
    final Timestamp createtDateFirebase = data['createdate'] ?? Timestamp(0, 0);
    final createDate = createtDateFirebase.toDate();
    final height = data['height']?? 0.0;
    final weight = data['weight']?? 0.0;
    final imc = data['imc']?? 0.0;
    final armCircunference = data['armCircunference']?? 0.0;
    final status = data['status']?? "";
    final measlesVaccinated = data['measlesVaccinated']?? false;
    final vitamineAVaccinated = data['vitamineAVaccinated']?? false;

    final symptomsFirebase = data['symtoms'];
    final symptoms = List<Symptom>.empty(growable: true);
    if (symptomsFirebase != null) {
      for (var symptom in symptomsFirebase) {
        symptoms.add(Symptom(
            symptomId: symptom['id']?? "",
            name: symptom['name']?? "",
            nameEn: symptom['name_en']?? "",
            nameFr: symptom['name_fr']?? ""
        ));
      }
    }

    final treatmentsFirebase = data['treatments'];
    final treatments = List<Treatment>.empty(growable: true);
    if (treatmentsFirebase != null) {
      for (var treatment in treatmentsFirebase) {
        treatments.add(Treatment(
            treatmentId: treatment['id']?? "",
            name: treatment['name']?? "",
            nameEn: treatment['name_en']?? "",
            nameFr: treatment['name_fr']?? "",
            price: treatment['price']?? 0.0)
        );
      }
    }

    final observations = data['observations']?? "";

    return Visit(
      visitId: documentId,
      pointId: pointId,
      childId: childId,
      tutorId: tutorId,
      caseId: caseId,
      createDate: createDate,
      height: height,
      weight: weight,
      imc: imc,
      armCircunference: armCircunference,
      status: status,
      measlesVaccinated: measlesVaccinated,
      vitamineAVaccinated: vitamineAVaccinated,
      symptoms: symptoms,
      treatments: treatments,
      observations: observations,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'point': pointId,
      'childId': childId,
      'tutorId': tutorId,
      'caseId': caseId,
      'createDate': createDate,
      'height': height,
      'weight': weight,
      'imc': imc,
      'armCircunference': armCircunference,
      'status': status,
      'measlesVaccinated': measlesVaccinated,
      'vitamineAVaccinated': vitamineAVaccinated,
      'symtoms': symptoms,
      'treatments': treatments,
      'observations': observations,
    };
  }
}

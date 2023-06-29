import 'dart:collection';

import 'package:adminnut4health/src/features/complications/domain/complication.dart';
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
    required this.edema,
    required this.respiratonStatus,
    required this.appetiteTest,
    required this.infection,
    required this.eyesDeficiency,
    required this.deshidratation,
    required this.vomiting,
    required this.diarrhea,
    required this.fever,
    required this.temperature,
    required this.cough,
    required this.vaccinationCard,
    required this.rubeolaVaccinated,
    required this.vitamineAVaccinated,
    required this.acidfolicAndFerroVaccinated,
    required this.complications,
    required this.observations,
    required this.admission,
    required this.amoxicilina,
    required this.otherTratments,
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
  final String edema;
  final String respiratonStatus;
  final String appetiteTest;
  final String infection;
  final String eyesDeficiency;
  final String deshidratation;
  final String vomiting;
  final String diarrhea;
  final String fever;
  final String temperature;
  final String cough;
  final String vaccinationCard;
  final String rubeolaVaccinated;
  final String vitamineAVaccinated;
  final String acidfolicAndFerroVaccinated;
  final List<Complication> complications;
  final String observations;
  final String admission;
  final String amoxicilina;
  final String otherTratments;

  @override
  List<Object> get props => [visitId, pointId, childId, tutorId, caseId, createDate,
    height, weight, imc, armCircunference, status, edema, respiratonStatus, appetiteTest,
    infection, eyesDeficiency, deshidratation, vomiting, diarrhea, fever, temperature,
    cough, vaccinationCard, rubeolaVaccinated, vitamineAVaccinated, complications,
    observations, admission, amoxicilina, otherTratments,
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
    final edema = data['edema']?? "";
    final respiratonStatus = data['respiratonStatus']?? "";
    final appetiteTest = data['appetiteTest']?? "";
    final infection = data['infection']?? "";
    final eyesDeficiency = data['eyesDeficiency']?? "";
    final deshidratation = data['deshidratation']?? "";
    final vomiting = data['vomiting']?? "";
    final diarrhea = data['diarrhea']?? "";
    final fever = data['fever']?? "";
    final temperature = data['temperature']?? "";
    final cough = data['cough']?? "";
    final vaccinationCard = data['vaccinationCard']?? "";
    final rubeolaVaccinated = data['rubeolaVaccinated']?? "";

    final vitamineAVaccinated = data['vitamineAVaccinated'];
    String vitamineAVaccinatedString = "--";
    if (vitamineAVaccinated is bool) {
      vitamineAVaccinatedString = vitamineAVaccinated? "Sí":"No";
    } else {
      vitamineAVaccinatedString = vitamineAVaccinated ?? "";
    }

    final acidfolicAndFerroVaccinated = data['acidfolicAndFerroVaccinated'];
    String acidfolicAndFerroVaccinatedString = "--";
    if (acidfolicAndFerroVaccinated is bool) {
      acidfolicAndFerroVaccinatedString = acidfolicAndFerroVaccinated? "Sí":"No";
    } else {
      acidfolicAndFerroVaccinatedString = acidfolicAndFerroVaccinated ?? "";
    }

    final amoxicilina = data['amoxicilina'];
    String amoxicilinaString = "--";
    if (amoxicilina is bool) {
      amoxicilinaString = amoxicilina? "Sí":"No";
    } else {
      amoxicilinaString = amoxicilina ?? "";
    }

    final complicationsFirebase = data['complications'];
    final complications = List<Complication>.empty(growable: true);
    if (complicationsFirebase != null) {
      for (var complication in complicationsFirebase) {
        complications.add(Complication(
            complicationId: complication['id']?? "",
            name: complication['name']?? "",
            nameEn: complication['name_en']?? "",
            nameFr: complication['name_fr']?? ""
        ));
      }
    }

    final observations = data['observations']?? "";
    final admission = data['admission']?? "";
    final otherTratments = data['otherTratments']?? "";

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
      edema: edema,
      respiratonStatus: respiratonStatus,
      appetiteTest: appetiteTest,
      infection: infection,
      eyesDeficiency: eyesDeficiency,
      deshidratation: deshidratation,
      vomiting: vomiting,
      diarrhea: diarrhea,
      fever: fever,
      temperature: temperature,
      cough: cough,
      vaccinationCard: vaccinationCard,
      rubeolaVaccinated: rubeolaVaccinated,
      vitamineAVaccinated: vitamineAVaccinatedString,
      acidfolicAndFerroVaccinated: acidfolicAndFerroVaccinatedString,
      complications: complications,
      observations: observations,
      admission: admission,
      amoxicilina: amoxicilinaString,
      otherTratments: otherTratments,
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
      'edema': edema,
      'respiratonStatus': respiratonStatus,
      'appetiteTest': appetiteTest,
      'infection': infection,
      'eyesDeficiency': eyesDeficiency,
      'deshidratation': deshidratation,
      'vomiting': vomiting,
      'diarrhea': diarrhea,
      'fever': fever,
      'temperature': temperature,
      'cough': cough,
      'vaccinationCard': vaccinationCard,
      'rubeolaVaccinated': rubeolaVaccinated,
      'vitamineAVaccinated': vitamineAVaccinated,
      'acidfolicAndFerroVaccinated': acidfolicAndFerroVaccinated,
      'complications': complications,
      'observations': observations,
      'admission': admission,
      'amoxicilina': amoxicilina,
      'otherTratments': otherTratments,
    };
  }
}

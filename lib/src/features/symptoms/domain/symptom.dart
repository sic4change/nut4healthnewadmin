import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

typedef SymptomID = String;

@immutable
class Symptom extends Equatable {
  const Symptom({
    required this.symptomId,
    required this.name,
    required this.nameEn,
    required this.nameFr,
    //required this.updatedby,
    //required this.lastupdate,
  });

  final SymptomID symptomId;
  final String name;
  final String nameEn;
  final String nameFr;
  //final String? updatedby;
  //final DateTime? lastupdate;

  @override
  List<Object> get props => [symptomId, name, nameEn, nameFr];

  @override
  bool get stringify => true;

  factory Symptom.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for symptomId: $documentId');
    }
    final name = data['name'] as String;
    final nameEn = data['name_en'] as String;
    final nameFr = data['name_fr'] as String;
    //final updatedby = data['updatedby'] as String?;
    //final Timestamp? lastupdateFirebase = data['lastupdate'];
    //final lastupdate = lastupdateFirebase?.toDate();

    return Symptom(
      symptomId: documentId,
      name: name,
      nameEn: nameEn,
      nameFr: nameFr,
      //updatedby: updatedby,
      //lastupdate: lastupdate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'nameEn': nameEn,
      'nameFr': nameFr,
    };
  }
}

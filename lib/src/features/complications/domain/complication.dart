import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

typedef ComplicationID = String;

@immutable
class Complication extends Equatable {
  const Complication({
    required this.complicationId,
    required this.name,
    required this.nameEn,
    required this.nameFr,
  });

  final ComplicationID complicationId;
  final String name;
  final String nameEn;
  final String nameFr;

  @override
  List<Object> get props => [complicationId, name, nameEn, nameFr];

  @override
  bool get stringify => true;

  factory Complication.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for complicationId: $documentId');
    }
    final name = data['name'] as String;
    final nameEn = data['name_en'] as String;
    final nameFr = data['name_fr'] as String;

    return Complication(
      complicationId: documentId,
      name: name,
      nameEn: nameEn,
      nameFr: nameFr,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'name_en': nameEn,
      'name_fr': nameFr,
    };
  }
}

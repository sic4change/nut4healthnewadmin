import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

typedef TreatmentID = String;

@immutable
class Treatment extends Equatable {
  const Treatment({
    required this.treatmentId,
    required this.name,
    required this.nameEn,
    required this.nameFr,
    required this.price,
  });

  final TreatmentID treatmentId;
  final String name;
  final String nameEn;
  final String nameFr;
  final double price;

  @override
  List<Object> get props => [treatmentId, name, nameEn, nameFr, price];

  @override
  bool get stringify => true;

  factory Treatment.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for treatmentId: $documentId');
    }
    final name = data['name'] as String;
    final nameEn = data['name_en'] as String;
    final nameFr = data['name_fr'] as String;
    final price = data['price'] as double;

    return Treatment(
      treatmentId: documentId,
      name: name,
      nameEn: nameEn,
      nameFr: nameFr,
      price: price,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'nameEn': nameEn,
      'nameFr': nameFr,
      'price': price,
    };
  }
}

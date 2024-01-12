
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class ChildInform extends Equatable {

  const ChildInform({
    required this.place,
    required this.ageGroup,
    required this.records,
    required this.male,
    required this.malemas,
    required this.malemam,
    required this.malepn,
    required this.female,
    required this.femalemas,
    required this.femalemam,
    required this.femalepn,
  });

  final String place;
  final String ageGroup;
  final int records;
  final int male;
  final int malemas;
  final int malemam;
  final int malepn;
  final int female;
  final int femalemas;
  final int femalemam;
  final int femalepn;

  @override
  List<Object> get props => [
    place ?? "",
    ageGroup ?? "",
    records ?? 0,
    male ?? 0,
    malemas ?? 0,
    malemam ?? 0,
    malepn ?? 0,
    female ?? 0,
    femalemas ?? 0,
    femalemam ?? 0,
    femalepn ?? 0,
  ];

  @override
  bool get stringify => true;

  factory ChildInform.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for contractId: $documentId');
    }

    final place = data['place'] ?? "";
    final ageGroup = data['ageGroup'] ?? "";
    final records = data['records'] ?? 0;
    final male = data['male'] ?? 0;
    final malemas = data['malemas'] ?? 0;
    final malemam = data['malemam'] ?? 0;
    final malepn = data['malepn'] ?? 0;
    final female = data['female'] ?? 0;
    final femalemas = data['femalemas'] ?? 0;
    final femalemam = data['femalemam'] ?? 0;
    final femalepn = data['femalepn'] ?? 0;

    return ChildInform(
      place: place,
      ageGroup: ageGroup,
      records: records,
      male: male,
      malemas: malemas,
      malemam: malemam,
      malepn: malepn,
      female: female,
      femalemas: femalemas,
      femalemam: femalemam,
      femalepn: femalepn,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'place': place,
      'ageGroup': ageGroup,
      'records': records,
      'male': male,
      'malemas' : malemas,
      'malemam' : malemam,
      'malepn': malepn,
      'female': female,
      'femalemas' : femalemas,
      'femalemam' : femalemam,
      'femalepn': femalepn,
    };
  }

}


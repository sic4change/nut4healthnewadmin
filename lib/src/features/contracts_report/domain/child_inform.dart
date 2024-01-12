
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class ChildInform extends Equatable {

  const ChildInform({
    required this.place,
    required this.ageGroup,
    required this.records,
    required this.male,
    required this.female,
  });

  final String place;
  final String ageGroup;
  final int records;
  final int male;
  final int female;

  @override
  List<Object> get props => [
    place ?? "",
    ageGroup ?? "",
    records ?? 0,
    male ?? 0,
    female ?? 0,
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
    final female = data['female'] ?? 0;

    return ChildInform(
      place: place,
      ageGroup: ageGroup,
      records: records,
      male: male,
      female: female,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'place': place,
      'ageGroup': ageGroup,
      'records': records,
      'male': male,
      'female': female,
    };
  }

}


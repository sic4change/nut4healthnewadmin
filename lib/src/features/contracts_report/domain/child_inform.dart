
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class ChildInform extends Equatable {

  const ChildInform({
    required this.place,
    required this.ageGroup,
    required this.records,
  });

  final String place;
  final String ageGroup;
  final int records;

  @override
  List<Object> get props => [
    place ?? "",
    ageGroup ?? "",
    records ?? 0,
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

    return ChildInform(
      place: place,
      ageGroup: ageGroup,
      records: records,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'place': place,
      'ageGroup': ageGroup,
      'records': records,
    };
  }

}


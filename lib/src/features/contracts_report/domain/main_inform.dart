
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class MainInform extends Equatable {

  const MainInform({
    required this.place,
    required this.records,
    required this.childs,
    required this.fefas,
    required this.childsMAS,
    required this.childsMAM,
    required this.childsPN,
  });

  final String place;
  final int records;
  final int childs;
  final int fefas;
  final int childsMAS;
  final int childsMAM;
  final int childsPN;

  @override
  List<Object> get props => [
    place ?? "",
    records ?? 0,
    childs ?? 0,
    fefas ?? 0,
    childsMAS ?? 0,
    childsMAM ?? 0,
    childsPN ?? 0,
  ];

  @override
  bool get stringify => true;

  factory MainInform.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for contractId: $documentId');
    }

    final place = data['place'] ?? "";
    final records = data['records'] ?? 0;
    final childs = data['childs'] ?? 0;
    final fefas = data['fefas'] ?? 0;
    final childsMAS = data['childsMAS'] ?? 0;
    final childsMAM = data['childsMAM'] ?? 0;
    final childsPN = data['childsPN'] ?? 0;

    return MainInform(
      place: place,
      records: records,
      childs: childs,
      fefas: fefas,
      childsMAS: childsMAS,
      childsMAM: childsMAM,
      childsPN: childsPN,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'place': place,
      'records': records,
      'childs': childs,
      'fefas': fefas,
      'childsMAS': childsMAS,
      'childsMAM': childsMAM,
      'childsPN': childsPN,
    };
  }

}


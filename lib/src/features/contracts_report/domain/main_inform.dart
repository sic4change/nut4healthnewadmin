
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
    required this.fefasfe,
    required this.fefasfa,
    required this.fefasfea,
  });

  final String place;
  final int records;
  final int childs;
  final int fefas;
  final int childsMAS;
  final int childsMAM;
  final int childsPN;
  final int fefasfe;
  final int fefasfa;
  final int fefasfea;

  @override
  List<Object> get props => [
    place ?? "",
    records ?? 0,
    childs ?? 0,
    fefas ?? 0,
    childsMAS ?? 0,
    childsMAM ?? 0,
    childsPN ?? 0,
    fefasfe ?? 0,
    fefasfa ?? 0,
    fefasfea ?? 0,
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
    final fefasfe = data['fefasfe'] ?? 0;
    final fefasfa = data['fefasfa'] ?? 0;
    final fefasfea = data['fefasfea'] ?? 0;

    return MainInform(
      place: place,
      records: records,
      childs: childs,
      fefas: fefas,
      childsMAS: childsMAS,
      childsMAM: childsMAM,
      childsPN: childsPN,
      fefasfe: fefasfe,
      fefasfa: fefasfa,
      fefasfea: fefasfea,
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
      'fefasfe': fefasfe,
      'fefasfa': fefasfa,
      'fefasfea': fefasfea,
    };
  }

}


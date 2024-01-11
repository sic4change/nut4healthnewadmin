
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
    required this.fefasfemas,
    required this.fefasfemam,
    required this.fefasfepn,
    required this.fefasfa,
    required this.fefasfamas,
    required this.fefasfamam,
    required this.fefasfapn,
    required this.fefasfea,
    required this.fefasfeamas,
    required this.fefasfeamam,
    required this.fefasfeapn,
  });

  final String place;
  final int records;
  final int childs;
  final int fefas;
  final int childsMAS;
  final int childsMAM;
  final int childsPN;
  final int fefasfe;
  final int fefasfemas;
  final int fefasfemam;
  final int fefasfepn;
  final int fefasfa;
  final int fefasfamas;
  final int fefasfamam;
  final int fefasfapn;
  final int fefasfea;
  final int fefasfeamas;
  final int fefasfeamam;
  final int fefasfeapn;

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
    fefasfemas ?? 0,
    fefasfemam ?? 0,
    fefasfepn ?? 0,
    fefasfa ?? 0,
    fefasfamas ?? 0,
    fefasfamam ?? 0,
    fefasfapn ?? 0,
    fefasfea ?? 0,
    fefasfeamas ?? 0,
    fefasfeamam ?? 0,
    fefasfeapn ?? 0,

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
    final fefasfemas = data['fefasfemas'] ?? 0;
    final fefasfemam = data['fefasfemam'] ?? 0;
    final fefasfepn = data['fefasfepn'] ?? 0;
    final fefasfa = data['fefasfa'] ?? 0;
    final fefasfamas = data['fefasfamas'] ?? 0;
    final fefasfamam = data['fefasfamam'] ?? 0;
    final fefasfapn = data['fefasfapn'] ?? 0;
    final fefasfea = data['fefasfea'] ?? 0;
    final fefasfeamas = data['fefasfeamas'] ?? 0;
    final fefasfeamam = data['fefasfeamam'] ?? 0;
    final fefasfeapn = data['fefasfeapn'] ?? 0;

    return MainInform(
      place: place,
      records: records,
      childs: childs,
      fefas: fefas,
      childsMAS: childsMAS,
      childsMAM: childsMAM,
      childsPN: childsPN,
      fefasfe: fefasfe,
      fefasfemas: fefasfemas,
      fefasfemam: fefasfemam,
      fefasfepn: fefasfepn,
      fefasfa: fefasfa,
      fefasfamas: fefasfamas,
      fefasfamam: fefasfamam,
      fefasfapn: fefasfapn,
      fefasfea: fefasfea,
      fefasfeamas: fefasfeamas,
      fefasfeamam: fefasfeamam,
      fefasfeapn: fefasfeapn,
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
      'fefasfemas': fefasfemas,
      'fefasfemam': fefasfemam,
      'fefasfepn': fefasfepn,
      'fefasfa': fefasfa,
      'fefasfamas': fefasfamas,
      'fefasfamam': fefasfamam,
      'fefasfapn': fefasfapn,
      'fefasfea': fefasfea,
      'fefasfeamas': fefasfeamas,
      'fefasfeamam': fefasfeamam,
      'fefasfeapn': fefasfeapn,
    };
  }

}


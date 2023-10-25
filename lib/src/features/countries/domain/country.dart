
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

typedef CountryID = String;

@immutable
class Country extends Equatable {

  const Country({required this.countryId, required this.name,
    required this.code, required this.active, required this.needValidation,
    required this.cases, required this.casesnormopeso, required this.casesmoderada,
    required this.casessevera});

  final CountryID countryId;
  final String name;
  final String code;
  final bool active;
  final bool needValidation;
  final int cases;
  final int casesnormopeso;
  final int casesmoderada;
  final int casessevera;


  @override
  List<Object> get props => [countryId, name, code, active, needValidation];

  @override
  bool get stringify => true;


  factory Country.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for countryId: $documentId');
    }
    final name = data['name'] as String;
    final code = data['code'] as String;
    final active = data['active'] as bool;
    final needValidation = data['needValidation']?? false;
    final cases = data['cases'] as int;
    final casesnormopeso = data['casesnormopeso'] as int;
    final casesmoderada = data['casesmoderada'] as int;
    final casessevera = data['casessevera'] as int;

    return Country(
        countryId: documentId,
        name: name,
        code: code,
        active: active,
        needValidation: needValidation,
        cases: cases,
        casesnormopeso: casesnormopeso,
        casesmoderada: casesmoderada,
        casessevera: casessevera,);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'active': active,
      'needValidation': needValidation,
      'cases': cases,
      'casesnormopeso': casesnormopeso,
      'casesmoderada': casesmoderada,
      'casessevera': casessevera
    };
  }
}


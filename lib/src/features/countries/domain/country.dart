
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

typedef CountryID = String;

@immutable
class Country extends Equatable {

  const Country({required this.countryId, required this.name,
    required this.code, required this.active});

  final CountryID countryId;
  final String name;
  final String code;
  final bool active;

  @override
  List<Object> get props => [countryId, name, code, active];

  @override
  bool get stringify => true;


  factory Country.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for countryId: $documentId');
    }
    final name = data['name'] as String;
    final code = data['code'] as String;
    final active = data['active'] as bool;
    return Country(
        countryId: documentId,
        name: name,
        code: code,
        active: active);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'active': active,
    };
  }
}


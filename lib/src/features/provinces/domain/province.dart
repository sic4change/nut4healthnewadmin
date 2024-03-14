
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

typedef ProvinceID = String;

@immutable
class Province extends Equatable {

  const Province({required this.provinceId, required this.name,
    required this.country, required this.regionId, required this.locationId, required this.active});

  final ProvinceID provinceId;
  final String name;
  final String country;
  final String regionId;
  final String locationId;
  final bool active;

  @override
  List<Object> get props => [provinceId, name, country, regionId, locationId, active];

  @override
  bool get stringify => true;


  factory Province.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for provinceId: $documentId');
    }
    final name = data['name'] as String;
    final country = data['country'] as String;
    final regionId = data['regionId']?? "";
    final locationId = data['locationId']?? "";
    final active = data['active'] as bool;
    return Province(
        provinceId: documentId,
        name: name,
        country: country,
        regionId: regionId,
        locationId: locationId,
        active: active);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'country': country,
      'regionId': regionId,
      'locationId': locationId,
      'active': active,
    };
  }
}


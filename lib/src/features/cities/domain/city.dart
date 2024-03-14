
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

typedef CityID = String;

@immutable
class City extends Equatable {

  const City({required this.cityId, required this.name,
    required this.locationId, required this.province, required this.country,
    required this.regionId, required this.active});

  final CityID cityId;
  final String name;
  final String country;
  final String regionId;
  final String locationId;
  final String province;
  final bool active;

  @override
  List<Object> get props => [cityId, name, country, regionId, locationId, province, active];

  @override
  bool get stringify => true;


  factory City.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for cityId: $documentId');
    }
    final name = data['name'] as String;
    final country = data['country'] as String;
    final regionId = data['regionId']?? "";
    final locationId = data['locationId']?? "";
    final province = data['province'] as String;
    final active = data['active'] as bool;
    return City(
        cityId: documentId,
        name: name,
        country: country,
        regionId: regionId,
        locationId: locationId,
        province: province,
        active: active);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'country': country,
      'regionId': regionId,
      'locationId': locationId,
      'province': province,
      'active': active,
    };
  }
}


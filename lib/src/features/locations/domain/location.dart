
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

typedef LocationID = String;

@immutable
class Location extends Equatable {

  const Location({required this.locationId, required this.name,
    required this.country, required this.regionId, required this.active});

  const Location.empty():
        locationId = '',
        regionId = '',
        name = '',
        country = '',
        active = false;

  final LocationID locationId;
  final String name;
  final String country;
  final String regionId;
  final bool active;

  @override
  List<Object> get props => [locationId, name, country, regionId, active];

  @override
  bool get stringify => true;


  factory Location.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for cityId: $documentId');
    }
    final name = data['name'] as String;
    final country = data['country'] as String;
    final regionId = data['regionId']?? "";
    final active = data['active'] as bool;
    return Location(
        locationId: documentId,
        name: name,
        country: country,
        regionId: regionId,
        active: active);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'country': country,
      'regionId': regionId,
      'active': active,
    };
  }
}


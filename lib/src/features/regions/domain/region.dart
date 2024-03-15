
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

typedef RegionID = String;

@immutable
class Region extends Equatable {

  const Region({required this.regionId, required this.name,
    required this.countryId, required this.active});

  const Region.empty():
        regionId = '',
        name = '',
        countryId = '',
        active = false;

  final RegionID regionId;
  final String name;
  final String countryId;
  final bool active;

  @override
  List<Object> get props => [regionId, name, countryId, active];

  @override
  bool get stringify => true;


  factory Region.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for regionId: $documentId');
    }
    final name = data['name'] as String;
    final countryId = data['countryId'] as String;
    final active = data['active'] as bool;
    return Region(
        regionId: documentId,
        name: name,
        countryId: countryId,
        active: active);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'countryId': countryId,
      'active': active,
    };
  }
}


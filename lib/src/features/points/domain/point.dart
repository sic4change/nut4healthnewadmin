
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';


typedef PointID = String;

@immutable
class Point extends Equatable {

  const Point({required this.pointId, required this.name , required this.fullName,
    required this.country, required this.province,
    required this.phoneCode, required this.active, required this.latitude,
    required this.longitude, required this.cases, required this.casesnormopeso,
    required this.casesmoderada, required this.casessevera});

  final PointID pointId;
  final String name;
  final String fullName;
  final String country;
  final String province;
  final String phoneCode;
  final bool active;
  final double latitude;
  final double longitude;
  final int cases;
  final int casesnormopeso;
  final int casesmoderada;
  final int casessevera;

  @override
  List<Object> get props => [pointId, name, fullName, country, province,
    phoneCode, active, latitude, longitude, cases, casesnormopeso, casesmoderada, casessevera];

  @override
  bool get stringify => true;


  factory Point.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for userId: $documentId');
    }
    final name = data['name'];
    final fullName = data['fullName'];
    final country = data['country'];
    final province = data['province'];
    final phoneCode = data['phoneCode'];
    final active = data['active'] as bool;
    final latitude = data['latitude'] as double;
    final longitude = data['longitude'] as double;
    final cases = data['cases'] as int;
    final casesnormopeso = data['casesnormopeso'] as int;
    final casesmoderada = data['casesmoderada'] as int;
    final casessevera = data['casessevera'] as int;

    return Point(
        pointId: documentId,
        name: name,
        fullName: fullName,
        country: country,
        province: province,
        phoneCode: phoneCode,
        active: active,
        latitude: latitude,
        longitude: longitude,
        cases: cases,
        casesnormopeso: casesnormopeso,
        casesmoderada: casesmoderada,
        casessevera: casessevera);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'fullName': fullName,
      'country': country,
      'province': province,
      'phoneCode': phoneCode,
      'active': active,
      'latitude': latitude,
      'longitude': longitude,
      'cases': cases,
      'casesnormopeso': casesnormopeso,
      'casesmoderada': casesmoderada,
      'casessevera': casessevera,
    };
  }
}



import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

typedef PointID = String;

@immutable
class Point extends Equatable {

  const Point({required this.pointId, required this.name, required this.fullName,
    required this.pointName, required this.pointCode, required this.type,
    required this.country, required this.regionId, required this.location, required this.province,
    required this.phoneCode, required this.phoneLength, required this.active, required this.latitude,
    required this.longitude, required this.language, required this.cases, required this.casesnormopeso,
    required this.casesmoderada, required this.casessevera, required this.transactionHash});

  final PointID pointId;
  final String name;
  final String fullName;
  final String pointName;
  final String pointCode;
  final String type;
  final String country;
  final String regionId;
  final String location;
  final String province;
  final String phoneCode;
  final int phoneLength;
  final bool active;
  final double latitude;
  final double longitude;
  final String language;
  final int cases;
  final int casesnormopeso;
  final int casesmoderada;
  final int casessevera;
  final String transactionHash;

  @override
  List<Object> get props => [pointId, name, fullName, pointName, pointCode, type,
    country, regionId, location, province, phoneCode, phoneLength, active, latitude, longitude,
    language, cases, casesnormopeso, casesmoderada,
    casessevera, transactionHash];

  @override
  bool get stringify => true;


  factory Point.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for userId: $documentId');
    }
    final name = data['name'];
    final fullName = data['fullName'];
    final pointName = data['pointName'];
    final pointCode = data['pointCode'];
    final type = data['type']?? "";
    final country = data['country'];
    final regionId = data['regionId']?? "";
    final location = data['location']?? "";
    final province = data['province']?? "";
    final phoneCode = data['phoneCode'];
    final phoneLength = data['phoneLength']??0;
    final active = data['active'] as bool;
    final latitude = data['latitude'] as double;
    final longitude = data['longitude'] as double;
    final language = data['language']??"";
    final cases = data['cases'] as int;
    final casesnormopeso = data['casesnormopeso'] as int;
    final casesmoderada = data['casesmoderada'] as int;
    final casessevera = data['casessevera'] as int;
    final transactionHash = data['transactionHash']??"";

    return Point(
        pointId: documentId,
        name: name,
        fullName: fullName,
        pointName: pointName,
        pointCode: pointCode,
        type: type,
        country: country,
        regionId: regionId,
        location: location,
        province: province,
        phoneCode: phoneCode,
        phoneLength: phoneLength,
        active: active,
        latitude: latitude,
        longitude: longitude,
        language: language,
        cases: cases,
        casesnormopeso: casesnormopeso,
        casesmoderada: casesmoderada,
        casessevera: casessevera,
        transactionHash: transactionHash,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'fullName': fullName,
      'pointName': pointName,
      'pointCode': pointCode,
      'type': type,
      'country': country,
      'regionId': regionId,
      'location': location,
      'province': province,
      'phoneCode': phoneCode,
      'phoneLength': phoneLength,
      'active': active,
      'latitude': latitude,
      'longitude': longitude,
      'language': language,
      'cases': cases,
      'casesnormopeso': casesnormopeso,
      'casesmoderada': casesmoderada,
      'casessevera': casessevera,
      'transactionHash': transactionHash,
    };
  }
}


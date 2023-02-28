
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';


typedef PointID = String;

@immutable
class Point extends Equatable {

  const Point({required this.pointId, required this.name , required this.fullName,
    required this.country, required this.province,
    required this.phoneCode, required this.active});

  final PointID pointId;
  final String name;
  final String fullName;
  final String country;
  final String province;
  final String phoneCode;
  final bool active;

  @override
  List<Object> get props => [pointId, name, fullName, country, province,
    phoneCode, active];

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

    return Point(
        pointId: documentId,
        name: name,
        fullName: fullName,
        country: country,
        province: province,
        phoneCode: phoneCode,
        active: active);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'fullName': fullName,
      'country': country,
      'province': province,
      'phoneCode': phoneCode,
      'active': active,
    };
  }
}


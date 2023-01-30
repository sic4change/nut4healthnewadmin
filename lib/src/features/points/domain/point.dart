
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';


typedef PointID = String;

@immutable
class Point extends Equatable {

  const Point({required this.pointId, required this.name , required this.fullName,
    required this.country, required this.province,
    required this.phoneCode});

  final PointID pointId;
  final String name;
  final String fullName;
  final String country;
  final String province;
  final String phoneCode;

  @override
  List<Object> get props => [pointId, name, fullName, country, province,
    phoneCode];

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

    return Point(
        pointId: documentId,
        name: name,
        fullName: fullName,
        country: country,
        province: province,
        phoneCode: phoneCode);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'fullName': fullName,
      'country': country,
      'province': province,
      'phoneCode': phoneCode,
    };
  }
}


import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';


@immutable
class ContractStadistic extends Equatable {

  const ContractStadistic({this.point, this.creationDate, this.value});

  final String? point;
  final DateTime? creationDate;
  final int? value;

  @override
  List<Object> get props => [point ?? "", creationDate ?? DateTime(0, 0, 0,), value ?? 0];

  @override
  bool get stringify => true;


  factory ContractStadistic.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for contractId: $documentId');
    }

    final point = data['point'] ?? "";
    final creationDate = DateTime.fromMillisecondsSinceEpoch( data['creationDateMiliseconds']);
    final value = data['value'] ?? 0;

    return ContractStadistic(
        point: point,
        creationDate: creationDate,
        value: value
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'point': point,
      'creationDate': creationDate,
      'value': value
    };
  }
}


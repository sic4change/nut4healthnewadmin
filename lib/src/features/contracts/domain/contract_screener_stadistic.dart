
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';


@immutable
class ContractScreenerStadistic extends Equatable {

  const ContractScreenerStadistic({this.user, this.creationDate, this.value});

  final String? user;
  final DateTime? creationDate;
  final int? value;

  @override
  List<Object> get props => [user ?? "", creationDate ?? DateTime(0, 0, 0,), value ?? 0];

  @override
  bool get stringify => true;


  factory ContractScreenerStadistic.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for contractId: $documentId');
    }

    final user = data['user'] ?? "";
    final creationDate = DateTime.fromMillisecondsSinceEpoch( data['creationDateMiliseconds']);
    final value = data['value'] ?? 0;

    return ContractScreenerStadistic(
        user: user,
        creationDate: creationDate,
        value: value
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user': user,
      'creationDate': creationDate,
      'value': value
    };
  }
}


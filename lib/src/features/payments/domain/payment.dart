

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

typedef PaymentID = String;

@immutable
class Payment extends Equatable {

  const Payment(
      {required this.paymentId,
        this.status,
        //this.quantity,
        this.type,
        //this.creationDate,
        this.screenerId,
        //this.contractId
  });

  final PaymentID paymentId;
  final String? status;
  //final double? quantity;
  final String? type;
  //final DateTime? creationDate;
  final String? screenerId;
  //final String? contractId;

  @override
  List<Object> get props => [
    paymentId,
    status ?? "",
    //quantity ?? 0.0,
    type ?? "",
    //creationDate ?? DateTime(0, 0, 0,),
    screenerId ?? "",
    //contractId ?? ""
  ];

  @override
  bool get stringify => true;


  factory Payment.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for paymentID: $documentId');
    }

    final status = data['status'] ?? "";
    //final quantity = data['quantity'] as double? ?? 0.0;
    final type = data['type'] ?? "";
    //final creationDate = DateTime.fromMillisecondsSinceEpoch( data['creationDateMiliseconds'] ?? 0);
    final screenerId = data['screenerId'] ?? "";
    //final contractId = data['contractId'] ?? "";

    return Payment(
        paymentId: documentId,
        status: status,
        //quantity: quantity,
        type: type,
        //creationDate: creationDate,
        screenerId: screenerId,
        //contractId: contractId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'type': type,
      //'contractId': contractId,
      'screenerId': screenerId,
    };
  }
}


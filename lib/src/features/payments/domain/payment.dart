

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

typedef PaymentID = String;

@immutable
class Payment extends Equatable {

  const Payment(
      {required this.paymentId,
        this.status,
        this.quantity,
        this.type,
        this.creationDate,
        this.screenerId,
  });

  final PaymentID paymentId;
  final String? status;
  final double? quantity;
  final String? type;
  final DateTime? creationDate;
  final String? screenerId;

  @override
  List<Object> get props => [
    paymentId,
    status ?? "",
    quantity ?? 0.0,
    type ?? "",
    creationDate ?? DateTime(0, 0, 0,),
    screenerId ?? ""
  ];

  @override
  bool get stringify => true;


  factory Payment.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for paymentID: $documentId');
    }

    final status = data['status'] ?? "";

    var quantity = 0.0;
    try {
      quantity = data['quantity'] as double? ?? 0.0;
    } catch (e) {
      print("error quantity $e");
      quantity = 0.0;
    }

    final type = data['type'] ?? "";
    var creationDateMiliseconds = 0;
    try {
      creationDateMiliseconds = data['creationDateMiliseconds'] as int ?? 0;
    } catch (e) {
      print("error creationDateMiliseconds $e");
      creationDateMiliseconds = 0;
    }
    final creationDate = DateTime.fromMillisecondsSinceEpoch(creationDateMiliseconds);

    final screenerId = data['screenerId'] ?? "";

    return Payment(
        paymentId: documentId,
        status: status,
        quantity: quantity,
        type: type,
        creationDate: creationDate,
        screenerId: screenerId
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'type': type,
      'screenerId': screenerId,
      'creationDate': creationDate,
    };
  }
}


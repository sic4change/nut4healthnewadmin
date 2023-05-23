
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';


typedef ConfigurationID = String;

@immutable
class Configuration extends Equatable {

  const Configuration({required this.id, required this.name , required this.money,
    required this.payByConfirmation, required this.payByDiagnosis,
    required this.pointByConfirmation, required this.pointsByDiagnosis,
    required this.monthlyPayment, required this.blockChainConfiguration,
    required this.hash,
  });

  final ConfigurationID id;
  final String name;
  final String money;
  final int payByConfirmation;
  final int payByDiagnosis;
  final int pointByConfirmation;
  final int pointsByDiagnosis;
  final int monthlyPayment;
  final int blockChainConfiguration;
  final String hash;

  @override
  List<Object> get props => [id, name, money, payByConfirmation,
    pointByConfirmation, pointsByDiagnosis, monthlyPayment,
    blockChainConfiguration, hash];

  @override
  bool get stringify => true;


  factory Configuration.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for userId: $documentId');
    }
    final name = data['name'];
    final money = data['money'];
    final payByConfirmation = data['payByConfirmation'];
    final payByDiagnosis = data['payByDiagnosis'];
    final pointByConfirmation = data['pointByConfirmation'];
    final pointsByDiagnosis = data['pointsByDiagnosis'];
    final monthlyPayment = data['monthlyPayment'];
    final blockChainConfiguration = data['blockChainConfiguration'] ??0;
    final hash = data['hash']?? "";

    return Configuration(
        id: documentId,
        name: name,
         money: money,
        payByConfirmation: payByConfirmation,
        payByDiagnosis: payByDiagnosis,
        pointByConfirmation: pointByConfirmation,
        pointsByDiagnosis: pointsByDiagnosis,
        monthlyPayment: monthlyPayment,
        blockChainConfiguration: blockChainConfiguration,
        hash: hash,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'money': money,
      'payByConfirmation': payByConfirmation,
      'payByDiagnosis': payByDiagnosis,
      'pointByConfirmation': pointByConfirmation,
      'pointsByDiagnosis': pointsByDiagnosis,
      'monthlyPayment' : monthlyPayment,
      'blockChainConfiguration': blockChainConfiguration,
      'hash': hash,
    };
  }
}


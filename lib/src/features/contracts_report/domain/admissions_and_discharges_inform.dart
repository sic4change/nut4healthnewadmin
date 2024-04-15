
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class AdmissionsAndDischargesInform extends Equatable {

  AdmissionsAndDischargesInform({
    required this.category,
    required this.patientsAtBeginning,
    required this.newAdmissions,
    required this.reAdmissions,
    required this.referred,
    required this.transfered,
  });

  final String category;
  int patientsAtBeginning;
  int newAdmissions;
  int reAdmissions;
  int referred;
  int transfered;
  int totalAdmissions() => newAdmissions + reAdmissions + referred + transfered;
  int totalAttended() => totalAdmissions() + patientsAtBeginning;

  @override
  List<Object> get props => [
    category,
    patientsAtBeginning,
    newAdmissions,
    reAdmissions,
    referred,
    transfered,
  ];

  @override
  bool get stringify => true;

}


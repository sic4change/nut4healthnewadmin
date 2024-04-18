
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class AdmissionsAndDischargesInform extends Equatable {

  AdmissionsAndDischargesInform({
    required this.category,
    required this.patientsAtBeginning,
    required this.newAdmissions,
    required this.reAdmissions,
    required this.referredIn,
    required this.transferedIn,
    required this.recovered,
    required this.unresponsive,
    required this.abandonment,
    required this.referredOut,
    required this.transferedOut,
  });

  final String category;
  int patientsAtBeginning;
  int newAdmissions;
  int reAdmissions;
  int referredIn;
  int transferedIn;
  int totalAdmissions() => newAdmissions + reAdmissions + referredIn + transferedIn;
  int totalAttended() => totalAdmissions() + patientsAtBeginning;
  int recovered;
  int unresponsive;
  int abandonment;
  int referredOut;
  int transferedOut;
  int totalDischarges() => recovered + unresponsive + abandonment + referredOut + transferedOut;
  int totalAtTheEnd() => totalAttended() - totalDischarges();

  @override
  List<Object> get props => [
    category,
    patientsAtBeginning,
    newAdmissions,
    reAdmissions,
    referredIn,
    transferedIn,
    recovered,
    unresponsive,
    abandonment,
    referredOut,
    transferedOut,
  ];

  @override
  bool get stringify => true;

}


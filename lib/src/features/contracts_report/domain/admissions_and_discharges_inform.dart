
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class AdmissionsAndDischargesInform extends Equatable {

  AdmissionsAndDischargesInform({
    required this.category,
    required this.patientsAtBeginning,
    required this.newAdmissions,
    required this.reAdmissions,
    required this.relapses,
    required this.referredIn,
    required this.transferedIn,
    required this.recovered,
    required this.unresponsive,
    required this.deaths,
    required this.abandonment,
    required this.referredOut,
    required this.transferedOut,
  });

  final String category;
  int patientsAtBeginning;
  int newAdmissions;
  int reAdmissions;
  int relapses;
  int referredIn;
  int transferedIn;
  int totalAdmissions() => newAdmissions + reAdmissions + relapses + referredIn + transferedIn;
  int totalAttended() => totalAdmissions() + patientsAtBeginning;
  int recovered;
  int unresponsive;
  int deaths;
  int abandonment;
  int referredOut;
  int transferedOut;
  int totalDischarges() => recovered + unresponsive + deaths + abandonment + referredOut + transferedOut;
  int totalAtTheEnd() => totalAttended() - totalDischarges();

  @override
  List<Object> get props => [
    category,
    patientsAtBeginning,
    newAdmissions,
    reAdmissions,
    relapses,
    referredIn,
    transferedIn,
    recovered,
    unresponsive,
    deaths,
    abandonment,
    referredOut,
    transferedOut,
  ];

  @override
  bool get stringify => true;

}


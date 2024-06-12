
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class AdmissionsAndDischargesByPointInform extends Equatable {

  AdmissionsAndDischargesByPointInform({
    required this.country,
    required this.region,
    required this.location,
    required this.province,
    required this.point,
    required this.patientsAtBeginningBoy,
    required this.patientsAtBeginningGirl,
    required this.patientsAtBeginningFEFA,
    required this.newAdmissionsBoy,
    required this.newAdmissionsGirl,
    required this.newAdmissionsFEFA,
    required this.reAdmissionsBoy,
    required this.reAdmissionsGirl,
    required this.reAdmissionsFEFA,
    required this.relapsesBoy,
    required this.relapsesGirl,
    required this.relapsesFEFA,
    required this.referredInBoy,
    required this.referredInGirl,
    required this.referredInFEFA,
    required this.transferedInBoy,
    required this.transferedInGirl,
    required this.transferedInFEFA,
    required this.recoveredBoy,
    required this.recoveredGirl,
    required this.recoveredFEFA,
    required this.unresponsiveBoy,
    required this.unresponsiveGirl,
    required this.unresponsiveFEFA,
    required this.deathsBoy,
    required this.deathsGirl,
    required this.deathsFEFA,
    required this.abandonmentBoy,
    required this.abandonmentGirl,
    required this.abandonmentFEFA,
    required this.referredOutBoy,
    required this.referredOutGirl,
    required this.referredOutFEFA,
    required this.transferedOutBoy,
    required this.transferedOutGirl,
    required this.transferedOutFEFA,
  });

  final String country, region, location, province, point;
  int patientsAtBeginningBoy;
  int patientsAtBeginningGirl;
  int patientsAtBeginningFEFA;
  int newAdmissionsBoy;
  int newAdmissionsGirl;
  int newAdmissionsFEFA;
  int reAdmissionsBoy;
  int reAdmissionsGirl;
  int reAdmissionsFEFA;
  int relapsesBoy;
  int relapsesGirl;
  int relapsesFEFA;
  int referredInBoy;
  int referredInGirl;
  int referredInFEFA;
  int transferedInBoy;
  int transferedInGirl;
  int transferedInFEFA;
  int totalAdmissionsBoy() => newAdmissionsBoy + reAdmissionsBoy + relapsesBoy + referredInBoy + transferedInBoy;
  int totalAdmissionsGirl() => newAdmissionsGirl + reAdmissionsGirl + relapsesGirl + referredInGirl + transferedInGirl;
  int totalAdmissionsFEFA() => newAdmissionsFEFA + reAdmissionsFEFA + relapsesFEFA + referredInFEFA + transferedInFEFA;
  int totalAttendedBoy() => totalAdmissionsBoy() + patientsAtBeginningBoy;
  int totalAttendedGirl() => totalAdmissionsGirl() + patientsAtBeginningGirl;
  int totalAttendedFEFA() => totalAdmissionsFEFA() + patientsAtBeginningFEFA;
  int recoveredBoy;
  int recoveredGirl;
  int recoveredFEFA;
  int unresponsiveBoy;
  int unresponsiveGirl;
  int unresponsiveFEFA;
  int deathsBoy;
  int deathsGirl;
  int deathsFEFA;
  int abandonmentBoy;
  int abandonmentGirl;
  int abandonmentFEFA;
  int referredOutBoy;
  int referredOutGirl;
  int referredOutFEFA;
  int transferedOutBoy;
  int transferedOutGirl;
  int transferedOutFEFA;
  int totalDischargesBoy() => recoveredBoy + unresponsiveBoy + deathsBoy + abandonmentBoy + referredOutBoy + transferedOutBoy;
  int totalDischargesGirl() => recoveredGirl + unresponsiveGirl + deathsGirl + abandonmentGirl + referredOutGirl + transferedOutGirl;
  int totalDischargesFEFA() => recoveredFEFA + unresponsiveFEFA + deathsFEFA + abandonmentFEFA + referredOutFEFA + transferedOutFEFA;
  int totalAtTheEndBoy() => totalAttendedBoy() - totalDischargesBoy();
  int totalAtTheEndGirl() => totalAttendedGirl() - totalDischargesGirl();
  int totalAtTheEndFEFA() => totalAttendedFEFA() - totalDischargesFEFA();

  @override
  List<Object> get props => [
    country,
    region,
    location,
    province,
    point,
    patientsAtBeginningBoy,
    patientsAtBeginningGirl,
    patientsAtBeginningFEFA,
    newAdmissionsBoy,
    newAdmissionsGirl,
    newAdmissionsFEFA,
    reAdmissionsBoy,
    reAdmissionsGirl,
    reAdmissionsFEFA,
    relapsesBoy,
    relapsesGirl,
    relapsesFEFA,
    referredInBoy,
    referredInGirl,
    referredInFEFA,
    transferedInBoy,
    transferedInGirl,
    transferedInFEFA,
    recoveredBoy,
    recoveredGirl,
    recoveredFEFA,
    unresponsiveBoy,
    unresponsiveGirl,
    unresponsiveFEFA,
    deathsBoy,
    deathsGirl,
    deathsFEFA,
    abandonmentBoy,
    abandonmentGirl,
    abandonmentFEFA,
    referredOutBoy,
    referredOutGirl,
    referredOutFEFA,
    transferedOutBoy,
    transferedOutGirl,
    transferedOutFEFA,
  ];

  @override
  bool get stringify => true;

}


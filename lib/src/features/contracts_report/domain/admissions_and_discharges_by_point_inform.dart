
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class AdmissionsAndDischargesByPointInform {
  AdmissionsAndDischargesByPointInform({
    required this.country,
    required this.region,
    required this.location,
    required this.province,
    required this.point,
    this.patientsAtBeginningBoy = 0,
    this.patientsAtBeginningGirl = 0,
    this.patientsAtBeginningFEFA = 0,
    this.newAdmissionsBoy = 0,
    this.newAdmissionsGirl = 0,
    this.newAdmissionsFEFA = 0,
    this.reAdmissionsBoy = 0,
    this.reAdmissionsGirl = 0,
    this.reAdmissionsFEFA = 0,
    this.relapsesBoy = 0,
    this.relapsesGirl = 0,
    this.relapsesFEFA = 0,
    this.referredInBoy = 0,
    this.referredInGirl = 0,
    this.referredInFEFA = 0,
    this.transferedInBoy = 0,
    this.transferedInGirl = 0,
    this.transferedInFEFA = 0,
    this.recoveredBoy = 0,
    this.recoveredGirl = 0,
    this.recoveredFEFA = 0,
    this.unresponsiveBoy = 0,
    this.unresponsiveGirl = 0,
    this.unresponsiveFEFA = 0,
    this.deathsBoy = 0,
    this.deathsGirl = 0,
    this.deathsFEFA = 0,
    this.abandonmentBoy = 0,
    this.abandonmentGirl = 0,
    this.abandonmentFEFA = 0,
    this.referredOutBoy = 0,
    this.referredOutGirl = 0,
    this.referredOutFEFA = 0,
    this.transferedOutBoy = 0,
    this.transferedOutGirl = 0,
    this.transferedOutFEFA = 0,
    this.percentageBoyAtTheEnd = 0,
    this.percentageGirlAtTheEnd = 0,
    this.percentageFEFAAtTheEnd = 0,
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

  int percentageBoyAtTheEnd, percentageGirlAtTheEnd, percentageFEFAAtTheEnd;
}


/// Package imports
/// import 'package:flutter/foundation.dart';

import 'package:adminnut4health/src/features/cases/domain/case.dart';
import 'package:adminnut4health/src/features/contracts_report/domain/admissions_and_discharges_by_point_inform.dart';
import 'package:adminnut4health/src/features/contracts_report/domain/case_full.dart';
import 'package:adminnut4health/src/features/contracts_report/presentation/admissions_and_discharges_by_point_datagridsource.dart';
import 'package:adminnut4health/src/features/countries/domain/country.dart';
import 'package:adminnut4health/src/features/locations/domain/location.dart';
import 'package:adminnut4health/src/features/points/domain/point.dart';
import 'package:adminnut4health/src/features/provinces/domain/province.dart';
import 'package:adminnut4health/src/sample/samples/datagrid/datagrid_table_summary.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:typed_data';
import 'dart:html' show Blob, AnchorElement, Url;

/// Barcode import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../../sample/model/sample_view.dart';
import '../../regions/domain/region.dart';
/// Local import
import '../data/firestore_repository.dart';
import '../domain/PointWithVisitAndChild.dart';
import 'dart:html' show FileReader;

import '../../../common_widgets/export/save_file_mobile.dart'
  if (dart.library.html) '../../../common_widgets/export/save_file_web.dart' as helper;

import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'contracts_screen_controller.dart';

/// Render contract data grid
class AdmissionsAndDischargesByPointDataGrid extends LocalizationSampleView {
  /// Creates getting started data grid
  const AdmissionsAndDischargesByPointDataGrid({Key? key}) : super(key: key);

  @override
  _AdmissionsAndDischargesByPointDataGridState createState() => _AdmissionsAndDischargesByPointDataGridState();
}

class _AdmissionsAndDischargesByPointDataGridState extends LocalizationSampleViewState {

  final GlobalKey<SfDataGridState> _key = GlobalKey<SfDataGridState>();

  /// DataGridSource required for SfDataGrid to obtain the row data.
  late AdmissionsAndDischargesByPointDataGridSource mainInformDataGridSource;

  static const double dataPagerHeight = 60;
  int _rowsPerPage = 15;

  /// Selected locale
  late String selectedLocale;


  int start = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).millisecondsSinceEpoch;

  int end = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59).millisecondsSinceEpoch;


  /// Translate names
  late String _country, _region, _location, _province, _point, _patientsAtBeginning, _newAdmissions, _reAdmissions,
      _referredIn, _transferedIn, _totalAdmissions, _totalAttended, _recovered,
      _unresponsive, _deaths, _abandonment, _referredOut, _transferedOut,
      _totalDischarges, _totalAtTheEnd, _start, _end, _exportXLS, _exportPDF,
      _total, _contracts, _selectCountry, _selectRegion, _selectLocation,
      _selectProvince, _selectPointType, _selectPoint, _allMale, _allFemale,
      _admissions, _discharges, _boy, _girl, _fefa, _totalBoyGirl, _totalBoyGirlFEFA, _percentages;

  late Map<String, double> columnWidths = {
    'País': 150,
    'Región': 150,
    'Provincia': 150,
    'Municipio': 150,
    'Puesto de salud': 200,
    'Pacientes al inicio (M)': 200,
    'Pacientes al inicio (F)': 200,
    'Pacientes al inicio (FEFA)': 200,
    'Nuevos casos (M)': 200,
    'Nuevos casos (F)': 200,
    'Nuevos casos (FEFA)': 200,
    'Readmisiones (M)': 200,
    'Readmisiones (F)': 200,
    'Readmisiones (FEFA)': 200,
    'Referidos (Admisión) (M)': 200,
    'Referidos (Admisión) (F)': 200,
    'Referidos (Admisión) (FEFA)': 200,
    'Transferidos (Admisión) (M)': 200,
    'Transferidos (Admisión) (F)': 200,
    'Transferidos (Admisión) (FEFA)': 200,
    'TOTAL ADMISIONES (M)': 200,
    'TOTAL ADMISIONES (F)': 200,
    'TOTAL ADMISIONES (FEFA)': 200,
    'TOTAL ATENDIDOS (M)': 200,
    'TOTAL ATENDIDAS (F)': 200,
    'TOTAL ATENDIDAS (FEFA)': 200,
    'Recuperados (M)': 200,
    'Recuperados (F)': 200,
    'Recuperados (FEFA)': 200,
    'Sin respuesta (M)': 200,
    'Sin respuesta (F)': 200,
    'Sin respuesta (FEFA)': 200,
    'Fallecimientos (M)': 200,
    'Fallecimientos (F)': 200,
    'Fallecimientos (FEFA)': 200,
    'Abandonos (M)': 200,
    'Abandonos (F)': 200,
    'Abandonos (FEFA)': 200,
    'Referidos (Alta) (M)': 200,
    'Referidos (Alta) (F)': 200,
    'Referidos (Alta) (FEFA)': 200,
    'Transferidos (Alta) (M)': 200,
    'Transferidos (Alta) (F)': 200,
    'Transferidos (Alta) (FEFA)': 200,
    'TOTAL ALTAS (M)': 200,
    'TOTAL ALTAS (F)': 200,
    'TOTAL ALTAS (FEFA)': 200,
    'TOTAL AL FINAL (M)': 200,
    'TOTAL AL FINAL (F)': 200,
    'TOTAL AL FINAL (FEFA)': 200,
  };


  AsyncValue<List<CaseFull>> casesAsyncValue = AsyncValue.data(List.empty());
  AsyncValue<List<CaseFull>> openCasesBeforeStartDateAsyncValue = AsyncValue.data(List.empty());

  List<Country> countries = <Country>[];
  Country? countrySelected;

  List<Region> regions = <Region>[];
  Region? regionSelected;

  List<Location> locations = <Location>[];
  Location? locationSelected;

  List<Province> provinces = <Province>[];
  Province? provinceSelected;

  late List<String> pointTypes;
  String? pointTypeSelected;

  List<Point> points = <Point>[];
  List<Point> pointsSelected = [];

  List<CaseFull> cases = <CaseFull>[];

  Widget getLocationWidget(String location) {
    return Row(
      children: <Widget>[
        Image.asset('images/location.png'),
        Text(' $location',)
      ],
    );
  }

  _saveCountries(AsyncValue<List<Country>> countries) {      this.countries.clear();
      this.countries.add(Country(countryId: "", name: _allMale, code: "",
          active: false, needValidation: false, cases: 0, casesnormopeso: 0,
          casesmoderada: 0, casessevera: 0));
      this.countries.addAll(countries.value!);
  }

  _saveRegions(AsyncValue<List<Region>>? regions) {
    if (regions == null) {
      return;
    } else {
      this.regions.clear();
      this.regions.add(Region(regionId: '', name: _allFemale, countryId: '', active: false));
      this.regions.addAll(regions.value!);
    }
  }

  _saveLocations(AsyncValue<List<Location>>? locations) {
    if (locations == null) {
      return;
    } else {
      this.locations.clear();
      this.locations.add(Location(locationId: '', name: _allFemale, country: '', regionId: '', active: false));
      this.locations.addAll(locations.value!);
    }
  }

  _saveProvinces(AsyncValue<List<Province>>? provinces) {
    if (provinces == null) {
      return;
    } else {
      this.provinces.clear();
      this.provinces.add(Province(provinceId: '', locationId: '', regionId: '', name: _allFemale, country: '', active: false));
      this.provinces.addAll(provinces.value!);
    }
  }

  _savePoints(AsyncValue<List<Point>>? points) {
    if (points == null) {
      return;
    } else {
      this.points.clear();
      this.points.addAll(points.value!);
      _refreshPointsSelected();
    }
  }

  _saveMainInforms(AsyncValue<List<CaseFull>>? casesFull) {
    if (casesFull == null) {
      mainInformDataGridSource.setMainInforms(List.empty());
    } else {
      cases = casesFull.value!;
      _updateInformData();
    }
  }

  _updateInformData() {
    List<CaseFull> filteredCases = List.from(cases);

    if (countrySelected != null && countrySelected!.name != _allMale) {
      filteredCases = filteredCases.where((c) =>  c.point?.country == countrySelected?.countryId).toList();
    }

    if (regionSelected != null && regionSelected!.name != _allFemale) {
      filteredCases = filteredCases.where((c) =>  c.point?.regionId == regionSelected?.regionId).toList();
    }

    if (locationSelected != null && locationSelected!.name != _allFemale) {
      filteredCases = filteredCases.where((c) =>  c.point?.location == locationSelected?.locationId).toList();
    }

    if (provinceSelected != null && provinceSelected!.name != _allFemale) {
      filteredCases = filteredCases.where((c) =>  c.point?.province == provinceSelected?.provinceId).toList();
    }

    if (pointTypeSelected != null && pointTypeSelected != _allMale) {
      filteredCases = filteredCases.where((c) =>  c.point?.type == pointTypeSelected).toList();
    }

    final pointsIds = pointsSelected.map((point) => point.pointId).toList();
    filteredCases = filteredCases.where((c) => pointsIds.contains(c.point?.pointId)).toList();

    List<AdmissionsAndDischargesByPointInform> informs = [];

    AdmissionsAndDischargesByPointInform informSummaryRow1 = AdmissionsAndDischargesByPointInform(
      country: "",
      region: "",
      location: "",
      province: "",
      point: "TOTAL",
    );

    AdmissionsAndDischargesByPointInform informSummaryRow2 = AdmissionsAndDischargesByPointInform(
      country: "",
      region: "",
      location: "",
      province: "",
      point: _totalBoyGirl,
    );

    AdmissionsAndDischargesByPointInform informSummaryRow3 = AdmissionsAndDischargesByPointInform(
      country: "",
      region: "",
      location: "",
      province: "",
      point: _totalBoyGirlFEFA,
    );

    AdmissionsAndDischargesByPointInform informSummaryRow4 = AdmissionsAndDischargesByPointInform(
      country: "",
      region: "",
      location: "",
      province: "",
      point: _percentages,
    );

    for (Point point in pointsSelected) {
      AdmissionsAndDischargesByPointInform inform = AdmissionsAndDischargesByPointInform(
        country: countries.firstWhere((c) => c.countryId == point.country, orElse: () => const Country.empty()).name,
        region: regions.firstWhere((r) => r.regionId == point.regionId, orElse: () => const Region.empty()).name,
        location: locations.firstWhere((l) => l.locationId == point.location, orElse: () => const Location.empty()).name,
        province: provinces.firstWhere((p) => p.provinceId == point.province, orElse: () => const Province.empty()).name,
        point: point.name,
      );

      if (filteredCases.isNotEmpty) {
        // PATIENTS AT BEGINNING
        final openCasesBeforeStartDate = filteredCases.where((caseFull) =>
          caseFull.myCase.createDate.isBefore(DateTime.fromMillisecondsSinceEpoch(start)) &&
          // Que no estén cerrados, o que estén cerrados DESPUÉS de la fecha de inicio del filtro
          ((caseFull.myCase.closedReason.isEmpty || caseFull.myCase.closedReason == "null") || caseFull.getClosedDate().isAfter(DateTime.fromMillisecondsSinceEpoch(start))) &&
          caseFull.myCase.pointId == point.pointId);
        for (var c in openCasesBeforeStartDate) {
          if (c.child == null || c.child!.childId == '') {
            inform.patientsAtBeginningFEFA++;
          } else {
            if (c.child?.sex == "Masculino" ||
                c.child?.sex == "Homme" ||
                c.child?.sex == "ذكر") {
              inform.patientsAtBeginningBoy++;
            } else {
              inform.patientsAtBeginningGirl++;
            }
          }
        }

        // ADMISSIONS
        final newCasesByDate = filteredCases.where((myCase) =>
            myCase.myCase.createDate.isAfter(DateTime.fromMillisecondsSinceEpoch(start)) &&
            myCase.myCase.createDate.isBefore(DateTime.fromMillisecondsSinceEpoch(end)) &&
            myCase.myCase.pointId == point.pointId);
        for (var c in newCasesByDate) {
          // Nuevos casos
          if (c.myCase.admissionTypeServer == CaseType.newAdmission ||
              c.myCase.admissionTypeServer.isEmpty) {
            if (c.child == null || c.child!.childId == '') {
              inform.newAdmissionsFEFA++;
            } else {
              if (c.child?.sex == "Masculino" ||
                  c.child?.sex == "Homme" ||
                  c.child?.sex == "ذكر") {
                inform.newAdmissionsBoy++;
              } else {
                inform.newAdmissionsGirl++;
              }
            }
          }

          // Readmisiones
          if (c.myCase.admissionTypeServer == CaseType.reAdmission) {
            if (c.child == null || c.child!.childId == '') {
              inform.reAdmissionsFEFA++;
            } else {
              if (c.child?.sex == "Masculino" ||
                  c.child?.sex == "Homme" ||
                  c.child?.sex == "ذكر") {
                inform.reAdmissionsBoy++;
              } else {
                inform.reAdmissionsGirl++;
              }
            }
          }

          // Recaídas
          if (c.myCase.admissionTypeServer == CaseType.relapse) {
            if (c.child == null || c.child!.childId == '') {
              inform.relapsesFEFA++;
            } else {
              if (c.child?.sex == "Masculino" ||
                  c.child?.sex == "Homme" ||
                  c.child?.sex == "ذكر") {
                inform.relapsesBoy++;
              } else {
                inform.relapsesGirl++;
              }
            }
          }

          // Referidos
          if (c.myCase.admissionTypeServer == CaseType.referred) {
            if (c.child == null || c.child!.childId == '') {
              inform.referredInFEFA++;
            } else {
              if (c.child?.sex == "Masculino" ||
                  c.child?.sex == "Homme" ||
                  c.child?.sex == "ذكر") {
                inform.referredInBoy++;
              } else {
                inform.referredInGirl++;
              }
            }
          }

          // Transferidos
          if (c.myCase.admissionTypeServer == CaseType.transfered) {
            if (c.child == null || c.child!.childId == '') {
              inform.transferedInFEFA++;
            } else {
              if (c.child?.sex == "Masculino" ||
                  c.child?.sex == "Homme" ||
                  c.child?.sex == "ذكر") {
                inform.transferedInBoy++;
              } else {
                inform.transferedInGirl++;
              }
            }
          }
        }

        // DISCHARGES
        final closedCasesByDate = filteredCases.where((caseFull) =>
        caseFull.getClosedDate().isAfter(DateTime.fromMillisecondsSinceEpoch(start)) &&
            caseFull.getClosedDate().isBefore(DateTime.fromMillisecondsSinceEpoch(end)) &&
            caseFull.myCase.closedReason != "null" && caseFull.myCase.closedReason.isNotEmpty &&
            caseFull.myCase.pointId == point.pointId);
        for (var c in closedCasesByDate) {
          // Recuperados
          if (c.myCase.closedReason == CaseType.recovered) {
            if (c.child == null || c.child!.childId == '') {
              inform.recoveredFEFA++;
            } else {
              if (c.child?.sex == "Masculino" ||
                  c.child?.sex == "Homme" ||
                  c.child?.sex == "ذكر") {
                inform.recoveredBoy++;
              } else {
                inform.recoveredGirl++;
              }
            }
          }

          // Sin respuesta
          if (c.myCase.closedReason == CaseType.unresponsive) {
            if (c.child == null || c.child!.childId == '') {
              inform.unresponsiveFEFA++;
            } else {
              if (c.child?.sex == "Masculino" ||
                  c.child?.sex == "Homme" ||
                  c.child?.sex == "ذكر") {
                inform.unresponsiveBoy++;
              } else {
                inform.unresponsiveGirl++;
              }
            }
          }

          // Fallecimientos
          if (c.myCase.closedReason == CaseType.death) {
            if (c.child == null || c.child!.childId == '') {
              inform.deathsFEFA++;
            } else {
              if (c.child?.sex == "Masculino" ||
                  c.child?.sex == "Homme" ||
                  c.child?.sex == "ذكر") {
                inform.deathsBoy++;
              } else {
                inform.deathsGirl++;
              }
            }
          }

          // Abandonos
          if (c.myCase.closedReason == CaseType.abandonment) {
            if (c.child == null || c.child!.childId == '') {
              inform.abandonmentFEFA++;
            } else {
              if (c.child?.sex == "Masculino" ||
                  c.child?.sex == "Homme" ||
                  c.child?.sex == "ذكر") {
                inform.abandonmentBoy++;
              } else {
                inform.abandonmentGirl++;
              }
            }
          }

          // Referidos
          if (c.myCase.closedReason == CaseType.referred) {
            if (c.child == null || c.child!.childId == '') {
              inform.referredOutFEFA++;
            } else {
              if (c.child?.sex == "Masculino" ||
                  c.child?.sex == "Homme" ||
                  c.child?.sex == "ذكر") {
                inform.referredOutBoy++;
              } else {
                inform.referredOutGirl++;
              }
            }
          }

          // Transferidos
          if (c.myCase.closedReason == CaseType.transfered) {
            if (c.child == null || c.child!.childId == '') {
              inform.transferedOutFEFA++;
            } else {
              if (c.child?.sex == "Masculino" ||
                  c.child?.sex == "Homme" ||
                  c.child?.sex == "ذكر") {
                inform.transferedOutBoy++;
              } else {
                inform.transferedOutGirl++;
              }
            }
          }
        }

        informs.add(inform);
        // Totales por cada columna
        informSummaryRow1.patientsAtBeginningBoy += inform.patientsAtBeginningBoy;
        informSummaryRow1.patientsAtBeginningGirl += inform.patientsAtBeginningGirl;
        informSummaryRow1.patientsAtBeginningFEFA += inform.patientsAtBeginningFEFA;
        informSummaryRow1.newAdmissionsBoy += inform.newAdmissionsBoy;
        informSummaryRow1.newAdmissionsGirl += inform.newAdmissionsGirl;
        informSummaryRow1.newAdmissionsFEFA += inform.newAdmissionsFEFA;
        informSummaryRow1.reAdmissionsBoy += inform.reAdmissionsBoy;
        informSummaryRow1.reAdmissionsGirl += inform.reAdmissionsGirl;
        informSummaryRow1.reAdmissionsFEFA += inform.reAdmissionsFEFA;
        informSummaryRow1.relapsesBoy += inform.relapsesBoy;
        informSummaryRow1.relapsesGirl += inform.relapsesGirl;
        informSummaryRow1.relapsesFEFA += inform.relapsesFEFA;
        informSummaryRow1.referredInBoy += inform.referredInBoy;
        informSummaryRow1.referredInGirl += inform.referredInGirl;
        informSummaryRow1.referredInFEFA += inform.referredInFEFA;
        informSummaryRow1.transferedInBoy += inform.transferedInBoy;
        informSummaryRow1.transferedInGirl += inform.transferedInGirl;
        informSummaryRow1.transferedInFEFA += inform.transferedInFEFA;
        informSummaryRow1.recoveredBoy += inform.recoveredBoy;
        informSummaryRow1.recoveredGirl += inform.recoveredGirl;
        informSummaryRow1.recoveredFEFA += inform.recoveredFEFA;
        informSummaryRow1.unresponsiveBoy += inform.unresponsiveBoy;
        informSummaryRow1.unresponsiveGirl += inform.unresponsiveGirl;
        informSummaryRow1.unresponsiveFEFA += inform.unresponsiveFEFA;
        informSummaryRow1.deathsBoy += inform.deathsBoy;
        informSummaryRow1.deathsGirl += inform.deathsGirl;
        informSummaryRow1.deathsFEFA += inform.deathsFEFA;
        informSummaryRow1.abandonmentBoy += inform.abandonmentBoy;
        informSummaryRow1.abandonmentGirl += inform.abandonmentGirl;
        informSummaryRow1.abandonmentFEFA += inform.abandonmentFEFA;
        informSummaryRow1.referredOutBoy += inform.referredOutBoy;
        informSummaryRow1.referredOutGirl += inform.referredOutGirl;
        informSummaryRow1.referredOutFEFA += inform.referredOutFEFA;
        informSummaryRow1.transferedOutBoy += inform.transferedOutBoy;
        informSummaryRow1.transferedOutGirl += inform.transferedOutGirl;
        informSummaryRow1.transferedOutFEFA += inform.transferedOutFEFA;

        // Totales juntando niños y niñas
        informSummaryRow2.patientsAtBeginningGirl += (inform.patientsAtBeginningBoy + inform.patientsAtBeginningGirl);
        informSummaryRow2.newAdmissionsGirl += (inform.newAdmissionsBoy + inform.newAdmissionsGirl);
        informSummaryRow2.reAdmissionsGirl += (inform.reAdmissionsBoy + inform.reAdmissionsGirl);
        informSummaryRow2.relapsesGirl += (inform.relapsesBoy + inform.relapsesGirl);
        informSummaryRow2.referredInGirl += (inform.referredInBoy + inform.referredInGirl);
        informSummaryRow2.transferedInGirl += (inform.transferedInBoy + inform.transferedInGirl);
        informSummaryRow2.recoveredGirl += (inform.recoveredBoy + inform.recoveredGirl);
        informSummaryRow2.unresponsiveGirl += (inform.unresponsiveBoy + inform.unresponsiveGirl);
        informSummaryRow2.deathsGirl += (inform.deathsBoy + inform.deathsGirl);
        informSummaryRow2.abandonmentGirl += (inform.abandonmentBoy + inform.abandonmentGirl);
        informSummaryRow2.referredOutGirl += (inform.referredOutBoy + inform.referredOutGirl);
        informSummaryRow2.transferedOutGirl += (inform.transferedOutBoy + inform.transferedOutGirl);

        // Totales juntando niñas, niños y MEL
        informSummaryRow3.patientsAtBeginningFEFA += (inform.patientsAtBeginningBoy + inform.patientsAtBeginningGirl + inform.patientsAtBeginningFEFA);
        informSummaryRow3.newAdmissionsFEFA += (inform.newAdmissionsBoy + inform.newAdmissionsGirl + inform.newAdmissionsFEFA);
        informSummaryRow3.reAdmissionsFEFA += (inform.reAdmissionsBoy + inform.reAdmissionsGirl + inform.reAdmissionsFEFA);
        informSummaryRow3.relapsesFEFA += (inform.relapsesBoy + inform.relapsesGirl + inform.relapsesFEFA);
        informSummaryRow3.referredInFEFA += (inform.referredInBoy + inform.referredInGirl + inform.referredInFEFA);
        informSummaryRow3.transferedInFEFA += (inform.transferedInBoy + inform.transferedInGirl + inform.transferedInFEFA);
        informSummaryRow3.recoveredFEFA += (inform.recoveredBoy + inform.recoveredGirl + inform.recoveredFEFA);
        informSummaryRow3.unresponsiveFEFA += (inform.unresponsiveBoy + inform.unresponsiveGirl + inform.unresponsiveFEFA);
        informSummaryRow3.deathsFEFA += (inform.deathsBoy + inform.deathsGirl + inform.deathsFEFA);
        informSummaryRow3.abandonmentFEFA += (inform.abandonmentBoy + inform.abandonmentGirl + inform.abandonmentFEFA);
        informSummaryRow3.referredOutFEFA += (inform.referredOutBoy + inform.referredOutGirl + inform.referredOutFEFA);
        informSummaryRow3.transferedOutFEFA += (inform.transferedOutBoy + inform.transferedOutGirl + inform.transferedOutFEFA);
      }
    }

    // Completar los campos de la segunda fila de totales (en FEFA el total de FEFAS)
    informSummaryRow2.patientsAtBeginningFEFA = informSummaryRow1.patientsAtBeginningFEFA;
    informSummaryRow2.newAdmissionsFEFA = informSummaryRow1.newAdmissionsFEFA;
    informSummaryRow2.reAdmissionsFEFA = informSummaryRow1.reAdmissionsFEFA;
    informSummaryRow2.relapsesFEFA = informSummaryRow1.relapsesFEFA;
    informSummaryRow2.referredInFEFA = informSummaryRow1.referredInFEFA;
    informSummaryRow2.transferedInFEFA = informSummaryRow1.transferedInFEFA;
    informSummaryRow2.recoveredFEFA = informSummaryRow1.recoveredFEFA;
    informSummaryRow2.unresponsiveFEFA = informSummaryRow1.unresponsiveFEFA;
    informSummaryRow2.deathsFEFA = informSummaryRow1.deathsFEFA;
    informSummaryRow2.abandonmentFEFA = informSummaryRow1.abandonmentFEFA;
    informSummaryRow2.referredOutFEFA = informSummaryRow1.referredOutFEFA;
    informSummaryRow2.transferedOutFEFA = informSummaryRow1.transferedOutFEFA;

    // PORCENTAJES niños y niñas
    if (informSummaryRow2.totalAttendedGirl() != 0){
      informSummaryRow4.referredInGirl = (informSummaryRow2.referredInGirl/informSummaryRow2.totalAttendedGirl()*100).floor();
    }
    // PORCENTAJES niños, niñas y FEFA
    if (informSummaryRow3.totalDischargesFEFA() != 0) {
      informSummaryRow4.recoveredFEFA = (informSummaryRow3.recoveredFEFA / informSummaryRow3.totalDischargesFEFA() * 100).floor();
      informSummaryRow4.unresponsiveFEFA = (informSummaryRow3.unresponsiveFEFA / informSummaryRow3.totalDischargesFEFA() * 100).floor();
      informSummaryRow4.deathsFEFA = (informSummaryRow3.deathsFEFA / informSummaryRow3.totalDischargesFEFA() * 100).floor();
      informSummaryRow4.abandonmentFEFA = (informSummaryRow3.abandonmentFEFA / informSummaryRow3.totalDischargesFEFA() * 100).floor();
    }

    if (informSummaryRow3.totalAtTheEndFEFA() != 0) {informSummaryRow4.percentageBoyAtTheEnd = (informSummaryRow1.totalAtTheEndBoy() / informSummaryRow3.totalAtTheEndFEFA() * 100).floor();
      informSummaryRow4.percentageGirlAtTheEnd = (informSummaryRow1.totalAtTheEndGirl() / informSummaryRow3.totalAtTheEndFEFA() * 100).floor();
      informSummaryRow4.percentageFEFAAtTheEnd = (informSummaryRow1.totalAtTheEndFEFA() / informSummaryRow3.totalAtTheEndFEFA() * 100).floor();
    }

    informs.add(informSummaryRow1);
    informs.add(informSummaryRow2);
    informs.add(informSummaryRow3);
    informs.add(informSummaryRow4);

    mainInformDataGridSource.setMainInforms(informs);

    mainInformDataGridSource.buildDataGridRows(/*enableFiltering: true, showByWomenOrigin: true*/);
    mainInformDataGridSource.updateDataSource();
  }

  Widget _buildView(AsyncValue<List<CaseFull>> cases) {
    if (cases.value != null) {
      selectedLocale = model.locale.toString();
      mainInformDataGridSource.updateSelectedLocale(selectedLocale);
      mainInformDataGridSource.buildDataGridRows();
      mainInformDataGridSource.updateDataSource();
      return _buildLayoutBuilder();
    } else {
      return const Center(
         child: SizedBox(
           width: 200,
           height: 200,
           child: CircularProgressIndicator(),
         )
      );
    }
  }

  Widget _buildLayoutBuilder() {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraint) {
          if (mainInformDataGridSource.getMainInforms()!.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildHeaderButtons(),
                const SizedBox(height: 20.0,),
                const Expanded(
                  child: Center(
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: Text("No hay datos que mostrar"),
                      )),
                ),
              ],
            );
          } else {
          return SingleChildScrollView(
            child: Column(
                children: <Widget>[
                  _buildHeaderButtons(),
                  const SizedBox(height: 20.0,),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: SfDataGridTheme(
                        data: SfDataGridThemeData(headerColor: Colors.blueAccent),
                        child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: _buildDataGrid()
                        )
                    ),
                  ),
                  Container(
                    height: dataPagerHeight,
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withOpacity(0.12),
                        border: Border(
                            top: BorderSide(
                                width: .5,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.12)))),
                    child: Align(child: _buildDataPager()),
                  ),
                ],
            ),
          );
        }});
  }

  Future<String> readBlob(Blob blob) async {
    final reader = FileReader();
    reader.readAsText(blob);
    await reader.onLoad.first;
    return reader.result as String;
  }

  Widget _buildHeaderButtons() {
    Future<void> exportDataGridToExcel() async {
      //CustomDataGridToExcelConverter excelConverter = CustomDataGridToExcelConverter();
      //final Workbook workbook = _key.currentState!.exportToExcelWorkbook(converter: excelConverter);
      final Workbook workbook = _key.currentState!.exportToExcelWorkbook(
        //exportTableSummaries: false,
          cellExport: (DataGridCellExcelExportDetails details) {
          });
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();
      await helper.FileSaveHelper.saveAndLaunchFile(bytes, '$_contracts.xlsx');
    }

    Future<void> exportDataGridToPdf() async {
      final ByteData data = await rootBundle.load('images/nut_logo.jpg');
      final PdfDocument document = _key.currentState!.exportToPdfDocument(
          cellExport: (DataGridCellPdfExportDetails details) {},
          headerFooterExport: (DataGridPdfHeaderFooterExportDetails details) {
            final double width = details.pdfPage.getClientSize().width;
            final PdfPageTemplateElement header =
            PdfPageTemplateElement(Rect.fromLTWH(0, 0, width, 65));

            header.graphics.drawImage(
                PdfBitmap(data.buffer
                    .asUint8List(data.offsetInBytes, data.lengthInBytes)),
                Rect.fromLTWH(width - 148, 0, 148, 60));

            header.graphics.drawString(_contracts,
              PdfStandardFont(PdfFontFamily.helvetica, 13,
                  style: PdfFontStyle.bold),
              bounds: const Rect.fromLTWH(0, 25, 200, 60),
            );

            details.pdfDocumentTemplate.top = header;
          });
      final List<int> bytes = document.saveSync();
      await helper.FileSaveHelper.saveAndLaunchFile(bytes, '$_contracts.pdf');
      document.dispose();
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(child: _buildFilterRow(),),
          _buildExcelExportingButton(_exportXLS, onPressed: exportDataGridToExcel),
          _buildPDFExportingButton(_exportPDF, onPressed: exportDataGridToPdf),
        ],
      ),
    );

  }

  Widget _buildExcelExportingButton(String buttonName,
      {required VoidCallback onPressed}) {
    return Container(
        height: 60.0,
        padding: const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0),
        child: IconButton(
          icon: const Icon(
              FontAwesomeIcons.fileExcel,
              color: Colors.blueAccent),
          onPressed: onPressed,)
    );
  }

  Widget _buildPDFExportingButton(String buttonName,
      {required VoidCallback onPressed}) {
    return Container(
        height: 60.0,
        padding: const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0),
        child: IconButton(
          icon: const Icon(
              FontAwesomeIcons.filePdf,
              color: Colors.blueAccent),
          onPressed: onPressed,)
    );
  }

  Widget _buildDataPager() {
    var rows = mainInformDataGridSource.rows;
    if (mainInformDataGridSource.effectiveRows.isNotEmpty ) {
      rows = mainInformDataGridSource.effectiveRows;
    }
    var addMorePage = 0;
    if ((rows.length / _rowsPerPage).remainder(1) != 0) {
      addMorePage  = 1;
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SfDataPager(
        delegate: mainInformDataGridSource,
        availableRowsPerPage: const <int>[15, 20, 25],
        pageCount: (rows.length / _rowsPerPage) + addMorePage,
        onRowsPerPageChanged: (int? rowsPerPage) {
          setState(() {
            _rowsPerPage = rowsPerPage!;
          });
        },
      ),
    );

  }

  SfDataGrid _buildDataGrid() {
    return SfDataGrid(
      frozenColumnsCount: 5,
      headerGridLinesVisibility: GridLinesVisibility.both,
      gridLinesVisibility: GridLinesVisibility.both,
      key: _key,
      source: mainInformDataGridSource,
      rowsPerPage: _rowsPerPage,
      allowColumnsResizing: true,
      shrinkWrapRows: true,
      onColumnResizeUpdate: (ColumnResizeUpdateDetails details) {
        setState(() {
          columnWidths[details.column.columnName] = details.width;
        });
        return true;
      },
      allowFiltering: true,
      onFilterChanged: (DataGridFilterChangeDetails details) {
        setState(() {
          _buildLayoutBuilder();
        });
      },
      allowSorting: false,
      allowMultiColumnSorting: false,
      columns: <GridColumn>[
        GridColumn(
            columnName: 'País',
            width: columnWidths['País']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _country,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Región',
            width: columnWidths['Región']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _region,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Provincia',
            width: columnWidths['Provincia']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _location,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Municipio',
            width: columnWidths['Municipio']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _province,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Puesto de salud',
            width: columnWidths['Puesto de salud']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _point,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Pacientes al inicio (M)',
            width: columnWidths['Pacientes al inicio (M)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _boy,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Pacientes al inicio (F)',
            width: columnWidths['Pacientes al inicio (F)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _girl,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Pacientes al inicio (FEFA)',
            width: columnWidths['Pacientes al inicio (FEFA)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _fefa,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        // ADMISSIONS
        GridColumn(
            columnName: 'Nuevos casos (M)',
            width: columnWidths['Nuevos casos (M)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _boy,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Nuevos casos (F)',
            width: columnWidths['Nuevos casos (F)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _girl,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Nuevos casos (FEFA)',
            width: columnWidths['Nuevos casos (FEFA)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _fefa,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Readmisiones (M)',
            width: columnWidths['Readmisiones (M)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _boy,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Readmisiones (F)',
            width: columnWidths['Readmisiones (F)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _girl,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Readmisiones (FEFA)',
            width: columnWidths['Readmisiones (FEFA)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _fefa,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Referidos (Admisión) (M)',
            width: columnWidths['Referidos (Admisión) (M)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _boy,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Referidos (Admisión) (F)',
            width: columnWidths['Referidos (Admisión) (F)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _girl,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Referidos (Admisión) (FEFA)',
            width: columnWidths['Referidos (Admisión) (FEFA)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _fefa,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Transferidos (Admisión) (M)',
            width: columnWidths['Transferidos (Admisión) (M)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _boy,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Transferidos (Admisión) (F)',
            width: columnWidths['Transferidos (Admisión) (F)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _girl,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Transferidos (Admisión) (FEFA)',
            width: columnWidths['Transferidos (Admisión) (FEFA)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _fefa,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'TOTAL ADMISIONES (M)',
            width: columnWidths['TOTAL ADMISIONES (M)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _boy,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'TOTAL ADMISIONES (F)',
            width: columnWidths['TOTAL ADMISIONES (F)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _girl,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'TOTAL ADMISIONES (FEFA)',
            width: columnWidths['TOTAL ADMISIONES (FEFA)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _fefa,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'TOTAL ATENDIDOS (M)',
            width: columnWidths['TOTAL ATENDIDOS (M)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _boy,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'TOTAL ATENDIDAS (F)',
            width: columnWidths['TOTAL ATENDIDAS (F)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _girl,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'TOTAL ATENDIDAS (FEFA)',
            width: columnWidths['TOTAL ATENDIDAS (FEFA)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _fefa,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        // DISCHARGES
        GridColumn(
            columnName: 'Recuperados (M)',
            width: columnWidths['Recuperados (M)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _boy,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Recuperados (F)',
            width: columnWidths['Recuperados (F)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _girl,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Recuperados (FEFA)',
            width: columnWidths['Recuperados (FEFA)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _fefa,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Sin respuesta (M)',
            width: columnWidths['Sin respuesta (M)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _boy,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Sin respuesta (F)',
            width: columnWidths['Sin respuesta (F)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _girl,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Sin respuesta (FEFA)',
            width: columnWidths['Sin respuesta (FEFA)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _fefa,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Fallecimientos (M)',
            width: columnWidths['Fallecimientos (M)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _boy,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Fallecimientos (F)',
            width: columnWidths['Fallecimientos (F)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _girl,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Fallecimientos (FEFA)',
            width: columnWidths['Fallecimientos (FEFA)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _fefa,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Abandonos (M)',
            width: columnWidths['Abandonos (M)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _boy,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Abandonos (F)',
            width: columnWidths['Abandonos (F)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _girl,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Abandonos (FEFA)',
            width: columnWidths['Abandonos (FEFA)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _fefa,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Referidos (Alta) (M)',
            width: columnWidths['Referidos (Alta) (M)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _boy,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Referidos (Alta) (F)',
            width: columnWidths['Referidos (Alta) (F)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _girl,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Referidos (Alta) (FEFA)',
            width: columnWidths['Referidos (Alta) (FEFA)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _fefa,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Transferidos (Alta) (M)',
            width: columnWidths['Transferidos (Alta) (M)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _boy,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Transferidos (Alta) (F)',
            width: columnWidths['Transferidos (Alta) (F)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _girl,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Transferidos (Alta) (FEFA)',
            width: columnWidths['Transferidos (Alta) (FEFA)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _fefa,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'TOTAL ALTAS (M)',
            width: columnWidths['TOTAL ALTAS (M)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _boy,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'TOTAL ALTAS (F)',
            width: columnWidths['TOTAL ALTAS (F)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _girl,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'TOTAL ALTAS (FEFA)',
            width: columnWidths['TOTAL ALTAS (FEFA)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _fefa,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'TOTAL AL FINAL (M)',
            width: columnWidths['TOTAL AL FINAL (M)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _boy,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'TOTAL AL FINAL (F)',
            width: columnWidths['TOTAL AL FINAL (F)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _girl,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'TOTAL AL FINAL (FEFA)',
            width: columnWidths['TOTAL AL FINAL (FEFA)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _fefa,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
      ],
      stackedHeaderRows: <StackedHeaderRow>[
        StackedHeaderRow(cells: [
          StackedHeaderCell(
              columnNames: [
                'Nuevos casos (M)', 'Readmisiones (M)', 'Referidos (Admisión) (M)', 'Transferidos (Admisión) (M)', 'TOTAL ADMISIONES (M)',
                'Nuevos casos (F)', 'Readmisiones (F)', 'Referidos (Admisión) (F)', 'Transferidos (Admisión) (F)', 'TOTAL ADMISIONES (F)',
                'Nuevos casos (FEFA)', 'Readmisiones (FEFA)', 'Referidos (Admisión) (FEFA)', 'Transferidos (Admisión) (FEFA)', 'TOTAL ADMISIONES (FEFA)',],
              child: Center(child: Text(_admissions, style: const TextStyle(fontWeight: FontWeight.bold),))),
          StackedHeaderCell(
              columnNames: [
                'Recuperados (M)', 'Sin respuesta (M)', 'Fallecimientos (M)', 'Abandonos (M)', 'Referidos (Alta) (M)', 'Transferidos (Alta) (M)', 'TOTAL ALTAS (M)',
                'Recuperados (F)', 'Sin respuesta (F)', 'Fallecimientos (F)', 'Abandonos (F)', 'Referidos (Alta) (F)', 'Transferidos (Alta) (F)', 'TOTAL ALTAS (F)',
                'Recuperados (FEFA)', 'Sin respuesta (FEFA)', 'Fallecimientos (FEFA)', 'Abandonos (FEFA)', 'Referidos (Alta) (FEFA)', 'Transferidos (Alta) (FEFA)', 'TOTAL ALTAS (FEFA)'],
              child: Center(child: Text(_discharges, style: const TextStyle(fontWeight: FontWeight.bold),))),
        ]),
        StackedHeaderRow(cells: [
          StackedHeaderCell(
              columnNames: ['Pacientes al inicio (M)', 'Pacientes al inicio (F)', 'Pacientes al inicio (FEFA)'],
              child: Center(child: Text(_patientsAtBeginning, style: const TextStyle(fontWeight: FontWeight.bold),))),
          // ADMISSIONS
          StackedHeaderCell(
              columnNames: ['Nuevos casos (M)', 'Nuevos casos (F)', 'Nuevos casos (FEFA)'],
              child: Center(child: Text(_newAdmissions, style: const TextStyle(fontWeight: FontWeight.bold),))),
          StackedHeaderCell(
              columnNames: ['Readmisiones (M)', 'Readmisiones (F)', 'Readmisiones (FEFA)'],
              child: Center(child: Text(_reAdmissions, style: const TextStyle(fontWeight: FontWeight.bold),))),
          StackedHeaderCell(
              columnNames: ['Referidos (Admisión) (M)', 'Referidos (Admisión) (F)', 'Referidos (Admisión) (FEFA)'],
              child: Center(child: Text(_referredIn, style: const TextStyle(fontWeight: FontWeight.bold),))),
          StackedHeaderCell(
              columnNames: ['Transferidos (Admisión) (M)', 'Transferidos (Admisión) (F)', 'Transferidos (Admisión) (FEFA)'],
              child: Center(child: Text(_transferedIn, style: const TextStyle(fontWeight: FontWeight.bold),))),
          StackedHeaderCell(
              columnNames: ['TOTAL ADMISIONES (M)', 'TOTAL ADMISIONES (F)', 'TOTAL ADMISIONES (FEFA)'],
              child: Center(child: Text(_totalAdmissions, style: const TextStyle(fontWeight: FontWeight.bold),))),
          StackedHeaderCell(
              columnNames: ['TOTAL ATENDIDOS (M)', 'TOTAL ATENDIDAS (F)', 'TOTAL ATENDIDAS (FEFA)'],
              child: Center(child: Text(_totalAttended, style: const TextStyle(fontWeight: FontWeight.bold),))),
          // DISCHARGES
          StackedHeaderCell(
              columnNames: ['Recuperados (M)', 'Recuperados (F)', 'Recuperados (FEFA)'],
              child: Center(child: Text(_recovered, style: const TextStyle(fontWeight: FontWeight.bold),))),
          StackedHeaderCell(
              columnNames: ['Sin respuesta (M)', 'Sin respuesta (F)', 'Sin respuesta (FEFA)'],
              child: Center(child: Text(_unresponsive, style: const TextStyle(fontWeight: FontWeight.bold),))),
          StackedHeaderCell(
              columnNames: ['Fallecimientos (M)', 'Fallecimientos (F)', 'Fallecimientos (FEFA)'],
              child: Center(child: Text(_deaths, style: const TextStyle(fontWeight: FontWeight.bold),))),
          StackedHeaderCell(
              columnNames: ['Abandonos (M)', 'Abandonos (F)', 'Abandonos (FEFA)'],
              child: Center(child: Text(_abandonment, style: const TextStyle(fontWeight: FontWeight.bold),))),
          StackedHeaderCell(
              columnNames: ['Referidos (Alta) (M)', 'Referidos (Alta) (F)', 'Referidos (Alta) (FEFA)'],
              child: Center(child: Text(_referredOut, style: const TextStyle(fontWeight: FontWeight.bold),))),
          StackedHeaderCell(
              columnNames: ['Transferidos (Alta) (M)', 'Transferidos (Alta) (F)', 'Transferidos (Alta) (FEFA)'],
              child: Center(child: Text(_transferedOut, style: const TextStyle(fontWeight: FontWeight.bold),))),
          StackedHeaderCell(
              columnNames: ['TOTAL ALTAS (M)', 'TOTAL ALTAS (F)', 'TOTAL ALTAS (FEFA)'],
              child: Center(child: Text(_totalDischarges, style: const TextStyle(fontWeight: FontWeight.bold),))),
          StackedHeaderCell(
              columnNames: ['TOTAL AL FINAL (M)', 'TOTAL AL FINAL (F)', 'TOTAL AL FINAL (FEFA)'],
              child: Center(child: Text(_totalAtTheEnd, style: const TextStyle(fontWeight: FontWeight.bold),))),
        ]),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    mainInformDataGridSource = AdmissionsAndDischargesByPointDataGridSource(List.empty());

    selectedLocale = model.locale.toString();
    switch (selectedLocale) {
      case 'en_US':
        _country = 'Country';
        _region = 'Region';
        _location = 'Province';
        _province = 'Municipality';
        _point = 'Healthcare Position';
        _patientsAtBeginning = 'Patients at beginning';
        _newAdmissions = 'New admissions';
        _reAdmissions = 'Readmissions';
        _referredIn = 'Referred (Admission)';
        _transferedIn = 'Transferred (Admission)';
        _totalAdmissions = 'TOTAL ADMISSIONS';
        _totalAttended = 'TOTAL ATTENDED';
        _recovered = 'Recovered';
        _unresponsive = 'Unresponsive';
        _deaths = 'Deaths';
        _abandonment = 'Abandonment';
        _referredOut = 'Referred (Discharge)';
        _transferedOut = 'Transferred (Discharge)';
        _totalDischarges = 'TOTAL DISCHARGES';
        _totalAtTheEnd = 'TOTAL AT THE END';
        _totalBoyGirl = 'TOTAL GIRLS AND BOYS';
        _totalBoyGirlFEFA = 'TOTAL GIRLS, BOYS AND FEFA';
        _percentages = 'PERCENTAGES (%)';
        _exportXLS = 'Export XLS';
        _exportPDF = 'Export PDF';
        _total = 'Total Locations';
        _contracts = 'Diagnosis';
        _start = 'Start';
        _end = 'End';
        _allMale = 'ALL';
        _allFemale = 'ALL';
        _admissions = 'ADMISSIONS';
        _discharges = 'DISCHARGES';
        _boy = 'Boys';
        _girl = 'Girls';
        _fefa = 'FEFA';
        break;
      case 'es_ES':
        _country = 'País';
        _region = 'Región';
        _location = 'Provincia';
        _province = 'Municipio';
        _point = 'Puesto de salud';
        _patientsAtBeginning = 'Pacientes al inicio';
        _newAdmissions = 'Nuevos casos';
        _reAdmissions = 'Readmisiones';
        _referredIn = 'Referidos (Admisión)';
        _transferedIn = 'Transferidos (Admisión)';
        _totalAdmissions = 'TOTAL ADMISIONES';
        _totalAttended = 'TOTAL ATENDIDOS/AS';
        _recovered = 'Recuperados';
        _unresponsive = 'Sin respuesta';
        _deaths = 'Fallecimientos';
        _abandonment = 'Abandonos';
        _referredOut = 'Referidos (Alta)';
        _transferedOut = 'Transferidos (Alta)';
        _totalDischarges = 'TOTAL ALTAS';
        _totalAtTheEnd = 'TOTAL AL FINAL';
        _totalBoyGirl = 'TOTALES NIÑAS Y NIÑOS';
        _totalBoyGirlFEFA = 'TOTALES NIÑAS, NIÑOS Y MEL';
        _percentages = 'PORCENTAJES (%)';
        _exportXLS = 'Exportar XLS';
        _exportPDF = 'Exportar PDF';
        _total = 'Totales';
        _contracts = 'Diagnósticos';
        _start = 'Inicio';
        _end = 'Fin';
        _allMale = 'TODOS';
        _allFemale = 'TODAS';
        _admissions = 'ADMISIONES';
        _discharges = 'ALTAS';
        _boy = 'Niños';
        _girl = 'Niñas';
        _fefa = 'MEL';
        break;
      case 'fr_FR':
        _country = 'Pays';
        _region = 'Région';
        _location = 'Province';
        _province = 'Municipalité';
        _point = 'Poste de santé';
        _patientsAtBeginning = 'Patients au début';
        _newAdmissions = 'Nouvelles admissions';
        _reAdmissions = 'Réadmissions';
        _referredIn = 'Références (Admission)';
        _transferedIn = 'Transféré (Admission)';
        _totalAdmissions = 'ADMISSIONS TOTALES';
        _totalAttended = 'ATTENTION TOTALE';
        _recovered = 'Rétabli';
        _unresponsive = 'Sans réponse';
        _deaths = 'Décès';
        _abandonment = 'Décrocheurs';
        _referredOut = 'Références (Sortie)';
        _transferedOut = 'Transféré (Sortie)';
        _totalDischarges = 'SORTIES TOTALES';
        _totalAtTheEnd = 'TOTAL À LA FIN';
        _totalBoyGirl = 'TOTAL FILLES ET GARÇONS';
        _totalBoyGirlFEFA = 'TOTAL FILLES, GARCONS ET FEFA';
        _percentages = 'POURCENTAGES (%)';
        _exportXLS = 'Exporter XLS';
        _exportPDF = 'Exporter PDF';
        _total = 'Total';
        _contracts = 'Diagnostics';
        _start = 'Début';
        _end = 'Fin';
        _allMale = 'TOUS';
        _allFemale = 'TOUTES';
        _admissions = 'ADMISSIONS';
        _discharges = 'SORTIES';
        _boy = 'Garçons';
        _girl = 'Filles';
        _fefa = 'FEFA';
        break;
    }

    pointTypes = [_allMale, "CRENAM", "CRENAS", "CRENI", "Otro"];
  }


  @override
  Widget buildSample(BuildContext context) {

    return Consumer(
        builder: (context, ref, child) {
          ref.listen<AsyncValue>(
            contractsScreenControllerProvider,
                (_, state) => {
            },
          );

          final countriesAsyncValue = ref.watch(countriesStreamProvider);
          final regionsAsyncValue = ref.watch(regionsByCountryStreamProvider(countrySelected?.countryId??""));
          final locationFilter = Tuple2(countrySelected?.countryId??"", regionSelected?.regionId??"");
          final locationsAsyncValue = ref.watch(locationsByCountryAndRegionStreamProvider(locationFilter));
          final provinceFilter = Tuple3(countrySelected?.countryId??"", regionSelected?.regionId??"", locationSelected?.locationId??"",);
          final provincesAsyncValue = ref.watch(provincesByLocationStreamProvider(provinceFilter));
          final pointFilter = Tuple5(
            countrySelected?.countryId??"",
            regionSelected?.regionId??"",
            locationSelected?.locationId??"",
            provinceSelected?.provinceId??"",
            pointTypeSelected == _allMale?"": (pointTypeSelected??""),
          );
          final pointsAsyncValue = ref.watch(pointsByLocationStreamProvider(pointFilter));
          casesAsyncValue = ref.watch(casesFullStreamProvider);

          if (countriesAsyncValue.value != null) {
            _saveCountries(countriesAsyncValue);
          }

          if (regionsAsyncValue.value != null) {
            _saveRegions(regionsAsyncValue);
          }

          if (locationsAsyncValue.value != null) {
            _saveLocations(locationsAsyncValue);
          }

          if (provincesAsyncValue.value != null) {
            _saveProvinces(provincesAsyncValue);
          }

          if (pointsAsyncValue.value != null) {
            _savePoints(pointsAsyncValue);
          }

          if (countriesAsyncValue.value != null
              && regionsAsyncValue.value != null
              && locationsAsyncValue.value != null
              && provincesAsyncValue.value != null
              && pointsAsyncValue.value != null
              && casesAsyncValue.value != null
          ) {
            _saveMainInforms(casesAsyncValue);
          }

          return _buildView(casesAsyncValue);
        });

  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.start,
        runSpacing: 20.0,
        spacing: 20.0,
        children: [
          _buildCountryPicker(),
          _buildRegionPicker(),
          _buildLocationPicker(),
          _buildProvincePicker(),
          _buildPointTypePicker(),
          _buildPointPicker(),
          SizedBox(
            width: 400,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: SfDateRangePicker(
                initialSelectedRange: PickerDateRange(
                  DateTime.fromMillisecondsSinceEpoch(start),
                  DateTime.fromMillisecondsSinceEpoch(end),),
                onSelectionChanged: _onSelectionChanged,
                selectionMode: DateRangePickerSelectionMode.range,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (args.value is PickerDateRange) {
      final PickerDateRange range = args.value;
      final DateTime? startDate = range.startDate;
      final DateTime? endDate = range.endDate?.copyWith(hour: 23, minute: 59, second: 59);

      start = startDate!.millisecondsSinceEpoch;
      if (endDate != null && endDate.millisecondsSinceEpoch > startDate.millisecondsSinceEpoch){
        end = endDate.millisecondsSinceEpoch;
        setState(() {
          _buildLayoutBuilder();
        });
      }
    }
  }

  Widget _buildCountryPicker() {
    switch (model.locale.toString()) {
      case 'es_ES':
        _selectCountry = 'Selecciona un país';
        break;
      case 'fr_FR':
        _selectCountry = 'Sélectionnez un pays';
        break;
      default:
        _selectCountry = 'Select country';
        break;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3.0),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
        child: SizedBox(
          height: 50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              DropdownButton<String>(
                  focusColor: Colors.transparent,
                  underline:
                  Container(color: const Color(0xFFBDBDBD), height: 1),
                  value: countrySelected?.name,
                  hint: Text(_selectCountry),
                  items: countries.map((Country c) {
                    return DropdownMenuItem<String>(
                        value: c.name,
                        child: Text(c.name,
                            style: TextStyle(color: model.textColor)));
                  }).toList(),
                  onChanged: (dynamic value) {
                    setState(() {
                      countrySelected = countries.firstWhere((c) => c.name == value);
                      regionSelected = null;
                      locationSelected = null;
                      provinceSelected = null;
                    });
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegionPicker() {
    switch (model.locale.toString()) {
      case 'es_ES':
        _selectRegion = 'Selecciona una región';
        break;
      case 'fr_FR':
        _selectRegion = 'Sélectionnez une région';
        break;
      default:
        _selectRegion = 'Select region';
        break;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3.0),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
        child: SizedBox(
          height: 50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              DropdownButton<String>(
                  focusColor: Colors.transparent,
                  underline:
                  Container(color: const Color(0xFFBDBDBD), height: 1),
                  value: regionSelected?.name,
                  hint: Text(_selectRegion),
                  items: regions.map((Region r) {
                    return DropdownMenuItem<String>(
                        value: r.name,
                        child: Text(r.name,
                            style: TextStyle(color: model.textColor)));
                  }).toList(),
                  onChanged: (dynamic value) {
                    setState(() {
                      regionSelected = regions.firstWhere((r) => r.name == value);
                      locationSelected = null;
                      provinceSelected = null;
                    });
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationPicker() {
    switch (model.locale.toString()) {
      case 'es_ES':
        _selectLocation = 'Selecciona una provincia';
        break;
      case 'fr_FR':
        _selectLocation = 'Sélectionnez une province';
        break;
      default:
        _selectLocation = 'Select province';
        break;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3.0),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
        child: SizedBox(
          height: 50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              DropdownButton<String>(
                  focusColor: Colors.transparent,
                  underline:
                  Container(color: const Color(0xFFBDBDBD), height: 1),
                  value: locationSelected?.name,
                  hint: Text(_selectLocation),
                  items: locations.map((Location l) {
                    return DropdownMenuItem<String>(
                        value: l.name,
                        child: Text(l.name,
                            style: TextStyle(color: model.textColor)));
                  }).toList(),
                  onChanged: (dynamic value) {
                    setState(() {
                      locationSelected = locations.firstWhere((l) => l.name == value);
                      provinceSelected = null;
                    });
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProvincePicker() {
    switch (model.locale.toString()) {
      case 'es_ES':
        _selectProvince = 'Selecciona un municipio';
        break;
      case 'fr_FR':
        _selectProvince = 'Sélectionnez une municipalité';
        break;
      default:
        _selectProvince = 'Select municipality';
        break;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3.0),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
        child: SizedBox(
          height: 50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              DropdownButton<String>(
                  focusColor: Colors.transparent,
                  underline:
                  Container(color: const Color(0xFFBDBDBD), height: 1),
                  value: provinceSelected?.name,
                  hint: Text(_selectProvince),
                  items: provinces.map((Province p) {
                    return DropdownMenuItem<String>(
                        value: p.name,
                        child: Text(p.name,
                            style: TextStyle(color: model.textColor)));
                  }).toList(),
                  onChanged: (dynamic value) {
                    setState(() {
                      provinceSelected = provinces.firstWhere((p) => p.name == value);
                    });
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPointTypePicker() {
    switch (model.locale.toString()) {
      case 'es_ES':
        _selectPointType = 'Selecciona un tipo de centro';
        break;
      case 'fr_FR':
        _selectPointType = 'Sélectionnez un type de centre';
        break;
      default:
        _selectPointType = 'Select type of centre';
        break;
    }

    return Column(children: <Widget>[
      Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3.0),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
          child: SizedBox(
            height: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                DropdownButton<String>(
                    focusColor: Colors.transparent,
                    underline:
                    Container(color: const Color(0xFFBDBDBD), height: 1),
                    value: pointTypeSelected,
                    hint: Text(_selectPointType),
                    items: pointTypes.map((String p) {
                      return DropdownMenuItem<String>(
                          value: p,
                          child: Text(p,
                              style: TextStyle(color: model.textColor)));
                    }).toList(),
                    onChanged: (dynamic value) {
                      setState(() {
                        pointTypeSelected = value;
                      });
                    }),
              ],
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _buildPointPicker() {
    switch (model.locale.toString()) {
      case 'es_ES':
        _selectPoint = 'Selecciona centro/s';
        break;
      case 'fr_FR':
        _selectPoint = 'Sélectionnez le(s) centre(s)';
        break;
      default:
        _selectPoint = 'Select center/s';
        break;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3.0),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
        child: SizedBox(
          height: 50.0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PopupMenuButton<Point>(
                //offset: const Offset(0, -380),
                itemBuilder: (context) => points.map((p) => PopupMenuItem<Point>(
                    value: p,
                    child: StatefulBuilder(
                        builder: (context, setStateSB) {
                          return CheckboxMenuButton(
                            value: p.isSelected,
                            onChanged: (bool? value) {
                              setStateSB(() {
                                p.isSelected = value?? false;
                                _refreshPointsSelected();
                              });
                              setState(() {

                              });
                            },
                            child: Text(p.name, style: TextStyle(color: model.textColor)),
                          );
                        }
                    ))).toList(),
                child: Container(
                  padding: const EdgeInsets.only(bottom: 5,),
                  decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(
                        color: Colors.grey,
                        width: 1.0, // Underline thickness
                      ))
                  ),
                  child: Row(
                    children: [
                      Text(
                          _selectPoint,
                          style: TextStyle(
                            color: model.textColor,
                            fontSize: 14.0,
                          )
                      ),
                      const SizedBox(width: 4.0,),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20.0,),
              CheckboxMenuButton(
                value: !points.any((p) => !p.isSelected),
                onChanged: (bool? value) {
                  setState(() {
                    if (value??false) {
                      _selectAllPoints();
                    } else {
                      _unselectAllPoints();
                    }
                    _refreshPointsSelected();
                  });
                },
                child: Text(_allMale, style: TextStyle(color: model.textColor)),
              )
            ],
          ),
        ),
      ),
    );
  }

  _selectAllPoints(){
    for (var element in points) {element.isSelected = true;}
  }

  _unselectAllPoints(){
    for (var element in points) {element.isSelected = false;}
  }

  _refreshPointsSelected() {
    pointsSelected = points.where((element) => element.isSelected).toList();
  }
}



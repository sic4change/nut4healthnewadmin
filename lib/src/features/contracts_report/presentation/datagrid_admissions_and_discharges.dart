/// Package imports
/// import 'package:flutter/foundation.dart';

import 'package:adminnut4health/src/common_widgets/custom_datagrid_to_excel_converter.dart';
import 'package:adminnut4health/src/common_widgets/custom_datagrid_to_pdf_converter.dart';
import 'package:adminnut4health/src/features/cases/domain/case.dart';
import 'package:adminnut4health/src/features/contracts_report/domain/admissions_and_discharges_inform.dart';
import 'package:adminnut4health/src/features/contracts_report/domain/case_full.dart';
import 'package:adminnut4health/src/features/contracts_report/presentation/admissions_and_discharges_datagridsource.dart';
import 'package:adminnut4health/src/features/countries/domain/country.dart';
import 'package:adminnut4health/src/features/locations/domain/location.dart';
import 'package:adminnut4health/src/features/points/domain/point.dart';
import 'package:adminnut4health/src/features/provinces/domain/province.dart';
import 'package:dartz/dartz.dart';
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
class AdmissionsAndDischargesDataGrid extends LocalizationSampleView {
  /// Creates getting started data grid
  const AdmissionsAndDischargesDataGrid({Key? key}) : super(key: key);

  @override
  _AdmissionsAndDischargesDataGridState createState() => _AdmissionsAndDischargesDataGridState();
}

class _AdmissionsAndDischargesDataGridState extends LocalizationSampleViewState {

  final GlobalKey<SfDataGridState> _key = GlobalKey<SfDataGridState>();

  /// DataGridSource required for SfDataGrid to obtain the row data.
  late AdmissionsAndDischargesDataGridSource mainInformDataGridSource;

  static const double dataPagerHeight = 60;
  int _rowsPerPage = 15;

  /// Selected locale
  late String selectedLocale;


  int start = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).millisecondsSinceEpoch;

  int end = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59).millisecondsSinceEpoch;


  /// Translate names
  late String _category, _patientsAtBeginning, _newAdmissions, _reAdmissions,
      _relapses, _referredIn, _transferedIn, _totalAdmissions, _totalAttended,
      _recovered, _unresponsive, _deaths, _abandonment, _referredOut, _transferedOut,
      _totalDischarges, _totalAtTheEnd, _start, _end, _exportXLS, _exportPDF,
      _total, _contracts, _selectCountry, _selectRegion, _selectLocation,
      _selectProvince, _selectPointType, _selectPoint, _allMale, _allFemale,
      _admissions, _discharges;

  late Map<String, double> columnWidths = {
    'Categoría': 200,
    'Pacientes al inicio': 200,
    'Nuevos casos': 200,
    'Readmisiones': 200,
    'Recaídas': 200,
    'Referidos (Admisión)': 200,
    'Transferidos (Admisión)': 200,
    'TOTAL ADMISIONES': 200,
    'TOTAL ATENDIDOS/AS': 200,
    'Recuperados': 200,
    'Sin respuesta': 200,
    'Fallecimientos': 200,
    'Abandonos': 200,
    'Referidos (Alta)': 200,
    'Transferidos (Alta)': 200,
    'TOTAL ALTAS': 200,
    'TOTAL AL FINAL': 200,
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

  _saveCountries(AsyncValue<List<Country>>? countries) {
    if (countries == null) {
      return;
    } else {
      this.countries.clear();
      this.countries.add(Country(countryId: "", name: _allMale, code: "",
          active: false, needValidation: false, cases: 0, casesnormopeso: 0,
          casesmoderada: 0, casessevera: 0));
      this.countries.addAll(countries.value!);
    }
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

    List<AdmissionsAndDischargesInform> informs = [];
    late String boy, girl, subtotalChildren, fefa, total;

    total = "Total";
    switch (selectedLocale) {
      case 'en_US':
        boy = 'Boys <5 years';
        girl = 'Girls <5 years';
        subtotalChildren = 'Subtotal children <5 years';
        fefa = 'Pregnant and lactating women';
        break;
      case 'es_ES':
        boy = 'Niños <5 años';
        girl = 'Niñas <5 años';
        subtotalChildren = 'Subtotal niñas/os <5 años';
        fefa = 'Mujeres embarazadas y lactantes';
        break;
      case 'fr_FR':
        boy = 'Garcons <5 años';
        girl = 'Filles <5 años';
        subtotalChildren = 'Sous-total filles et garçons <5 ans';
        fefa = 'FEFA';
        break;
    }

    informs.add(AdmissionsAndDischargesInform(
      category: boy,
      patientsAtBeginning: 0,
      newAdmissions: 0,
      reAdmissions: 0,
      relapses: 0,
      referredIn: 0,
      transferedIn: 0,
      recovered: 0,
      unresponsive: 0,
      deaths: 0,
      abandonment: 0,
      referredOut: 0,
      transferedOut: 0,
    ));

    informs.add(AdmissionsAndDischargesInform(
      category: girl,
      patientsAtBeginning: 0,
      newAdmissions: 0,
      reAdmissions: 0,
      relapses: 0,
      referredIn: 0,
      transferedIn: 0,
      recovered: 0,
      unresponsive: 0,
      deaths: 0,
      abandonment: 0,
      referredOut: 0,
      transferedOut: 0,
    ));

    informs.add(AdmissionsAndDischargesInform(
      category: subtotalChildren,
      patientsAtBeginning: 0,
      newAdmissions: 0,
      reAdmissions: 0,
      relapses: 0,
      referredIn: 0,
      transferedIn: 0,
      recovered: 0,
      unresponsive: 0,
      deaths: 0,
      abandonment: 0,
      referredOut: 0,
      transferedOut: 0,
    ));

    informs.add(AdmissionsAndDischargesInform(
      category: fefa,
      patientsAtBeginning: 0,
      newAdmissions: 0,
      reAdmissions: 0,
      relapses: 0,
      referredIn: 0,
      transferedIn: 0,
      recovered: 0,
      unresponsive: 0,
      deaths: 0,
      abandonment: 0,
      referredOut: 0,
      transferedOut: 0,
    ));

    informs.add(AdmissionsAndDischargesInform(
      category: total,
      patientsAtBeginning: 0,
      newAdmissions: 0,
      reAdmissions: 0,
      relapses: 0,
      referredIn: 0,
      transferedIn: 0,
      recovered: 0,
      unresponsive: 0,
      deaths: 0,
      abandonment: 0,
      referredOut: 0,
      transferedOut: 0,
    ));

    if (filteredCases.isNotEmpty) {

      // PATIENTS AT BEGINNING
      final openCasesBeforeStartDate = filteredCases.where((caseFull) =>
        caseFull.myCase.createDate.isBefore(DateTime.fromMillisecondsSinceEpoch(start)) &&
        // Y que no estén cerrados, o que estén cerrados DESPUÉS de la fecha de inicio del filtro
        ((caseFull.myCase.closedReason.isEmpty || caseFull.myCase.closedReason == "null") || caseFull.getClosedDate().isAfter(DateTime.fromMillisecondsSinceEpoch(start)))
      );
      for (var element in openCasesBeforeStartDate) {
        if (element.child == null || element.child!.childId == '') {
          informs[3].patientsAtBeginning++;
        } else {
          if (element.child?.sex == "Masculino" ||
              element.child?.sex == "Homme" ||
              element.child?.sex == "ذكر") {
            informs[0].patientsAtBeginning++;
          } else {
            informs[1].patientsAtBeginning++;
          }
        }
      }

      // ADMISSIONS
      final newCasesByDate = filteredCases.where((myCase) =>
          myCase.myCase.createDate.isAfter(DateTime.fromMillisecondsSinceEpoch(start)) &&
          myCase.myCase.createDate.isBefore(DateTime.fromMillisecondsSinceEpoch(end)));
      for (var element in newCasesByDate) {
        // Nuevos casos
        if (element.myCase.admissionTypeServer == CaseType.newAdmission ||
            element.myCase.admissionTypeServer.isEmpty) {
          if (element.child == null || element.child!.childId == '') {
            informs[3].newAdmissions++;
          } else {
            if (element.child?.sex == "Masculino" ||
                element.child?.sex == "Homme" ||
                element.child?.sex == "ذكر") {
              informs[0].newAdmissions++;
            } else {
              informs[1].newAdmissions++;
            }
          }
        }

        // Readmisiones
        if (element.myCase.admissionTypeServer == CaseType.reAdmission) {
          if (element.child == null || element.child!.childId == '') {
            informs[3].reAdmissions++;
          } else {
            if (element.child?.sex == "Masculino" ||
                element.child?.sex == "Homme" ||
                element.child?.sex == "ذكر") {
              informs[0].reAdmissions++;
            } else {
              informs[1].reAdmissions++;
            }
          }
        }

        // Recaídas
        if (element.myCase.admissionTypeServer == CaseType.relapse) {
          if (element.child == null || element.child!.childId == '') {
            informs[3].relapses++;
          } else {
            if (element.child?.sex == "Masculino" ||
                element.child?.sex == "Homme" ||
                element.child?.sex == "ذكر") {
              informs[0].relapses++;
            } else {
              informs[1].relapses++;
            }
          }
        }

        // Referidos
        if (element.myCase.admissionTypeServer == CaseType.referred) {
          if (element.child == null || element.child!.childId == '') {
            informs[3].referredIn++;
          } else {
            if (element.child?.sex == "Masculino" ||
                element.child?.sex == "Homme" ||
                element.child?.sex == "ذكر") {
              informs[0].referredIn++;
            } else {
              informs[1].referredIn++;
            }
          }
        }

        // Transferidos
        if (element.myCase.admissionTypeServer == CaseType.transfered) {
          if (element.child == null || element.child!.childId == '') {
            informs[3].transferedIn++;
          } else {
            if (element.child?.sex == "Masculino" ||
                element.child?.sex == "Homme" ||
                element.child?.sex == "ذكر") {
              informs[0].transferedIn++;
            } else {
              informs[1].transferedIn++;
            }
          }
        }
      }

      // DISCHARGES
      final closedCasesByDate = filteredCases.where((caseFull) =>
          caseFull.getClosedDate().isAfter(DateTime.fromMillisecondsSinceEpoch(start)) &&
          caseFull.getClosedDate().isBefore(DateTime.fromMillisecondsSinceEpoch(end)) &&
          caseFull.myCase.closedReason != "null" && caseFull.myCase.closedReason.isNotEmpty);
      for (var element in closedCasesByDate) {
        // Recuperados
        if (element.myCase.closedReason == CaseType.recovered) {
          if (element.child == null || element.child!.childId == '') {
            informs[3].recovered++;
          } else {
            if (element.child?.sex == "Masculino" ||
                element.child?.sex == "Homme" ||
                element.child?.sex == "ذكر") {
              informs[0].recovered++;
            } else {
              informs[1].recovered++;
            }
          }
        }

        // Sin respuesta
        if (element.myCase.closedReason == CaseType.unresponsive) {
          if (element.child == null || element.child!.childId == '') {
            informs[3].unresponsive++;
          } else {
            if (element.child?.sex == "Masculino" ||
                element.child?.sex == "Homme" ||
                element.child?.sex == "ذكر") {
              informs[0].unresponsive++;
            } else {
              informs[1].unresponsive++;
            }
          }
        }

        // Fallecimientos
        if (element.myCase.closedReason == CaseType.death) {
          if (element.child == null || element.child!.childId == '') {
            informs[3].deaths++;
          } else {
            if (element.child?.sex == "Masculino" ||
                element.child?.sex == "Homme" ||
                element.child?.sex == "ذكر") {
              informs[0].deaths++;
            } else {
              informs[1].deaths++;
            }
          }
        }

        // Abandono
        if (element.myCase.closedReason == CaseType.abandonment) {
          if (element.child == null || element.child!.childId == '') {
            informs[3].abandonment++;
          } else {
            if (element.child?.sex == "Masculino" ||
                element.child?.sex == "Homme" ||
                element.child?.sex == "ذكر") {
              informs[0].abandonment++;
            } else {
              informs[1].abandonment++;
            }
          }
        }

        // Referidos
        if (element.myCase.closedReason == CaseType.referred) {
          if (element.child == null || element.child!.childId == '') {
            informs[3].referredOut++;
          } else {
            if (element.child?.sex == "Masculino" ||
                element.child?.sex == "Homme" ||
                element.child?.sex == "ذكر") {
              informs[0].referredOut++;
            } else {
              informs[1].referredOut++;
            }
          }
        }

        // Abandono
        if (element.myCase.closedReason == CaseType.transfered) {
          if (element.child == null || element.child!.childId == '') {
            informs[3].transferedOut++;
          } else {
            if (element.child?.sex == "Masculino" ||
                element.child?.sex == "Homme" ||
                element.child?.sex == "ذكر") {
              informs[0].transferedOut++;
            } else {
              informs[1].transferedOut++;
            }
          }
        }
      }
    }

    // Subtotal children
    informs[2].patientsAtBeginning = informs[0].patientsAtBeginning + informs[1].patientsAtBeginning;
    informs[2].newAdmissions = informs[0].newAdmissions + informs[1].newAdmissions;
    informs[2].reAdmissions = informs[0].reAdmissions + informs[1].reAdmissions;
    informs[2].relapses = informs[0].relapses + informs[1].relapses;
    informs[2].referredIn = informs[0].referredIn + informs[1].referredIn;
    informs[2].transferedIn = informs[0].transferedIn + informs[1].transferedIn;
    informs[2].recovered = informs[0].recovered + informs[1].recovered;
    informs[2].unresponsive = informs[0].unresponsive + informs[1].unresponsive;
    informs[2].deaths = informs[0].deaths + informs[1].deaths;
    informs[2].abandonment = informs[0].abandonment + informs[1].abandonment;
    informs[2].referredOut = informs[0].referredOut + informs[1].referredOut;
    informs[2].transferedOut = informs[0].transferedOut + informs[1].transferedOut;

    // Total
    informs[4].patientsAtBeginning = informs[2].patientsAtBeginning + informs[3].patientsAtBeginning;
    informs[4].newAdmissions = informs[2].newAdmissions + informs[3].newAdmissions;
    informs[4].reAdmissions = informs[2].reAdmissions + informs[3].reAdmissions;
    informs[4].relapses = informs[2].relapses + informs[3].relapses;
    informs[4].referredIn = informs[2].referredIn + informs[3].referredIn;
    informs[4].transferedIn = informs[2].transferedIn + informs[3].transferedIn;
    informs[4].recovered = informs[2].recovered + informs[3].recovered;
    informs[4].unresponsive = informs[2].unresponsive + informs[3].unresponsive;
    informs[4].deaths = informs[2].deaths + informs[3].deaths;
    informs[4].abandonment = informs[2].abandonment + informs[3].abandonment;
    informs[4].referredOut = informs[2].referredOut + informs[3].referredOut;
    informs[4].transferedOut = informs[2].transferedOut + informs[3].transferedOut;

    mainInformDataGridSource.setMainInforms(informs);

    mainInformDataGridSource.buildDataGridRows(/*enableFiltering: true, showByWomenOrigin: true*/);
    mainInformDataGridSource.updateDataSource();
  }

  Widget _buildView(AsyncValue<List<CaseFull>> cases) {
    if (cases.value != null) {
      mainInformDataGridSource.buildDataGridRows();
      mainInformDataGridSource.updateDataSource();
      selectedLocale = model.locale.toString();
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
      final Workbook workbook = _key.currentState!.exportToExcelWorkbook(
          converter: CustomDataGridToExcelConverter(),
          cellExport: (DataGridCellExcelExportDetails details) {
          });
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();
      await helper.FileSaveHelper.saveAndLaunchFile(bytes, '$_contracts.xlsx');
    }

    Future<void> exportDataGridToPdf() async {
      final ByteData data = await rootBundle.load('images/nut_logo.jpg');
      final PdfDocument document = _key.currentState!.exportToPdfDocument(
          converter: CustomDataGridToPdfConverter(),
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

  List<GridTableSummaryRow> _getTableSummaryRows() {
    final Color color =
    model.themeData.colorScheme.brightness == Brightness.light
        ? const Color(0xFFEBEBEB)
        : const Color(0xFF3B3B3B);
    return <GridTableSummaryRow>[
      GridTableSummaryRow(
        showSummaryInRow: true,
          color: color,
          title: '$_total: {Count}',
          columns: <GridSummaryColumn>[
            const GridSummaryColumn(
                name: 'Count',
                columnName: 'Categoría',
                summaryType: GridSummaryType.count),
          ],
          position: GridTableSummaryRowPosition.bottom),
    ];
  }

  SfDataGrid _buildDataGrid() {
    return SfDataGrid(
      frozenColumnsCount: 1,
      key: _key,
      source: mainInformDataGridSource,
      rowsPerPage: _rowsPerPage,
      //tableSummaryRows: _getTableSummaryRows(),
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
      allowSorting: true,
      allowMultiColumnSorting: true,
      columns: <GridColumn>[
        GridColumn(
            columnName: 'Categoría',
            width: columnWidths['Categoría']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _category,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Pacientes al inicio',
            width: columnWidths['Pacientes al inicio']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _patientsAtBeginning,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Nuevos casos',
            width: columnWidths['Nuevos casos']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _newAdmissions,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Readmisiones',
            width: columnWidths['Readmisiones']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _reAdmissions,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Recaídas',
            width: columnWidths['Recaídas']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _relapses,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Referidos (Admisión)',
            width: columnWidths['Referidos (Admisión)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _referredIn,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Transferidos (Admisión)',
            width: columnWidths['Transferidos (Admisión)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _transferedIn,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'TOTAL ADMISIONES',
            width: columnWidths['TOTAL ADMISIONES']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _totalAdmissions,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'TOTAL ATENDIDOS/AS',
            width: columnWidths['TOTAL ATENDIDOS/AS']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _totalAttended,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Recuperados',
            width: columnWidths['Recuperados']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _recovered,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Sin respuesta',
            width: columnWidths['Sin respuesta']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _unresponsive,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Fallecimientos',
            width: columnWidths['Fallecimientos']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _deaths,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Abandonos',
            width: columnWidths['Abandonos']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _abandonment,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Referidos (Alta)',
            width: columnWidths['Referidos (Alta)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _referredOut,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Transferidos (Alta)',
            width: columnWidths['Transferidos (Alta)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _transferedOut,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'TOTAL ALTAS',
            width: columnWidths['TOTAL ALTAS']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _totalDischarges,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'TOTAL AL FINAL',
            width: columnWidths['TOTAL AL FINAL']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _totalAtTheEnd,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
      ],
      stackedHeaderRows: <StackedHeaderRow>[
        StackedHeaderRow(cells: [
          StackedHeaderCell(
              text: _admissions,
              columnNames: ['Nuevos casos', 'Readmisiones', 'Referidos (Admisión)', 'Recaídas', 'Transferidos (Admisión)', 'TOTAL ADMISIONES'],
              child: Center(child: Text(_admissions, style: const TextStyle(fontWeight: FontWeight.bold),))),
          StackedHeaderCell(
              text: _discharges,
              columnNames: ['Recuperados', 'Sin respuesta', 'Fallecimientos', 'Abandonos', 'Referidos (Alta)', 'Transferidos (Alta)', 'TOTAL ALTAS'],
              child: Center(child: Text(_discharges, style: const TextStyle(fontWeight: FontWeight.bold),))),
        ]),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    mainInformDataGridSource = AdmissionsAndDischargesDataGridSource(List.empty());

    selectedLocale = model.locale.toString();
    switch (selectedLocale) {
      case 'en_US':
        _category = 'Category';
        _patientsAtBeginning = 'Patients at beginning';
        _newAdmissions = 'New admissions';
        _reAdmissions = 'Readmissions';
        _relapses = 'Relapses';
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
        break;
      case 'es_ES':
        _category = 'Categoría';
        _patientsAtBeginning = 'Pacientes al inicio';
        _newAdmissions = 'Nuevos casos';
        _reAdmissions = 'Readmisiones';
        _relapses = 'Recaídas';
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
        break;
      case 'fr_FR':
        _category = 'Catégorie';
        _patientsAtBeginning = 'Patients au début';
        _newAdmissions = 'Nouvelles admissions';
        _reAdmissions = 'Réadmissions';
        _relapses = 'Rechutes';
        _referredIn = 'Références (Admission)';
        _transferedIn = 'Transféré (Admission)';
        _totalAdmissions = 'TOTAL ADMISSIONS';
        _totalAttended = 'Total pris en charge au cours du mois';
        _recovered = 'GUERIS';
        _unresponsive = 'Non-répondant';
        _deaths = 'Décès';
        _abandonment = 'Abandon';
        _referredOut = 'Références (Sortie)';
        _transferedOut = 'Transféré (Sortie)';
        _totalDischarges = 'TOTAL SORTIES';
        _totalAtTheEnd = 'TOTAL À LA FIN DE MOIS';
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
          if (countriesAsyncValue.value != null) {
            _saveCountries(countriesAsyncValue);
          }

          final regionsAsyncValue = ref.watch(regionsByCountryStreamProvider(countrySelected?.countryId??""));
          if (regionsAsyncValue.value != null) {
            _saveRegions(regionsAsyncValue);
          }

          final locationFilter = Tuple2(countrySelected?.countryId??"", regionSelected?.regionId??"");
          final locationsAsyncValue = ref.watch(locationsByCountryAndRegionStreamProvider(locationFilter));
          if (locationsAsyncValue.value != null) {
            _saveLocations(locationsAsyncValue);
          }

          final provinceFilter = Tuple3(
            countrySelected?.countryId??"",
            regionSelected?.regionId??"",
            locationSelected?.locationId??"",
          );
          final provincesAsyncValue = ref.watch(provincesByLocationStreamProvider(provinceFilter));
          if (provincesAsyncValue.value != null) {
            _saveProvinces(provincesAsyncValue);
          }

          final pointFilter = Tuple5(
              countrySelected?.countryId??"",
              regionSelected?.regionId??"",
              locationSelected?.locationId??"",
              provinceSelected?.provinceId??"",
              pointTypeSelected == _allMale?"": (pointTypeSelected??""),
          );
          final pointsAsyncValue = ref.watch(pointsByLocationStreamProvider(pointFilter));
          if (pointsAsyncValue.value != null) {
            _savePoints(pointsAsyncValue);
          }

          casesAsyncValue = ref.watch(casesFullStreamProvider);

          if (casesAsyncValue.value != null) {
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



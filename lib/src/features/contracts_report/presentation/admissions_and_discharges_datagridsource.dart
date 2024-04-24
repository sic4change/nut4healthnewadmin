import 'package:adminnut4health/src/features/cases/domain/case.dart';
import 'package:adminnut4health/src/features/contracts_report/domain/admissions_and_discharges_inform.dart';
import 'package:adminnut4health/src/features/contracts_report/domain/case_full.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../domain/PointWithVisitAndChild.dart';


class AdmissionsAndDischargesDataGridSource extends DataGridSource {
  AdmissionsAndDischargesDataGridSource(List<AdmissionsAndDischargesInform> informData) {
    _mainInforms = informData;
    buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = <DataGridRow>[];
  List<AdmissionsAndDischargesInform>? _mainInforms = <AdmissionsAndDischargesInform>[];

  /// Building DataGridRows
  void buildDataGridRows() {
    if (_mainInforms != null && _mainInforms!.isNotEmpty) {

      _dataGridRows = _mainInforms!.map<DataGridRow>((AdmissionsAndDischargesInform mainInform) {

        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<String>(columnName: 'Categoría', value: mainInform.category),
          DataGridCell<int>(columnName: 'Pacientes al inicio', value: mainInform.patientsAtBeginning),
          DataGridCell<int>(columnName: 'Nuevos casos', value: mainInform.newAdmissions),
          DataGridCell<int>(columnName: 'Readmisiones', value: mainInform.reAdmissions),
          DataGridCell<int>(columnName: 'Recaídas', value: mainInform.relapses),
          DataGridCell<int>(columnName: 'Referidos (Admisión)', value: mainInform.referredIn),
          DataGridCell<int>(columnName: 'Transferidos (Admisión)', value: mainInform.transferedIn),
          DataGridCell<int>(columnName: 'TOTAL ADMISIONES', value: mainInform.totalAdmissions()),
          DataGridCell<int>(columnName: 'TOTAL ATENDIDOS/AS', value: mainInform.totalAttended()),
          DataGridCell<int>(columnName: 'Recuperados', value: mainInform.recovered),
          DataGridCell<int>(columnName: 'Sin respuesta', value: mainInform.unresponsive),
          DataGridCell<int>(columnName: 'Abandono', value: mainInform.abandonment),
          DataGridCell<int>(columnName: 'Referidos (Alta)', value: mainInform.referredOut),
          DataGridCell<int>(columnName: 'Transferidos (Alta)', value: mainInform.transferedOut),
          DataGridCell<int>(columnName: 'TOTAL ALTAS', value: mainInform.totalDischarges()),
          DataGridCell<int>(columnName: 'TOTAL AL FINAL', value: mainInform.totalAtTheEnd()),
        ]);
      }).toList();
    }
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final rowColor = row.getCells()[0].value.toString().contains("Total")? Colors.grey.withOpacity(0.3):
        row.getCells()[0].value.toString().contains("Subtotal")? Colors.grey.withOpacity(0.15): Colors.white;
    final textStyle = row.getCells()[0].value.toString().contains("Total")? const TextStyle(fontWeight: FontWeight.bold):
    row.getCells()[0].value.toString().contains("Subtotal")? const TextStyle(fontWeight: FontWeight.w600): const TextStyle();
    
    return DataGridRowAdapter(
        cells: row.getCells().map((c) =>
            _buildStandardContainer(c.value.toString(), textStyle)
        ).toList(),
        color: rowColor
    );
  }

  // Overrides
  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  Widget? buildTableSummaryCellWidget(
      GridTableSummaryRow summaryRow,
      GridSummaryColumn? summaryColumn,
      RowColumnIndex rowColumnIndex,
      String summaryValue) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      child: Text(summaryValue),
    );
  }

  Widget _buildStandardContainer(String value, TextStyle textStyle) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.centerLeft,
      child: Text(value, style: textStyle),
    );
  }

  setMainInforms(List<CaseFull>? cases, String selectedLocale, int start, int end) {
    List<AdmissionsAndDischargesInform> inform = [];
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

    inform.add(
        AdmissionsAndDischargesInform(
          category: boy,
          patientsAtBeginning: 0,
          newAdmissions: 0,
          reAdmissions: 0,
          relapses: 0,
          referredIn: 0,
          transferedIn: 0,
          recovered: 0,
          unresponsive: 0,
          abandonment: 0,
          referredOut: 0,
          transferedOut: 0,
        )
    );
    inform.add(
        AdmissionsAndDischargesInform(
          category: girl,
          patientsAtBeginning: 0,
          newAdmissions: 0,
          reAdmissions: 0,
          relapses: 0,
          referredIn: 0,
          transferedIn: 0,
          recovered: 0,
          unresponsive: 0,
          abandonment: 0,
          referredOut: 0,
          transferedOut: 0,
        )
    );
    inform.add(
        AdmissionsAndDischargesInform(
          category: subtotalChildren,
          patientsAtBeginning: 0,
          newAdmissions: 0,
          reAdmissions: 0,
          relapses: 0,
          referredIn: 0,
          transferedIn: 0,
          recovered: 0,
          unresponsive: 0,
          abandonment: 0,
          referredOut: 0,
          transferedOut: 0,
        )
    );
    inform.add(
        AdmissionsAndDischargesInform(
          category: fefa,
          patientsAtBeginning: 0,
          newAdmissions: 0,
          reAdmissions: 0,
          relapses: 0,
          referredIn: 0,
          transferedIn: 0,
          recovered: 0,
          unresponsive: 0,
          abandonment: 0,
          referredOut: 0,
          transferedOut: 0,
        )
    );
    inform.add(
        AdmissionsAndDischargesInform(
          category: total,
          patientsAtBeginning: 0,
          newAdmissions: 0,
          reAdmissions: 0,
          relapses: 0,
          referredIn: 0,
          transferedIn: 0,
          recovered: 0,
          unresponsive: 0,
          abandonment: 0,
          referredOut: 0,
          transferedOut: 0,
        )
    );

    if (cases != null) {
      // PATIENTS AT BEGINNING
      final openCasesBeforeStartDate = cases.where((caseFull) =>
          caseFull.myCase.createDate.isBefore(DateTime.fromMillisecondsSinceEpoch(start))
          && caseFull.myCase.closedReason.isEmpty);
      for (var element in openCasesBeforeStartDate) {
        if (element.child == null || element.child!.childId == '') {
          inform[3].patientsAtBeginning++;
        } else {
          if (element.child?.sex == "Masculino" ||
              element.child?.sex == "Homme" ||
              element.child?.sex == "ذكر") {
            inform[0].patientsAtBeginning++;
          } else {
            inform[1].patientsAtBeginning++;
          }
        }
      }

      // ADMISSIONS
      final newCasesByDate = cases.where((myCase) =>
          myCase.myCase.createDate.isAfter(DateTime.fromMillisecondsSinceEpoch(start))
          && myCase.myCase.createDate.isBefore(DateTime.fromMillisecondsSinceEpoch(end)));
      for (var element in newCasesByDate) {
        // Nuevos casos
        if (element.myCase.admissionTypeServer == CaseType.newAdmission || element.myCase.admissionTypeServer.isEmpty) {
          if (element.child == null || element.child!.childId == '') {
            inform[3].newAdmissions++;
          } else {
            if (element.child?.sex == "Masculino" ||
                element.child?.sex == "Homme" ||
                element.child?.sex == "ذكر") {
              inform[0].newAdmissions++;
            } else {
              inform[1].newAdmissions++;
            }
          }
        }

        // Readmisiones
        if (element.myCase.admissionTypeServer == CaseType.reAdmission) {
          if (element.child == null || element.child!.childId == '') {
            inform[3].reAdmissions++;
          } else {
            if (element.child?.sex == "Masculino" ||
                element.child?.sex == "Homme" ||
                element.child?.sex == "ذكر") {
              inform[0].reAdmissions++;
            } else {
              inform[1].reAdmissions++;
            }
          }
        }

        // Recaídas
        if (element.myCase.admissionTypeServer == CaseType.relapse) {
          if (element.child == null || element.child!.childId == '') {
            inform[3].relapses++;
          } else {
            if (element.child?.sex == "Masculino" ||
                element.child?.sex == "Homme" ||
                element.child?.sex == "ذكر") {
              inform[0].relapses++;
            } else {
              inform[1].relapses++;
            }
          }
        }

        // Referidos
        if (element.myCase.admissionTypeServer == CaseType.referred) {
          if (element.child == null || element.child!.childId == '') {
            inform[3].referredIn++;
          } else {
            if (element.child?.sex == "Masculino" ||
                element.child?.sex == "Homme" ||
                element.child?.sex == "ذكر") {
              inform[0].referredIn++;
            } else {
              inform[1].referredIn++;
            }
          }
        }

        // Transferidos
        if (element.myCase.admissionTypeServer == CaseType.transfered) {
          if (element.child == null || element.child!.childId == '') {
            inform[3].transferedIn++;
          } else {
            if (element.child?.sex == "Masculino" ||
                element.child?.sex == "Homme" ||
                element.child?.sex == "ذكر") {
              inform[0].transferedIn++;
            } else {
              inform[1].transferedIn++;
            }
          }
        }
      }

      // DISCHARGES
      final closedCasesByDate = cases.where((caseFull) =>
      caseFull.myCase.lastDate.isAfter(DateTime.fromMillisecondsSinceEpoch(start))
          && caseFull.myCase.lastDate.isBefore(DateTime.fromMillisecondsSinceEpoch(end))
          && caseFull.myCase.closedReason != "null" && caseFull.myCase.closedReason.isNotEmpty);
      for (var element in closedCasesByDate) {
        // Recuperados
        if (element.myCase.closedReason == CaseType.recovered){
          if (element.child == null || element.child!.childId == '') {
            inform[3].recovered++;
          } else {
            if (element.child?.sex == "Masculino" ||
                element.child?.sex == "Homme" ||
                element.child?.sex == "ذكر") {
              inform[0].recovered++;
            } else {
              inform[1].recovered++;
            }
          }
        }

        // Sin respuesta
        if (element.myCase.closedReason == CaseType.unresponsive){
          if (element.child == null || element.child!.childId == '') {
            inform[3].unresponsive++;
          } else {
            if (element.child?.sex == "Masculino" ||
                element.child?.sex == "Homme" ||
                element.child?.sex == "ذكر") {
              inform[0].unresponsive++;
            } else {
              inform[1].unresponsive++;
            }
          }
        }

        // Abandono
        if (element.myCase.closedReason == CaseType.abandonment){
          if (element.child == null || element.child!.childId == '') {
            inform[3].abandonment++;
          } else {
            if (element.child?.sex == "Masculino" ||
                element.child?.sex == "Homme" ||
                element.child?.sex == "ذكر") {
              inform[0].abandonment++;
            } else {
              inform[1].abandonment++;
            }
          }
        }

        // Referidos
        if (element.myCase.closedReason == CaseType.referred){
          if (element.child == null || element.child!.childId == '') {
            inform[3].referredOut++;
          } else {
            if (element.child?.sex == "Masculino" ||
                element.child?.sex == "Homme" ||
                element.child?.sex == "ذكر") {
              inform[0].referredOut++;
            } else {
              inform[1].referredOut++;
            }
          }
        }

        // Abandono
        if (element.myCase.closedReason == CaseType.transfered){
          if (element.child == null || element.child!.childId == '') {
            inform[3].transferedOut++;
          } else {
            if (element.child?.sex == "Masculino" ||
                element.child?.sex == "Homme" ||
                element.child?.sex == "ذكر") {
              inform[0].transferedOut++;
            } else {
              inform[1].transferedOut++;
            }
          }
        }
      }
    }

    // Subtotal children
    inform[2].patientsAtBeginning = inform[0].patientsAtBeginning + inform[1].patientsAtBeginning;
    inform[2].newAdmissions = inform[0].newAdmissions + inform[1].newAdmissions;
    inform[2].reAdmissions = inform[0].reAdmissions + inform[1].reAdmissions;
    inform[2].relapses = inform[0].relapses + inform[1].relapses;
    inform[2].referredIn = inform[0].referredIn + inform[1].referredIn;
    inform[2].transferedIn = inform[0].transferedIn + inform[1].transferedIn;
    inform[2].recovered = inform[0].recovered + inform[1].recovered;
    inform[2].unresponsive = inform[0].unresponsive + inform[1].unresponsive;
    inform[2].abandonment = inform[0].abandonment + inform[1].abandonment;
    inform[2].referredOut = inform[0].referredOut + inform[1].referredOut;
    inform[2].transferedOut = inform[0].transferedOut + inform[1].transferedOut;

    // Total
    inform[4].patientsAtBeginning = inform[2].patientsAtBeginning + inform[3].patientsAtBeginning;
    inform[4].newAdmissions = inform[2].newAdmissions + inform[3].newAdmissions;
    inform[4].reAdmissions = inform[2].reAdmissions + inform[3].reAdmissions;
    inform[4].relapses = inform[2].relapses + inform[3].relapses;
    inform[4].referredIn = inform[2].referredIn + inform[3].referredIn;
    inform[4].transferedIn = inform[2].transferedIn + inform[3].transferedIn;
    inform[4].recovered = inform[2].recovered + inform[3].recovered;
    inform[4].unresponsive = inform[2].unresponsive + inform[3].unresponsive;
    inform[4].abandonment = inform[2].abandonment + inform[3].abandonment;
    inform[4].referredOut = inform[2].referredOut + inform[3].referredOut;
    inform[4].transferedOut = inform[2].transferedOut + inform[3].transferedOut;

    _mainInforms = inform;
  }

  List<AdmissionsAndDischargesInform>? getMainInforms() {
    return _mainInforms;
  }

  /// Update DataSource
  void updateDataSource() {
    notifyListeners();
  }

}

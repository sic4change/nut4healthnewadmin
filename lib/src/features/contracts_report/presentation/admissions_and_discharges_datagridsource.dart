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
          DataGridCell<int>(columnName: 'Referidos', value: mainInform.referred),
          DataGridCell<int>(columnName: 'Transferidos', value: mainInform.transfered),
          DataGridCell<int>(columnName: 'TOTAL ADMISIONES', value: mainInform.totalAdmissions()),
          DataGridCell<int>(columnName: 'TOTAL ATENDIDOS/AS', value: mainInform.totalAttended()),
        ]);
      }).toList();
    }
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(cells: <Widget>[
      _buildStandardContainer(row.getCells()[0].value.toString()),
      _buildStandardContainer(row.getCells()[1].value.toString()),
      _buildStandardContainer(row.getCells()[2].value.toString()),
      _buildStandardContainer(row.getCells()[3].value.toString()),
      _buildStandardContainer(row.getCells()[4].value.toString()),
      _buildStandardContainer(row.getCells()[5].value.toString()),
      _buildStandardContainer(row.getCells()[6].value.toString()),
      _buildStandardContainer(row.getCells()[7].value.toString()),
    ]);
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

  Widget _buildStandardContainer(String value) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.centerLeft,
      child: Text(value),
    );
  }

  setMainInforms(List<CaseFull>? cases, List<CaseFull>? openCasesBeforeStartDate, String selectedLocale) {
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
          referred: 0,
          transfered: 0,
        )
    );
    inform.add(
        AdmissionsAndDischargesInform(
          category: girl,
          patientsAtBeginning: 0,
          newAdmissions: 0,
          reAdmissions: 0,
          referred: 0,
          transfered: 0,
        )
    );
    inform.add(
        AdmissionsAndDischargesInform(
          category: subtotalChildren,
          patientsAtBeginning: 0,
          newAdmissions: 0,
          reAdmissions: 0,
          referred: 0,
          transfered: 0,
        )
    );
    inform.add(
        AdmissionsAndDischargesInform(
          category: fefa,
          patientsAtBeginning: 0,
          newAdmissions: 0,
          reAdmissions: 0,
          referred: 0,
          transfered: 0,
        )
    );
    inform.add(
        AdmissionsAndDischargesInform(
          category: total,
          patientsAtBeginning: 0,
          newAdmissions: 0,
          reAdmissions: 0,
          referred: 0,
          transfered: 0,
        )
    );

    if (openCasesBeforeStartDate != null) {
      for (var element in openCasesBeforeStartDate) {
        // Pacientes al comienzo
        //if (element.myCase.closedReason.isEmpty) {
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
        //}
      }
    }

    if (cases != null) {
      for (var element in cases) {
        // Nuevos casos
        if (element.myCase.admissionType == "Nouvelle admission" ||
            element.myCase.admissionType == "Nueva admisión" ||
            element.myCase.admissionType == "قبول جديد") {
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
        if (element.myCase.admissionType == "Réadmission" ||
            element.myCase.admissionType == "Readmisión" ||
            element.myCase.admissionType == "إعادة القبو") {
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

        // Referidos
        if (element.myCase.admissionType == "Réferencement" ||
            element.myCase.admissionType == "Referencia" ||
            element.myCase.admissionType == "الإحالة") {
          if (element.child == null || element.child!.childId == '') {
            inform[3].referred++;
          } else {
            if (element.child?.sex == "Masculino" ||
                element.child?.sex == "Homme" ||
                element.child?.sex == "ذكر") {
              inform[0].referred++;
            } else {
              inform[1].referred++;
            }
          }
        }

        // Transferidos
        if (element.myCase.admissionType == "Transfer" ||
            element.myCase.admissionType == "Transferencia" ||
            element.myCase.admissionType == "التحويل") {
          if (element.child == null || element.child!.childId == '') {
            inform[3].transfered++;
          } else {
            if (element.child?.sex == "Masculino" ||
                element.child?.sex == "Homme" ||
                element.child?.sex == "ذكر") {
              inform[0].transfered++;
            } else {
              inform[1].transfered++;
            }
          }
        }
      }
    }

    // Subtotal children
    inform[2].patientsAtBeginning = inform[0].patientsAtBeginning + inform[1].patientsAtBeginning;
    inform[2].newAdmissions = inform[0].newAdmissions + inform[1].newAdmissions;
    inform[2].reAdmissions = inform[0].reAdmissions + inform[1].reAdmissions;
    inform[2].referred = inform[0].referred + inform[1].referred;
    inform[2].transfered = inform[0].transfered + inform[1].transfered;
    inform[2].transfered = inform[0].transfered + inform[1].transfered;

    // Total
    inform[4].patientsAtBeginning = inform[2].patientsAtBeginning + inform[3].patientsAtBeginning;
    inform[4].newAdmissions = inform[2].newAdmissions + inform[3].newAdmissions;
    inform[4].reAdmissions = inform[2].reAdmissions + inform[3].reAdmissions;
    inform[4].referred = inform[2].referred + inform[3].referred;
    inform[4].transfered = inform[2].transfered + inform[3].transfered;
    inform[4].transfered = inform[2].transfered + inform[3].transfered;

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

import 'package:adminnut4health/src/features/contracts_report/domain/admissions_and_discharges_inform.dart';
import 'package:adminnut4health/src/features/contracts_report/domain/case_full.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../domain/PointWithVisitAndChild.dart';


class AdmissionsAndDischargesDataGridSource extends DataGridSource {
  AdmissionsAndDischargesDataGridSource(List<AdmissionsAndDischargesInform> admissionsAndDischargesInformData) {
    _mainInforms = admissionsAndDischargesInformData;
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
    List<AdmissionsAndDischargesInform> admissionsAndDischargesInform = [];
    late String boy, girl, fefa;
    switch (selectedLocale) {
      case 'en_US':
        boy = 'Boys <5 years';
        girl = 'Girls <5 years';
        fefa = 'Pregnant and lactating women';
        break;
      case 'es_ES':
        boy = 'Niños <5 años';
        girl = 'Niñas <5 años';
        fefa = 'Mujeres embarazadas y lactantes';
        break;
      case 'fr_FR':
        boy = 'Garcons <5 años';
        girl = 'Filles <5 años';
        fefa = 'FEFA';
        break;
    }
    admissionsAndDischargesInform.add(
        AdmissionsAndDischargesInform(
          category: boy,
          patientsAtBeginning: 0,
          newAdmissions: 0,
          reAdmissions: 0,
          referred: 0,
          transfered: 0,
        )
    );
    admissionsAndDischargesInform.add(
        AdmissionsAndDischargesInform(
          category: girl,
          patientsAtBeginning: 0,
          newAdmissions: 0,
          reAdmissions: 0,
          referred: 0,
          transfered: 0,
        )
    );
    admissionsAndDischargesInform.add(
        AdmissionsAndDischargesInform(
          category: fefa,
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
            admissionsAndDischargesInform[2].patientsAtBeginning++;
          } else {
            if (element.child?.sex == "Masculino" ||
                element.child?.sex == "Homme" ||
                element.child?.sex == "ذكر") {
              admissionsAndDischargesInform[0].patientsAtBeginning++;
            } else {
              admissionsAndDischargesInform[1].patientsAtBeginning++;
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
            admissionsAndDischargesInform[2].newAdmissions++;
          } else {
            if (element.child?.sex == "Masculino" ||
                element.child?.sex == "Homme" ||
                element.child?.sex == "ذكر") {
              admissionsAndDischargesInform[0].newAdmissions++;
            } else {
              admissionsAndDischargesInform[1].newAdmissions++;
            }
          }
        }

        // Readmisiones
        if (element.myCase.admissionType == "Réadmission" ||
            element.myCase.admissionType == "Readmisión" ||
            element.myCase.admissionType == "إعادة القبو") {
          if (element.child == null || element.child!.childId == '') {
            admissionsAndDischargesInform[2].reAdmissions++;
          } else {
            if (element.child?.sex == "Masculino" ||
                element.child?.sex == "Homme" ||
                element.child?.sex == "ذكر") {
              admissionsAndDischargesInform[0].reAdmissions++;
            } else {
              admissionsAndDischargesInform[1].reAdmissions++;
            }
          }
        }

        // Referidos
        if (element.myCase.admissionType == "Réferencement" ||
            element.myCase.admissionType == "Referencia" ||
            element.myCase.admissionType == "الإحالة") {
          if (element.child == null || element.child!.childId == '') {
            admissionsAndDischargesInform[2].referred++;
          } else {
            if (element.child?.sex == "Masculino" ||
                element.child?.sex == "Homme" ||
                element.child?.sex == "ذكر") {
              admissionsAndDischargesInform[0].referred++;
            } else {
              admissionsAndDischargesInform[1].referred++;
            }
          }
        }

        // Transferidos
        if (element.myCase.admissionType == "Transfer" ||
            element.myCase.admissionType == "Transferencia" ||
            element.myCase.admissionType == "التحويل") {
          if (element.child == null || element.child!.childId == '') {
            admissionsAndDischargesInform[2].transfered++;
          } else {
            if (element.child?.sex == "Masculino" ||
                element.child?.sex == "Homme" ||
                element.child?.sex == "ذكر") {
              admissionsAndDischargesInform[0].transfered++;
            } else {
              admissionsAndDischargesInform[1].transfered++;
            }
          }
        }
      }
    }

    _mainInforms = admissionsAndDischargesInform;
  }

  List<AdmissionsAndDischargesInform>? getMainInforms() {
    return _mainInforms;
  }

  /// Update DataSource
  void updateDataSource() {
    notifyListeners();
  }

}


import 'package:adminnut4health/src/features/contracts_report/domain/main_inform.dart';
/// Packages import
import 'package:flutter/material.dart';

/// DataGrid import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../domain/PointWithVisitAndChild.dart';


import '../domain/diagnosis_comunitary_crenam_by_region_and_date_inform.dart';class DiagnosisCommunitaryCrenamByRegionAndDateInformDataGridSource extends DataGridSource {

  DiagnosisCommunitaryCrenamByRegionAndDateInformDataGridSource(List<DiagnosisCommunitaryCrenamByRegionAndDateInform> mainInformData) {
    _mainInforms = mainInformData;
    buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = <DataGridRow>[];
  List<DiagnosisCommunitaryCrenamByRegionAndDateInform>? _mainInforms = <DiagnosisCommunitaryCrenamByRegionAndDateInform>[];

  /// Building DataGridRows
  void buildDataGridRows() {
    if (_mainInforms != null && _mainInforms!.isNotEmpty) {

      _dataGridRows = _mainInforms!.map<DataGridRow>((DiagnosisCommunitaryCrenamByRegionAndDateInform mainInform) {

        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<String>(columnName: 'Categoría', value: mainInform.category),
          DataGridCell<int>(columnName: 'Rojo (<115mm)', value: mainInform.red),
          DataGridCell<int>(columnName: 'Amarillo (115-125mm)', value: mainInform.yellow),
          DataGridCell<int>(columnName: 'Verde (≥ 125mm)', value: mainInform.green),
          DataGridCell<int>(columnName: 'Oedema', value: mainInform.oedema),
        ]);
      }).toList();
    }
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


  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(cells: <Widget>[
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[0].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[1].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[2].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[3].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[4].value.toString()),
      ),
    ]);
  }

  setMainInforms(List<VisitWithChildAndPoint>? mainInformData, String selectedLocale) {
    List<DiagnosisCommunitaryCrenamByRegionAndDateInform> diagnosisCommunitaryCrenamByRegionAndDateInform = [];
    late String _boy, _girl, _fefa;
    switch (selectedLocale) {
      case 'en_US':
        _boy = 'Boys <5 years';
        _girl = 'Girls <5 years';
        _fefa = 'Pregnant and lactating women';
        break;
      case 'es_ES':
        _boy = 'Niños <5 años';
        _girl = 'Niñas <5 años';
        _fefa = 'Mujeres embarazadas y lactantes';
        break;
      case 'fr_FR':
        _boy = 'Garcons <5 años';
        _girl = 'Filles <5 años';
        _fefa = 'FEFA';
        break;
    }
    diagnosisCommunitaryCrenamByRegionAndDateInform.add(
        DiagnosisCommunitaryCrenamByRegionAndDateInform(
            category: _boy,
            red: 0,
            yellow: 0,
            green: 0,
            oedema: 0
        )
    );
    diagnosisCommunitaryCrenamByRegionAndDateInform.add(
        DiagnosisCommunitaryCrenamByRegionAndDateInform(
            category: _girl,
            red: 0,
            yellow: 0,
            green: 0,
            oedema: 0
        )
    );
    diagnosisCommunitaryCrenamByRegionAndDateInform.add(
        DiagnosisCommunitaryCrenamByRegionAndDateInform(
            category: _fefa,
            red: 0,
            yellow: 0,
            green: 0,
            oedema: 0
        )
    );
    if (mainInformData != null) {
      for (var element in mainInformData) {
        if (element.visit != null) {
          if (element.visit!.armCircunference < 11.5) {
            if (element.child == null || element.child!.childId == '') {
              diagnosisCommunitaryCrenamByRegionAndDateInform[2].red++;
            } else {
              if (element.child?.sex == "Masculino" ||
                  element.child?.sex == "Homme" ||
                  element.child?.sex == "ذكر") {
                diagnosisCommunitaryCrenamByRegionAndDateInform[0].red++;
              } else {
                diagnosisCommunitaryCrenamByRegionAndDateInform[1].red++;
              }
            }
          } else if (element.visit!.armCircunference >= 11.5 &&
              element.visit!.armCircunference < 12.5) {
            if (element.child == null || element.child!.childId == '') {
              diagnosisCommunitaryCrenamByRegionAndDateInform[2].yellow++;
            } else {
              if (element.child?.sex == "Masculino" ||
                  element.child?.sex == "Homme" ||
                  element.child?.sex == "ذكر") {
                diagnosisCommunitaryCrenamByRegionAndDateInform[0].yellow++;
              } else {
                diagnosisCommunitaryCrenamByRegionAndDateInform[1].yellow++;
              }
            }
          } else if (element.visit!.armCircunference >= 12.5) {
            if (element.child == null || element.child!.childId == '') {
              diagnosisCommunitaryCrenamByRegionAndDateInform[2].green++;
            } else {
              if (element.child?.sex == "Masculino" ||
                  element.child?.sex == "Homme" ||
                  element.child?.sex == "ذكر") {
                diagnosisCommunitaryCrenamByRegionAndDateInform[0].green++;
              } else {
                diagnosisCommunitaryCrenamByRegionAndDateInform[1].green++;
              }
            }
          }
          if (element.visit.edema != null && element.visit.edema != "" && !element.visit.edema!.contains("(0)")) {
            if (element.child == null || element.child!.childId == '') {
              diagnosisCommunitaryCrenamByRegionAndDateInform[2].oedema++;
            } else {
              if (element.child?.sex == "Masculino" ||
                  element.child?.sex == "Homme" ||
                  element.child?.sex == "ذكر") {
                diagnosisCommunitaryCrenamByRegionAndDateInform[0].oedema++;
              } else {
                diagnosisCommunitaryCrenamByRegionAndDateInform[1].oedema++;
              }
            }
          }
        }
      }
    }
    _mainInforms = diagnosisCommunitaryCrenamByRegionAndDateInform;
  }

  List<DiagnosisCommunitaryCrenamByRegionAndDateInform>? getMainInforms() {
    return _mainInforms;
  }

  /// Update DataSource
  void updateDataSource() {
    notifyListeners();
  }

}

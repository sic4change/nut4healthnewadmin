
/// Packages import
import 'package:adminnut4health/src/features/symptoms/domain/symptom.dart';
import 'package:flutter/material.dart';

/// DataGrid import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

/// Set symptom's data collection to data grid source.
class SymptomDataGridSource extends DataGridSource {
  /// Creates the symptom data source class with required details.
  SymptomDataGridSource(List<Symptom> symptomData) {
    _symptoms = symptomData;
    buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = <DataGridRow>[];
  List<Symptom>? _symptoms = <Symptom>[];

  /// Building DataGridRows
  void buildDataGridRows() {
    if (_symptoms != null && _symptoms!.isNotEmpty) {
      _dataGridRows = _symptoms!.map<DataGridRow>((Symptom symptom) {
        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<String>(columnName: 'Id', value: symptom.symptomId),
          DataGridCell<String>(columnName: 'Síntoma (ES)', value: symptom.name),
          DataGridCell<String>(columnName: 'Síntoma (EN)', value: symptom.nameEn),
          DataGridCell<String>(columnName: 'Síntoma (FR)', value: symptom.nameFr),
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
    ]);
  }

  setSymptoms(List<Symptom>? symptomData) {
    _symptoms = symptomData;
  }

  List<Symptom>? getSymptoms() {
    return _symptoms;
  }

  /// Update DataSource
  void updateDataSource() {
    notifyListeners();
  }
}

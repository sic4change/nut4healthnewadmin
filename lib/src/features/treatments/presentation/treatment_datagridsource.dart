
/// Packages import
import 'package:adminnut4health/src/features/treatments/domain/treatment.dart';
import 'package:flutter/material.dart';

/// DataGrid import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

/// Set treatment's data collection to data grid source.
class TreatmentDataGridSource extends DataGridSource {
  /// Creates the treatment data source class with required details.
  TreatmentDataGridSource(List<Treatment> treatmentData) {
    _treatments = treatmentData;
    buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = <DataGridRow>[];
  List<Treatment>? _treatments = <Treatment>[];

  /// Building DataGridRows
  void buildDataGridRows() {
    if (_treatments != null && _treatments!.isNotEmpty) {
      _dataGridRows = _treatments!.map<DataGridRow>((Treatment treatment) {
        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<String>(columnName: 'Id', value: treatment.treatmentId),
          DataGridCell<String>(columnName: 'Tratamiento (ES)', value: treatment.name),
          DataGridCell<String>(columnName: 'Tratamiento (EN)', value: treatment.nameEn),
          DataGridCell<String>(columnName: 'Tratamiento (FR)', value: treatment.nameFr),
          DataGridCell<double>(columnName: 'Precio', value: treatment.price),
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
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[4].value.toString()),
      ),
    ]);
  }

  setTreatments(List<Treatment>? treatmentData) {
    _treatments = treatmentData;
  }

  List<Treatment>? getTreatments() {
    return _treatments;
  }

  /// Update DataSource
  void updateDataSource() {
    notifyListeners();
  }
}

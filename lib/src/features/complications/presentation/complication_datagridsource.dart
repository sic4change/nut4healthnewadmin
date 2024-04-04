
/// Packages import
import 'package:adminnut4health/src/features/complications/domain/complication.dart';
import 'package:flutter/material.dart';

/// DataGrid import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

/// Set complication's data collection to data grid source.
class ComplicationDataGridSource extends DataGridSource {
  /// Creates the complication data source class with required details.
  ComplicationDataGridSource(List<Complication> complicationData) {
    _complications = complicationData;
    buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = <DataGridRow>[];
  List<Complication>? _complications = <Complication>[];

  /// Building DataGridRows
  void buildDataGridRows() {
    if (_complications != null && _complications!.isNotEmpty) {
      _dataGridRows = _complications!.map<DataGridRow>((Complication complication) {
        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<String>(columnName: 'ID', value: complication.complicationId),
          DataGridCell<String>(columnName: 'Complicación (ES)', value: complication.name),
          DataGridCell<String>(columnName: 'Complicación (EN)', value: complication.nameEn),
          DataGridCell<String>(columnName: 'Complicación (FR)', value: complication.nameFr),
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
        child: Text(row.getCells()[0].value.toString()),
      ),
    ]);
  }

  setComplications(List<Complication>? complicationData) {
    _complications = complicationData;
  }

  List<Complication>? getComplications() {
    return _complications;
  }

  /// Update DataSource
  void updateDataSource() {
    notifyListeners();
  }
}

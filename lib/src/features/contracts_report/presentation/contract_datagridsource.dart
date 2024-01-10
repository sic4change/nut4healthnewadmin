
import 'package:adminnut4health/src/features/contracts_report/domain/main_inform.dart';
/// Packages import
import 'package:flutter/material.dart';

/// DataGrid import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class MainInformDataGridSource extends DataGridSource {

  MainInformDataGridSource(List<MainInform> mainInformData) {
    _mainInforms = mainInformData;
    buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = <DataGridRow>[];
  List<MainInform>? _mainInforms = <MainInform>[];

  /// Building DataGridRows
  void buildDataGridRows() {
    if (_mainInforms != null && _mainInforms!.isNotEmpty) {

      _dataGridRows = _mainInforms!.map<DataGridRow>((MainInform mainInform) {

        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<String>(columnName: 'Localidad', value: mainInform.place),
          DataGridCell<int>(columnName: 'Registros', value: mainInform.records),
          DataGridCell<int>(columnName: 'Niños/as', value: mainInform.childs),
          DataGridCell<int>(columnName: 'FEFAS', value: mainInform.fefas),
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
    ]);
  }

  setMainInforms(List<MainInform>? mainInformData) {
    _mainInforms = mainInformData;
  }

  List<MainInform>? getMainInforms() {
    return _mainInforms;
  }

  /// Update DataSource
  void updateDataSource() {
    notifyListeners();
  }

}

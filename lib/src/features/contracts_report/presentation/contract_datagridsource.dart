
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
          DataGridCell<int>(columnName: 'Niños/as SAM', value: mainInform.childsMAS),
          DataGridCell<int>(columnName: 'Niños/as MAM', value: mainInform.childsMAM),
          DataGridCell<int>(columnName: 'Niños/as PN', value: mainInform.childsPN),
          DataGridCell<int>(columnName: 'FEFAS', value: mainInform.fefas),
          DataGridCell<int>(columnName: 'FEFAS FE', value: mainInform.fefasfe),
          DataGridCell<int>(columnName: 'FEFAS FE MAS', value: mainInform.fefasfemas),
          DataGridCell<int>(columnName: 'FEFAS FE MAM', value: mainInform.fefasfemam),
          DataGridCell<int>(columnName: 'FEFAS FE PN', value: mainInform.fefasfepn),
          DataGridCell<int>(columnName: 'FEFAS FA', value: mainInform.fefasfa),
          DataGridCell<int>(columnName: 'FEFAS FA MAS', value: mainInform.fefasfamas),
          DataGridCell<int>(columnName: 'FEFAS FA MAM', value: mainInform.fefasfamam),
          DataGridCell<int>(columnName: 'FEFAS FA PN', value: mainInform.fefasfapn),
          DataGridCell<int>(columnName: 'FEFAS FEA', value: mainInform.fefasfea),
          DataGridCell<int>(columnName: 'FEFAS FEA MAS', value: mainInform.fefasfeamas),
          DataGridCell<int>(columnName: 'FEFAS FEA MAM', value: mainInform.fefasfeamam),
          DataGridCell<int>(columnName: 'FEFAS FEA PN', value: mainInform.fefasfeapn),
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
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[5].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[6].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[7].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[8].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[9].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[10].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[11].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[12].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[13].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[14].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[15].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[16].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[17].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[18].value.toString()),
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

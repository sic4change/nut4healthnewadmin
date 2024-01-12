
/// Packages import
import 'package:flutter/material.dart';

/// DataGrid import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../domain/child_inform.dart';

class ChildInformDataGridSource extends DataGridSource {

  ChildInformDataGridSource(List<ChildInform> childInformData) {
    _childInforms = childInformData;
    buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = <DataGridRow>[];
  List<ChildInform>? _childInforms = <ChildInform>[];

  /// Building DataGridRows
  void buildDataGridRows() {
    if (_childInforms != null && _childInforms!.isNotEmpty) {

      _dataGridRows = _childInforms!.map<DataGridRow>((ChildInform mainInform) {

        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<String>(columnName: 'Localidad', value: mainInform.place),
          DataGridCell<String>(columnName: 'Edad', value: mainInform.ageGroup),
          DataGridCell<int>(columnName: 'Registros', value: mainInform.records),
          DataGridCell<int>(columnName: 'M', value: mainInform.male),
          DataGridCell<int>(columnName: 'M MAS', value: mainInform.malemas),
          DataGridCell<int>(columnName: 'M MAM', value: mainInform.malemam),
          DataGridCell<int>(columnName: 'M PN', value: mainInform.malepn),
          DataGridCell<int>(columnName: 'F', value: mainInform.female),
          DataGridCell<int>(columnName: 'F MAS', value: mainInform.femalemas),
          DataGridCell<int>(columnName: 'F MAM', value: mainInform.femalemam),
          DataGridCell<int>(columnName: 'F PN', value: mainInform.femalepn),
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
    ]);
  }

  setChildInforms(List<ChildInform>? mainInformData) {
    _childInforms = mainInformData;
  }

  List<ChildInform>? getChildInforms() {
    return _childInforms;
  }

  /// Update DataSource
  void updateDataSource() {
    notifyListeners();
  }

}


/// Packages import
import 'package:adminnut4health/src/features/childs/domain/childWithPointAndTutor.dart';
import 'package:flutter/material.dart';

/// DataGrid import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

/// Set child's data collection to data grid source.
class ChildDataGridSource extends DataGridSource {
  /// Creates the child data source class with required details.
  ChildDataGridSource(List<ChildWithPointAndTutor> childData) {
    _childs = childData;
    buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = <DataGridRow>[];
  List<ChildWithPointAndTutor>? _childs = <ChildWithPointAndTutor>[];

  /// Building DataGridRows
  void buildDataGridRows() {
    if (_childs != null && _childs!.isNotEmpty) {
      _dataGridRows = _childs!.map<DataGridRow>((ChildWithPointAndTutor childWithPointAndTutor) {
        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<String>(columnName: 'Id', value: childWithPointAndTutor.child.childId),
          DataGridCell<String>(columnName: 'Punto', value: childWithPointAndTutor.point?.name??""),
          DataGridCell<String>(columnName: 'Nombre', value: childWithPointAndTutor.child.name),
          DataGridCell<String>(columnName: 'Apellidos', value: childWithPointAndTutor.child.surnames),
          DataGridCell<DateTime>(columnName: 'Fecha de nacimiento', value: childWithPointAndTutor.child.birthdate),
          DataGridCell<DateTime>(columnName: 'Fecha de alta', value: childWithPointAndTutor.child.createDate),
          DataGridCell<DateTime>(columnName: 'Última visita', value: childWithPointAndTutor.child.lastDate),
          DataGridCell<String>(columnName: 'Etnia', value: childWithPointAndTutor.child.ethnicity),
          DataGridCell<String>(columnName: 'Sexo', value: childWithPointAndTutor.child.sex),
          DataGridCell<String>(columnName: 'Madre, padre o tutor', value: childWithPointAndTutor.tutor?.name?? ""),
          DataGridCell<String>(columnName: 'Observaciones', value: childWithPointAndTutor.child.observations),
        ]);
      }).toList();
    }
  }

  Widget _getWidget(Widget image, String text) {
    return Container(
      color: Colors.transparent,
      child: Row(
        children: <Widget>[
          Container(
            child: image,
          ),
          const SizedBox(width: 6),
          Expanded(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
              ))
        ],
      ),
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

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(cells: <Widget>[
      _buildStandardContainer(row.getCells()[1].value.toString()),
      _buildStandardContainer(row.getCells()[2].value.toString()),
      _buildStandardContainer(row.getCells()[3].value.toString()),
      _buildDate(row.getCells()[4].value),
      _buildDate(row.getCells()[5].value),
      _buildDate(row.getCells()[6].value),
      _buildStandardContainer(row.getCells()[7].value.toString()),
      _buildStandardContainer(row.getCells()[8].value.toString()),
      _buildStandardContainer(row.getCells()[9].value.toString()),
      _buildStandardContainer(row.getCells()[10].value.toString()),
    ]);
  }

  setChilds(List<ChildWithPointAndTutor>? childData) {
    _childs = childData;
  }

  List<ChildWithPointAndTutor>? getChilds() {
    return _childs;
  }

  /// Update DataSource
  void updateDataSource() {
    notifyListeners();
  }

  Widget _buildDate(dynamic value) {
    String valueString = value.toString();
    if (valueString == null || valueString.isEmpty || valueString == '1970-01-01 00:00:00.000') {
      return const Text("");
    } else {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: _getWidget(const Icon(Icons.calendar_month, size: 20), value.toString()),
      );
    }
  }

  Widget _buildStandardContainer(String value) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.centerLeft,
      child: Text(value),
    );
  }
}

/// Packages import
import 'package:adminnut4health/src/features/cases/domain/caseWithPointChildAndTutor.dart';
import 'package:flutter/material.dart';

/// DataGrid import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

/// Set myCase's data collection to data grid source.
class CaseDataGridSource extends DataGridSource {
  /// Creates the myCase data source class with required details.
  CaseDataGridSource(List<CaseWithPointChildAndTutor> myCaseData) {
    _myCases = myCaseData;
    buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = <DataGridRow>[];
  List<CaseWithPointChildAndTutor>? _myCases = <CaseWithPointChildAndTutor>[];

  /// Building DataGridRows
  void buildDataGridRows() {
    if (_myCases != null && _myCases!.isNotEmpty) {
      _dataGridRows = _myCases!.map<DataGridRow>((CaseWithPointChildAndTutor myCaseWithPointChildAndTutor) {
        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<String>(columnName: 'Id', value: myCaseWithPointChildAndTutor.myCase.caseId),
          DataGridCell<String>(columnName: 'Punto', value: myCaseWithPointChildAndTutor.point?.name??""),
          DataGridCell<String>(columnName: 'Madre, padre o tutor', value: myCaseWithPointChildAndTutor.tutor?.name?? ""),
          DataGridCell<String>(columnName: 'Niño/a', value: myCaseWithPointChildAndTutor.child?.name?? ""),
          DataGridCell<String>(columnName: 'Nombre', value: myCaseWithPointChildAndTutor.myCase.name),
          DataGridCell<DateTime>(columnName: 'Fecha de alta', value: myCaseWithPointChildAndTutor.myCase.createDate),
          DataGridCell<DateTime>(columnName: 'Última visita', value: myCaseWithPointChildAndTutor.myCase.lastDate),
          DataGridCell<int>(columnName: 'Nº visitas', value: myCaseWithPointChildAndTutor.myCase.visits),
          DataGridCell<String>(columnName: 'Observaciones', value: myCaseWithPointChildAndTutor.myCase.observations),
          DataGridCell<String>(columnName: 'Estado', value: myCaseWithPointChildAndTutor.myCase.status),
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
      _buildStandardContainer(row.getCells()[4].value.toString()),
      _buildDate(row.getCells()[5].value),
      _buildDate(row.getCells()[6].value),
      _buildStandardContainer(row.getCells()[7].value.toString()),
      _buildStandardContainer(row.getCells()[8].value.toString()),
      _buildStandardContainer(row.getCells()[9].value.toString()),
    ]);
  }

  setCases(List<CaseWithPointChildAndTutor>? myCaseData) {
    _myCases = myCaseData;
  }

  List<CaseWithPointChildAndTutor>? getCases() {
    return _myCases;
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

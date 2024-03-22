
/// Packages import
import 'package:adminnut4health/src/features/cases/domain/caseWithPointChildAndTutor.dart';
import 'package:flutter/material.dart';

/// DataGrid import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../users/domain/user.dart';

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
          DataGridCell<bool>(columnName: 'Validación Médico Jefe', value: myCaseWithPointChildAndTutor.myCase.chefValidation),
          DataGridCell<bool>(columnName: 'Validación Dirección Regional', value: myCaseWithPointChildAndTutor.myCase.regionalValidation),
          DataGridCell<String>(columnName: 'Tipo de admisión', value: myCaseWithPointChildAndTutor.myCase.admissionType),
          DataGridCell<String>(columnName: 'Servidor tipo de admisión', value: myCaseWithPointChildAndTutor.myCase.admissionTypeServer),
          DataGridCell<String>(columnName: 'Razón de cierre', value: myCaseWithPointChildAndTutor.myCase.closedReason),
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
      _buildBoolean(row.getCells()[10].value),
      _buildBoolean(row.getCells()[11].value),
      _buildStandardContainer(row.getCells()[1].value.toString()),
      User.currentRole != 'donante' ? Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[2].value.toString()),
      ) : Container(padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: const Text('---------'),
      ),
      User.currentRole != 'donante' ? Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[3].value.toString()),
      ) : Container(padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: const Text('---------'),
      ),
      _buildStandardContainer(row.getCells()[4].value.toString()),
      _buildStandardContainer(row.getCells()[12].value.toString()),
      _buildStandardContainer(row.getCells()[13].value.toString()),
      _buildStandardContainer(row.getCells()[14].value.toString()),
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

  Widget _buildBoolean(bool value) {
    final Map<String, Image> images = <String, Image>{
      '✔': Image.asset('images/Perfect.png'),
      '✘': Image.asset('images/Insufficient.png'),
    };

    if (value) {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: _getWidget(images['✔']!, ''),
      );
    } else  {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: _getWidget(images['✘']!, ''),
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

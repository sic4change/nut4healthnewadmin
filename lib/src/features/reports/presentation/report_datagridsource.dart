
/// Packages import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// DataGrid import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../domain/report.dart';

/// Set report's data collection to data grid source.
class ReportDataGridSource extends DataGridSource {
  /// Creates the report data source class with required details.
  ReportDataGridSource(List<Report> reportData) {
    _reports = reportData;
    buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = <DataGridRow>[];
  List<Report>? _reports = <Report>[];

  /// Building DataGridRows
  void buildDataGridRows() {
    if (_reports != null && _reports!.isNotEmpty) {
      _dataGridRows = _reports!.map<DataGridRow>((Report report) {
        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<DateTime>(columnName: 'Fecha', value: report.date),
          //DataGridCell<String>(columnName: 'Nombre', value: report.text),
          //DataGridCell<String>(columnName: 'Apellidos', value: report.text),
          DataGridCell<String>(columnName: 'Email', value: report.email),
          DataGridCell<String>(columnName: 'Mensaje', value: report.text),
          DataGridCell<bool>(columnName: 'Enviado', value: report.sent),
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

  final Map<String, Image> _images = <String, Image>{
    '✔': Image.asset('images/Perfect.png'),
    '✘': Image.asset('images/Insufficient.png'),
  };

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
      _buildDate(row.getCells()[0].value),
      /*
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[4].value.toString()),
      ),*/
      /*
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[4].value.toString()),
      ),*/
      _buildEmail(row.getCells()[1].value),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[2].value.toString()),
      ),
      _buildSent(row.getCells()[3].value),
    ]);
  }

  setReports(List<Report>? reportData) {
    _reports = reportData;
  }

  List<Report>? getReports() {
    return _reports;
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

  Widget _buildEmail(dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: _getWidget(const Icon(Icons.email, size: 20), value),
    );
  }

  Widget _buildSent(bool value) {
    if (value) {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: _getWidget(_images['✔']!, ''),
      );
    } else  {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: _getWidget(_images['✘']!, ''),
      );
    }
  }
}

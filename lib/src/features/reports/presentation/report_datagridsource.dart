
/// Packages import
import 'package:adminnut4health/src/features/reports/domain/report_with_user.dart';
import 'package:flutter/material.dart';

/// DataGrid import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

/// Set report's data collection to data grid source.
class ReportDataGridSource extends DataGridSource {
  /// Creates the report data source class with required details.
  ReportDataGridSource(List<ReportWithUser> reportData) {
    _reports = reportData;
    buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = <DataGridRow>[];
  List<ReportWithUser>? _reports = <ReportWithUser>[];

  /// Building DataGridRows
  void buildDataGridRows() {
    if (_reports != null && _reports!.isNotEmpty) {
      _dataGridRows = _reports!.map<DataGridRow>((ReportWithUser reportWithUser) {
        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<DateTime>(columnName: 'Fecha', value: reportWithUser.report.date),
          DataGridCell<String>(columnName: 'Nombre', value: reportWithUser.user?.name??""),
          DataGridCell<String>(columnName: 'Apellidos', value: reportWithUser.user?.surname??""),
          DataGridCell<String>(columnName: 'Email', value: reportWithUser.report.email),
          DataGridCell<String>(columnName: 'Mensaje', value: reportWithUser.report.text),
          DataGridCell<bool>(columnName: 'Enviado', value: reportWithUser.report.sent),
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
      _buildEmail(row.getCells()[3].value),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[4].value.toString()),
      ),
      _buildSent(row.getCells()[5].value),
    ]);
  }

  setReports(List<ReportWithUser>? reportData) {
    _reports = reportData;
  }

  List<ReportWithUser>? getReports() {
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

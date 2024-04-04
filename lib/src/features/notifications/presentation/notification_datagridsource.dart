
/// Packages import
import 'package:adminnut4health/src/features/cases/domain/caseWithPointChildAndTutor.dart';
import 'package:adminnut4health/src/features/notifications/domain/notificationWithPointAndChild.dart';
import 'package:flutter/material.dart';

/// DataGrid import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

/// Set notification's data collection to data grid source.
class NotificationDataGridSource extends DataGridSource {
  /// Creates the notification data source class with required details.
  NotificationDataGridSource(List<NotificationWithPointAndChild> notificationData) {
    _notifications = notificationData;
    buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = <DataGridRow>[];
  List<NotificationWithPointAndChild>? _notifications = <NotificationWithPointAndChild>[];

  /// Building DataGridRows
  void buildDataGridRows() {
    if (_notifications != null && _notifications!.isNotEmpty) {
      _dataGridRows = _notifications!.map<DataGridRow>((NotificationWithPointAndChild notificationWithPointAndChild) {
        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<String>(columnName: 'ID', value: notificationWithPointAndChild.notification.notificationId),
          DataGridCell<String>(columnName: 'Punto', value: notificationWithPointAndChild.point?.name??""),
          DataGridCell<String>(columnName: 'Niño/a', value: notificationWithPointAndChild.child?.name?? ""),
          DataGridCell<String>(columnName: 'Texto', value: notificationWithPointAndChild.notification.text),
          DataGridCell<double>(columnName: 'Duración', value: notificationWithPointAndChild.notification.timeMillis),
          DataGridCell<bool>(columnName: 'Enviado', value: notificationWithPointAndChild.notification.sent),
          DataGridCell<String>(columnName: 'Punto ID', value: notificationWithPointAndChild.notification.pointId),
          DataGridCell<String>(columnName: 'Niño/a ID', value: notificationWithPointAndChild.notification.childId),
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
      _buildSent(row.getCells()[5].value),
      _buildStandardContainer(row.getCells()[0].value),
      _buildStandardContainer(row.getCells()[6].value),
      _buildStandardContainer(row.getCells()[7].value),
    ]);
  }

  setNotifications(List<NotificationWithPointAndChild>? notificationData) {
    _notifications = notificationData;
  }

  List<NotificationWithPointAndChild>? getNotifications() {
    return _notifications;
  }

  /// Update DataSource
  void updateDataSource() {
    notifyListeners();
  }

  Widget _buildStandardContainer(String value) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.centerLeft,
      child: Text(value),
    );
  }

  final Map<String, Image> _images = <String, Image>{
    '✔': Image.asset('images/Perfect.png'),
    '✘': Image.asset('images/Insufficient.png'),
  };

  Widget _buildSent(bool sent) {
    if (sent) {
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

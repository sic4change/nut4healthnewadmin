/// Dart import
import 'dart:math' as math;

/// Packages import
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// DataGrid import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../domain/user.dart';

/// Set user's data collection to data grid source.
class UserDataGridSource extends DataGridSource {
  /// Creates the user data source class with required details.
  UserDataGridSource(List<User> userData) {
    _users = userData;
    buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = <DataGridRow>[];
  List<User>? _users = <User>[];

  /// Building DataGridRows
  void buildDataGridRows() {
    if (_users != null && _users!.isNotEmpty) {
      _dataGridRows = _users!.map<DataGridRow>((User user) {
        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<String>(columnName: 'Username', value: user.username),
          DataGridCell<String>(columnName: 'Nombre', value: user.name),
          DataGridCell<String>(columnName: 'Apellidos', value: user.surname),
          DataGridCell<String>(columnName: 'DNI/DPI', value: user.dni),
          DataGridCell<String>(columnName: 'Email', value: user.email),
          DataGridCell<String>(columnName: 'Teléfono', value: user.phone),
          DataGridCell<String>(columnName: 'Rol', value: user.role),
          DataGridCell<String>(columnName: 'Punto', value: user.point),
          DataGridCell<String>(columnName: 'Configuración', value: user.configuration),
          DataGridCell<int>(columnName: 'Puntos', value: user.points),
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
      padding: EdgeInsets.all(15.0),
      child: Text(summaryValue),
    );
  }

  Widget _buildUserName(dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: _getWidget(
          Icon(Icons.account_circle, size: 30, color: Colors.blue[300]), value),
    );
  }

  Widget _buildEmail(dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: _getWidget(const Icon(Icons.email, size: 20), value),
    );
  }

  Widget _buildPhone(dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: _getWidget(const Icon(Icons.phone, size: 20), value),
    );
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

  TextStyle _getStatusTextStyle(dynamic value) {
    if (value) {
      return const TextStyle(color: Colors.green);
    } else {
      return TextStyle(color: Colors.red[500]);
    }
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(cells: <Widget>[
      _buildUserName(row.getCells()[0].value),
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
          alignment: Alignment.center,
          child: Text(
            row.getCells()[5].value.toString())
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
        alignment: Alignment.center,
        child: Text(row.getCells()[9].value.toString()),
      ),
    ]);
  }

  setUsers(List<User>? userData) {
    _users = userData;
  }

}

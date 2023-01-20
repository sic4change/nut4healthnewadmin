/// Dart import
import 'dart:math' as math;

/// Packages import
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// DataGrid import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../model/user.dart';

/// Set user's data collection to data grid source.
class UserDataGridSource extends DataGridSource {
  /// Creates the user data source class with required details.
  UserDataGridSource() {
    _users = _getUsers(20);
    buildDataGridRows();
  }

  final math.Random _random = math.Random();
  List<DataGridRow> _dataGridRows = <DataGridRow>[];
  List<User> _users = <User>[];

  /// Building DataGridRows
  void buildDataGridRows() {
    _dataGridRows = _users.map<DataGridRow>((User user) {
      return DataGridRow(cells: <DataGridCell>[
        DataGridCell<String>(
            columnName: 'Username', value: user.username),
        DataGridCell<String>(
            columnName: 'Nombre', value: user.name),
        DataGridCell<String>(
            columnName: 'Apellidos', value: user.surname),
        DataGridCell<String>(columnName: 'Email', value: user.email),
        DataGridCell<String>(columnName: 'Teléfono', value: user.phone),
        DataGridCell<bool>(columnName: 'Estado', value: user.status),
      ]);
    }).toList();
  }

  // Overrides
  @override
  List<DataGridRow> get rows => _dataGridRows;

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
      _buildEmail(row.getCells()[3].value),
      _buildPhone(row.getCells()[4].value),
      Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text(
            row.getCells()[4].value.toString(),
            style: _getStatusTextStyle(row.getCells()[5].value),
          )),
    ]);
  }


  List<User> _getUsers(int count) {
    final List<User> userData = <User>[];
    //Llamada a firebase para traer los users
    return userData;
  }
}

/// Dart import
import 'dart:math' as math;

import 'package:adminnut4health/src/features/points/domain/point.dart';
/// Packages import
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// DataGrid import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../configurations/domain/configuration.dart';
import '../domain/UserWithConfigurationAndPoint.dart';

/// Set user's data collection to data grid source.
class UserDataGridSource extends DataGridSource {
  /// Creates the user data source class with required details.
  UserDataGridSource(List<UserWithConfigurationAndPoint> userData,
      List<Point> pointData, List<Configuration> configurationData) {
    _users = userData;
    _points = pointData;
    _configurations = configurationData;
    buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = <DataGridRow>[];
  List<UserWithConfigurationAndPoint>? _users = <UserWithConfigurationAndPoint>[];
  List<Point> _points = <Point>[];
  List<Configuration> _configurations = <Configuration>[];

  /// Building DataGridRows
  void buildDataGridRows() {
    if (_users != null && _users!.isNotEmpty) {
      _dataGridRows = _users!.map<DataGridRow>((UserWithConfigurationAndPoint userWithConfiguration) {
        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<String>(columnName: 'Foto', value: userWithConfiguration.user.photo),
          DataGridCell<String>(columnName: 'Username', value: userWithConfiguration.user.username),
          DataGridCell<String>(columnName: 'Nombre', value: userWithConfiguration.user.name),
          DataGridCell<String>(columnName: 'Apellidos', value: userWithConfiguration.user.surname),
          DataGridCell<String>(columnName: 'DNI/DPI', value: userWithConfiguration.user.dni),
          DataGridCell<String>(columnName: 'Email', value: userWithConfiguration.user.email),
          DataGridCell<String>(columnName: 'Teléfono', value: userWithConfiguration.user.phone),
          DataGridCell<String>(columnName: 'Rol', value: userWithConfiguration.user.role),
          DataGridCell<String>(columnName: 'Punto', value: userWithConfiguration.point?.name),
          DataGridCell<String>(columnName: 'Configuración', value: userWithConfiguration.configuration?.name),
          DataGridCell<int>(columnName: 'Puntos', value: userWithConfiguration.user.points),
          DataGridCell<DateTime>(columnName: 'CreateDate', value: userWithConfiguration.user.createdate),
          DataGridCell<String>(columnName: 'Dirección', value: userWithConfiguration.user.address),
          DataGridCell<String>(columnName: 'Hash transacción punto', value: userWithConfiguration.user.pointTransactionHash),
          DataGridCell<String>(columnName: 'Hash transacción rol', value: userWithConfiguration.user.roleTransactionHash),
          DataGridCell<String>(columnName: 'Hash transacción configuración', value: userWithConfiguration.user.configurationTransactionHash),
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

  Widget _buildPhoto(dynamic value) {
    return Padding(
            padding: const EdgeInsets.all(1.0),
            child: CircleAvatar(
              radius: 80.0,
              backgroundColor: Colors.grey[200],
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.scaleDown,
                    image: NetworkImage(value),
                  ),
                ),
              ),
            )
            /*child: CircleAvatar(
              backgroundImage: NetworkImage(value),
            ),*/
    );
  }

  Widget _buildEmail(dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: _getWidget(const Icon(Icons.email, size: 20), value),
    );
  }

  Widget _buildPhone(dynamic value) {
    if (value.toString().isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: _getWidget(const Icon(Icons.phone, size: 20), value),
      );
    } else {
      return const Text("");
    }
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

  Widget _buildPoint(dynamic value) {
    if (value.toString().isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: _getWidget(const Icon(Icons.place, size: 20), value),
      );
    } else {
      return const Text("");
    }
  }

  Widget _buildRole(dynamic value) {
    return Center(
      child: Text(
        value,
        style: _getStatusTextStyle(value),
        overflow: TextOverflow.ellipsis,
      ),
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
    if (value.toString() == 'Servicio Salud') {
      return const TextStyle(color: Colors.green);
    } else if (value.toString() == 'Agente Salud') {
      return TextStyle(color: Colors.blueAccent);
    } else if (value.toString() == 'Super Admin') {
      return const TextStyle(color: Colors.red);
    } else {
      return const TextStyle(color: Colors.orange);
    }
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(cells: <Widget>[
      _buildPhoto((row.getCells()[0].value.toString())),
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
      _buildEmail(row.getCells()[5].value),
      _buildPhone(row.getCells()[6].value),
      _buildRole(row.getCells()[7].value),
      _buildPoint(row.getCells()[8].value),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[9].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Text(row.getCells()[10].value.toString()),
      ),
      _buildDate(row.getCells()[11].value),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
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
    ]);
  }

  setUsers(List<UserWithConfigurationAndPoint>? userData) {
    _users = userData;
  }

  List<UserWithConfigurationAndPoint>? getUsers() {
    return _users;
  }

  setPoints(List<Point> pointData) {
    _points = pointData;
  }

  List<Point> getPoints() {
    return _points;
  }

  setConfigurations(List<Configuration> configurationData) {
    _configurations = configurationData;
  }

  List<Configuration> getConfigurations() {
    return _configurations;
  }

  /// Update DataSource
  void updateDataSource() {
    notifyListeners();
  }

}

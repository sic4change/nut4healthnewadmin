/// Dart import
import 'dart:math' as math;

import 'package:adminnut4health/src/features/locations/domain/location.dart';
import 'package:adminnut4health/src/features/points/domain/point.dart';
import 'package:adminnut4health/src/features/provinces/domain/province.dart';
import 'package:adminnut4health/src/features/regions/domain/region.dart';
/// Packages import
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// DataGrid import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../configurations/domain/configuration.dart';
import '../domain/UserWithConfigurationAndPoint.dart';
import '../domain/user.dart';

import '../../../sample/model/sample_view.dart';

/// Set user's data collection to data grid source.
class UserDataGridSource extends DataGridSource {
  /// Creates the user data source class with required details.
  UserDataGridSource(List<UserWithConfigurationAndPoint> userData,
      List<Region> regionData, List<Location> locationData, List<Province> provinceData,
      List<Point> pointData, List<Configuration> configurationData) {
    _users = userData;
    _regions = regionData;
    _locations = locationData;
    _provinces = provinceData;
    _points = pointData;
    _configurations = configurationData;
    buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = <DataGridRow>[];
  List<UserWithConfigurationAndPoint>? _users = <UserWithConfigurationAndPoint>[];
  List<Region> _regions = <Region>[];
  List<Location> _locations = <Location>[];
  List<Province> _provinces = <Province>[];
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
          DataGridCell<String>(columnName: 'Región', value: userWithConfiguration.region?.name),
          DataGridCell<String>(columnName: 'Provincia', value: userWithConfiguration.location?.name),
          DataGridCell<String>(columnName: 'Municipio', value: userWithConfiguration.province?.name),
          DataGridCell<String>(columnName: 'Punto', value: userWithConfiguration.point?.name),
          DataGridCell<String>(columnName: 'Configuración', value: userWithConfiguration.configuration?.name),
          DataGridCell<int>(columnName: 'Puntos', value: userWithConfiguration.user.points),
          DataGridCell<DateTime>(columnName: 'CreateDate', value: userWithConfiguration.user.createdate),
          DataGridCell<String>(columnName: 'Dirección', value: userWithConfiguration.user.address),
          DataGridCell<String>(columnName: 'Hash transacción punto', value: userWithConfiguration.user.pointTransactionHash),
          DataGridCell<String>(columnName: 'Hash transacción rol', value: userWithConfiguration.user.roleTransactionHash),
          DataGridCell<String>(columnName: 'Hash transacción configuración', value: userWithConfiguration.user.configurationTransactionHash),
          DataGridCell<String>(columnName: 'Usuario ID', value: userWithConfiguration.user.userId),
          DataGridCell<String>(columnName: 'Región ID', value: userWithConfiguration.region?.regionId),
          DataGridCell<String>(columnName: 'Provincia ID', value: userWithConfiguration.location?.locationId),
          DataGridCell<String>(columnName: 'Municipio ID', value: userWithConfiguration.province?.provinceId),
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

  Widget _buildStandardContainer(String value) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.centerLeft,
      child: Text(value),
    );
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
      _buildStandardContainer(row.getCells()[1].value.toString()),
      _buildStandardContainer(row.getCells()[2].value.toString()),
      _buildStandardContainer(row.getCells()[3].value.toString()),
      _buildStandardContainer(row.getCells()[4].value.toString()),
      _buildEmail(row.getCells()[5].value),
      _buildPhone(row.getCells()[6].value),
      _buildRole(row.getCells()[7].value),
      _buildStandardContainer(row.getCells()[8].value.toString()),
      _buildStandardContainer(row.getCells()[9].value.toString()),
      _buildStandardContainer(row.getCells()[10].value.toString()),
      _buildPoint(row.getCells()[11].value),
      _buildStandardContainer(row.getCells()[12].value.toString()),
      _buildStandardContainer(row.getCells()[13].value.toString()),
      _buildDate(row.getCells()[14].value),
      _buildStandardContainer(row.getCells()[15].value.toString()),
      _buildStandardContainer(row.getCells()[16].value.toString()),
      _buildStandardContainer(row.getCells()[17].value.toString()),
      _buildStandardContainer(row.getCells()[18].value.toString()),
      _buildStandardContainer(row.getCells()[19].value.toString()),
      _buildStandardContainer(row.getCells()[20].value.toString()),
      _buildStandardContainer(row.getCells()[21].value.toString()),
      _buildStandardContainer(row.getCells()[22].value.toString()),
    ]);
  }

  setUsers(List<UserWithConfigurationAndPoint>? userData) {
    _users = userData;
  }

  List<UserWithConfigurationAndPoint>? getUsers() {
    return _users;
  }

  setRegions(List<Region> regionData) {
    _regions = regionData;
  }

  List<Region> getRegions() {
    return _regions;
  }

  setLocations(List<Location> locationData) {
    _locations = locationData;
  }

  List<Location> getLocations() {
    return _locations;
  }

  setProvinces(List<Province> provinceData) {
    _provinces = provinceData;
  }

  List<Province> getProvinces() {
    return _provinces;
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

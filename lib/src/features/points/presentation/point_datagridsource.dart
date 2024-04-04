/// Dart import
/// Packages import
import 'package:adminnut4health/src/features/regions/domain/region.dart';
import 'package:flutter/material.dart';

/// DataGrid import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../countries/domain/country.dart';
import '../../locations/domain/location.dart';
import '../../provinces/domain/province.dart';
import '../domain/pointWithProvinceAndCountry.dart';

/// Set point's data collection to data grid source.
class PointDataGridSource extends DataGridSource {
  /// Creates the point data source class with required details.
  PointDataGridSource(List<PointWithProvinceAndCountry> pointData,
      List<Province> provinceData,
      List<Country> countryData,
      List<Region> regionData,
      List<Location> locationData,
      ) {
    _points = pointData;
    _provinces = provinceData;
    _countries = countryData;
    _regions = regionData;
    _locations = locationData;
    buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = <DataGridRow>[];
  List<PointWithProvinceAndCountry>? _points = <PointWithProvinceAndCountry>[];
  List<Country> _countries = <Country>[];
  List<Region> _regions = <Region>[];
  List<Location> _locations = <Location>[];
  List<Province> _provinces = <Province>[];


  /// Building DataGridRows
  void buildDataGridRows() {
    if (_points != null && _points!.isNotEmpty) {
      _dataGridRows = _points!.map<DataGridRow>((PointWithProvinceAndCountry pointWithProvinceAndCountry) {
        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<String>(columnName: 'ID', value: pointWithProvinceAndCountry.point.pointId),
          DataGridCell<String>(columnName: 'Nombre', value: pointWithProvinceAndCountry.point.name),
          DataGridCell<String>(columnName: 'Nombre Punto', value: pointWithProvinceAndCountry.point.pointName),
          DataGridCell<String>(columnName: 'Código Punto', value: pointWithProvinceAndCountry.point.pointCode),
          DataGridCell<String>(columnName: 'Tipo', value: pointWithProvinceAndCountry.point.type),
          DataGridCell<String>(columnName: 'Código', value: pointWithProvinceAndCountry.point.phoneCode),
          DataGridCell<int>(columnName: 'Nº dígitos teléfono', value: pointWithProvinceAndCountry.point.phoneLength),
          DataGridCell<String>(columnName: 'País', value: pointWithProvinceAndCountry.country?.name),
          DataGridCell<String>(columnName: 'Región', value: pointWithProvinceAndCountry.region?.name),
          DataGridCell<String>(columnName: 'Provincia', value: pointWithProvinceAndCountry.location?.name),
          DataGridCell<String>(columnName: 'Municipio', value: pointWithProvinceAndCountry.province?.name),
          DataGridCell<bool>(columnName: 'Activo', value: pointWithProvinceAndCountry.point.active),
          DataGridCell<double>(columnName: 'Latitud', value: pointWithProvinceAndCountry.point.latitude),
          DataGridCell<double>(columnName: 'Longitud',  value: pointWithProvinceAndCountry.point.longitude),
          DataGridCell<String>(columnName: 'Idioma',  value: pointWithProvinceAndCountry.point.language),
          DataGridCell<int>(columnName: 'Casos', value: pointWithProvinceAndCountry.point.cases),
          DataGridCell<int>(columnName: 'Casos Normopeso', value: pointWithProvinceAndCountry.point.casesnormopeso),
          DataGridCell<int>(columnName: 'Casos Moderada', value: pointWithProvinceAndCountry.point.casesmoderada),
          DataGridCell<int>(columnName: 'Casos Severa', value: pointWithProvinceAndCountry.point.casessevera),
          DataGridCell<String>(columnName: 'Hash de transacción', value: pointWithProvinceAndCountry.point.transactionHash),
          DataGridCell<String>(columnName: 'País ID', value: pointWithProvinceAndCountry.country?.countryId),
          DataGridCell<String>(columnName: 'Región ID', value: pointWithProvinceAndCountry.region?.regionId),
          DataGridCell<String>(columnName: 'Provincia ID', value: pointWithProvinceAndCountry.location?.locationId),
          DataGridCell<String>(columnName: 'Municipio ID', value: pointWithProvinceAndCountry.province?.provinceId),
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


  final Map<String, Image> _images = <String, Image>{
    '✔': Image.asset('images/Perfect.png'),
    '✘': Image.asset('images/Insufficient.png'),
  };

  Widget _buildActive(bool value) {
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


  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(cells: <Widget>[
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
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[5].value.toString()),
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
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[9].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[10].value.toString()),
      ),
      _buildActive(row.getCells()[11].value),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
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
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[16].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[17].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[18].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[19].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[0].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[20].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[21].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[22].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[23].value.toString()),
      ),
    ]);
  }

  setPoints(List<PointWithProvinceAndCountry>? pointData) {
    _points = pointData;
  }

  List<PointWithProvinceAndCountry>? getPoints() {
    return _points;
  }

  setCountries(List<Country> countryData) {
    _countries = countryData;
  }

  List<Country>? getCountries() {
    return _countries;
  }

  setRegions(List<Region> regionData) {
    _regions = regionData;
  }

  List<Region>? getRegions() {
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


  /// Update DataSource
  void updateDataSource() {
    notifyListeners();
  }

}

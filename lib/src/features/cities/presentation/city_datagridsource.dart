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
import '../domain/CityWithProvinceAndCountry.dart';

/// Set city's data collection to data grid source.
class CityDataGridSource extends DataGridSource {
  /// Creates the city data source class with required details.
  CityDataGridSource(List<CityWithProvinceAndCountry> cityData,
      List<Province> provinceData,
      List<Location> locationData,
      List<Country> countryData,
      List<Region> regionData,
      ) {
    _cities = cityData;
    _provinces = provinceData;
    _locations = locationData;
    _countries = countryData;
    _regions = regionData;
    buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = <DataGridRow>[];
  List<CityWithProvinceAndCountry>? _cities = <CityWithProvinceAndCountry>[];
  List<Country> _countries = <Country>[];
  List<Region> _regions = <Region>[];
  List<Location> _locations = <Location>[];
  List<Province> _provinces = <Province>[];


  /// Building DataGridRows
  void buildDataGridRows() {
    if (_cities != null && _cities!.isNotEmpty) {
      _dataGridRows = _cities!.map<DataGridRow>((CityWithProvinceAndCountry cityWithProvinceAndCountry) {
        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<String>(columnName: 'ID', value: cityWithProvinceAndCountry.city.cityId),
          DataGridCell<String>(columnName: 'Nombre', value: cityWithProvinceAndCountry.city.name),
          DataGridCell<String>(columnName: 'País', value: cityWithProvinceAndCountry.country?.name),
          DataGridCell<String>(columnName: 'Región', value: cityWithProvinceAndCountry.region?.name),
          DataGridCell<String>(columnName: 'Provincia', value: cityWithProvinceAndCountry.location?.name),
          DataGridCell<String>(columnName: 'Municipio', value: cityWithProvinceAndCountry.province?.name),
          DataGridCell<bool>(columnName: 'Activo', value: cityWithProvinceAndCountry.city.active),
          DataGridCell<String>(columnName: 'País ID', value: cityWithProvinceAndCountry.country?.countryId),
          DataGridCell<String>(columnName: 'Región ID', value: cityWithProvinceAndCountry.region?.regionId),
          DataGridCell<String>(columnName: 'Provincia ID', value: cityWithProvinceAndCountry.location?.locationId),
          DataGridCell<String>(columnName: 'Municipio ID', value: cityWithProvinceAndCountry.province?.provinceId),
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
      _buildActive(row.getCells()[6].value),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[0].value.toString()),
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
    ]);
  }

  setCities(List<CityWithProvinceAndCountry>? cityData) {
    _cities = cityData;
  }

  List<CityWithProvinceAndCountry>? getCities() {
    return _cities;
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

  /// Update DataSource
  void updateDataSource() {
    notifyListeners();
  }

}

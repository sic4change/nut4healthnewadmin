/// Dart import
/// Packages import
import 'package:adminnut4health/src/features/regions/domain/region.dart';
import 'package:flutter/material.dart';

/// DataGrid import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../countries/domain/country.dart';
import '../../locations/domain/location.dart';
import '../domain/ProvinceWithCountryRegionAndLocation.dart';

/// Set province's data collection to data grid source.
class ProvinceDataGridSource extends DataGridSource {
  /// Creates the province data source class with required details.
  ProvinceDataGridSource(
      List<ProvinceWithCountryRegionAndLocation> provinceData,
      List<Country> countryData,
      List<Region> regionData,
      List<Location> locationData,
      ) {
    _provinces = provinceData;
    _countries = countryData;
    _regions = regionData;
    _locations = locationData;
    buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = <DataGridRow>[];
  List<ProvinceWithCountryRegionAndLocation>? _provinces = <ProvinceWithCountryRegionAndLocation>[];
  List<Country> _countries = <Country>[];
  List<Region> _regions = <Region>[];
  List<Location> _locations = <Location>[];

  /// Building DataGridRows
  void buildDataGridRows() {
    if (_provinces != null && _provinces!.isNotEmpty) {
      _dataGridRows = _provinces!.map<DataGridRow>((ProvinceWithCountryRegionAndLocation provinceWithCountry) {
        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<String>(columnName: 'ID', value: provinceWithCountry.province.provinceId),
          DataGridCell<String>(columnName: 'Nombre', value: provinceWithCountry.province.name),
          DataGridCell<String>(columnName: 'País', value: provinceWithCountry.country?.name),
          DataGridCell<String>(columnName: 'Región', value: provinceWithCountry.region?.name),
          DataGridCell<String>(columnName: 'Provincia', value: provinceWithCountry.location?.name),
          DataGridCell<bool>(columnName: 'Activo', value: provinceWithCountry.province.active),
          DataGridCell<String>(columnName: 'País ID', value: provinceWithCountry.country?.countryId),
          DataGridCell<String>(columnName: 'Región ID', value: provinceWithCountry.region?.regionId),
          DataGridCell<String>(columnName: 'Provincia ID', value: provinceWithCountry.location?.locationId),
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
      _buildActive(row.getCells()[5].value),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[0].value.toString()),
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
    ]);
  }

  setProvinces(List<ProvinceWithCountryRegionAndLocation>? provinceData) {
    _provinces = provinceData;
  }

  List<ProvinceWithCountryRegionAndLocation>? getProvinces() {
    return _provinces;
  }

  setCountries(List<Country> countryData) {
    _countries = countryData;
  }

  List<Country> getCountries() {
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

  /// Update DataSource
  void updateDataSource() {
    notifyListeners();
  }

}

/// Dart import
/// Packages import
import 'package:adminnut4health/src/features/regions/domain/region.dart';
import 'package:flutter/material.dart';

/// DataGrid import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../countries/domain/country.dart';
import '../domain/locationWithRegionAndCountry.dart';

/// Set city's data collection to data grid source.
class LocationDataGridSource extends DataGridSource {
  /// Creates the city data source class with required details.
  LocationDataGridSource(
      List<LocationWithRegionAndCountry> locationData,
      List<Country> countryData,
      List<Region> regionData,
      ) {
    _locations = locationData;
    _countries = countryData;
    _regions = regionData;
    buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = <DataGridRow>[];
  List<LocationWithRegionAndCountry>? _locations = <LocationWithRegionAndCountry>[];
  List<Country> _countries = <Country>[];
  List<Region> _regions = <Region>[];


  /// Building DataGridRows
  void buildDataGridRows() {
    if (_locations != null && _locations!.isNotEmpty) {
      _dataGridRows = _locations!.map<DataGridRow>((LocationWithRegionAndCountry locationWithRegionAndCountry) {
        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<String>(columnName: 'Id', value: locationWithRegionAndCountry.location.locationId),
          DataGridCell<String>(columnName: 'Nombre', value: locationWithRegionAndCountry.location.name),
          DataGridCell<String>(columnName: 'País', value: locationWithRegionAndCountry.country?.name),
          DataGridCell<String>(columnName: 'Región', value: locationWithRegionAndCountry.region?.name),
          DataGridCell<bool>(columnName: 'Activo', value: locationWithRegionAndCountry.location.active),
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
        child: Text(row.getCells()[0].value.toString()),
      ),
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
      _buildActive(row.getCells()[4].value)
    ]);
  }

  setLocations(List<LocationWithRegionAndCountry>? locationData) {
    _locations = locationData;
  }

  List<LocationWithRegionAndCountry>? getLocations() {
    return _locations;
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

  /// Update DataSource
  void updateDataSource() {
    notifyListeners();
  }

}

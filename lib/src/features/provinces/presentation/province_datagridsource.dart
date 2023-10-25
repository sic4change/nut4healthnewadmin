/// Dart import
/// Packages import
import 'package:adminnut4health/src/features/regions/domain/region.dart';
import 'package:flutter/material.dart';

/// DataGrid import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../countries/domain/country.dart';
import '../domain/ProvinceWithCountry.dart';

/// Set province's data collection to data grid source.
class ProvinceDataGridSource extends DataGridSource {
  /// Creates the province data source class with required details.
  ProvinceDataGridSource(
      List<ProvinceWithCountry> provinceData,
      List<Country> countryData,
      List<Region> regionData,
      ) {
    _provinces = provinceData;
    _countries = countryData;
    _regions = regionData;
    buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = <DataGridRow>[];
  List<ProvinceWithCountry>? _provinces = <ProvinceWithCountry>[];
  List<Country> _countries = <Country>[];
  List<Region> _regions = <Region>[];

  /// Building DataGridRows
  void buildDataGridRows() {
    if (_provinces != null && _provinces!.isNotEmpty) {
      _dataGridRows = _provinces!.map<DataGridRow>((ProvinceWithCountry provinceWithCountry) {
        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<String>(columnName: 'Id', value: provinceWithCountry.province.provinceId),
          DataGridCell<String>(columnName: 'Nombre', value: provinceWithCountry.province.name),
          DataGridCell<String>(columnName: 'País', value: provinceWithCountry.country?.name),
          DataGridCell<String>(columnName: 'Región', value: provinceWithCountry.region?.name),
          DataGridCell<bool>(columnName: 'Activo', value: provinceWithCountry.province.active),
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

  setProvinces(List<ProvinceWithCountry>? provinceData) {
    _provinces = provinceData;
  }

  List<ProvinceWithCountry>? getProvinces() {
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

  /// Update DataSource
  void updateDataSource() {
    notifyListeners();
  }

}

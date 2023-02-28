/// Dart import
/// Packages import
import 'package:flutter/material.dart';

/// DataGrid import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../countries/domain/country.dart';
import '../../provinces/domain/province.dart';
import '../domain/CityWithProvinceAndCountry.dart';

/// Set city's data collection to data grid source.
class CityDataGridSource extends DataGridSource {
  /// Creates the city data source class with required details.
  CityDataGridSource(List<CityWithProvinceAndCountry> cityData,
      List<Province> provinceData,
      List<Country> countryData) {
    _cities = cityData;
    _provinces = provinceData;
    _countries = countryData;
    buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = <DataGridRow>[];
  List<CityWithProvinceAndCountry>? _cities = <CityWithProvinceAndCountry>[];
  List<Country> _countries = <Country>[];
  List<Province> _provinces = <Province>[];


  /// Building DataGridRows
  void buildDataGridRows() {
    if (_cities != null && _cities!.isNotEmpty) {
      _dataGridRows = _cities!.map<DataGridRow>((CityWithProvinceAndCountry cityWithProvinceAndCountry) {
        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<String>(columnName: 'Id', value: cityWithProvinceAndCountry.city.cityId),
          DataGridCell<String>(columnName: 'Nombre', value: cityWithProvinceAndCountry.city.name),
          DataGridCell<String>(columnName: 'País', value: cityWithProvinceAndCountry.country?.name),
          DataGridCell<String>(columnName: 'Municipio', value: cityWithProvinceAndCountry.province?.name),
          DataGridCell<bool>(columnName: 'Activo', value: cityWithProvinceAndCountry.city.active),
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

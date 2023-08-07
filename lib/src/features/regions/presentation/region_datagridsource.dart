/// Dart import
/// Packages import
import 'package:flutter/material.dart';

/// DataGrid import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../countries/domain/country.dart';
import '../domain/region_full.dart';

/// Set region's data collection to data grid source.
class RegionDataGridSource extends DataGridSource {
  /// Creates the region data source class with required details.
  RegionDataGridSource(List<RegionFull> regionData, List<Country> countryData) {
    _regions = regionData;
    _countries = countryData;
    buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = <DataGridRow>[];
  List<RegionFull>? _regions = <RegionFull>[];
  List<Country> _countries = <Country>[];

  /// Building DataGridRows
  void buildDataGridRows() {
    if (_regions != null && _regions!.isNotEmpty) {
      _dataGridRows = _regions!.map<DataGridRow>((RegionFull regionWithCountry) {
        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<String>(columnName: 'Id', value: regionWithCountry.region.regionId),
          DataGridCell<String>(columnName: 'Nombre', value: regionWithCountry.region.name),
          DataGridCell<String>(columnName: 'País', value: regionWithCountry.country?.name),
          DataGridCell<bool>(columnName: 'Activo', value: regionWithCountry.region.active),
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
      _buildActive(row.getCells()[3].value)
    ]);
  }

  setRegions(List<RegionFull>? regionData) {
    _regions = regionData;
  }

  List<RegionFull>? getRegions() {
    return _regions;
  }

  setCountries(List<Country> countryData) {
    _countries = countryData;
  }

  List<Country> getCountries() {
    return _countries;
  }


  /// Update DataSource
  void updateDataSource() {
    notifyListeners();
  }

}

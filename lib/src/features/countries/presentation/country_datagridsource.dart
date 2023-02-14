
/// Packages import
import 'package:flutter/material.dart';

/// DataGrid import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../domain/country.dart';

/// Set country's data collection to data grid source.
class CountryDataGridSource extends DataGridSource {
  /// Creates the country data source class with required details.
  CountryDataGridSource(List<Country> countryData) {
    _countries = countryData;
    buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = <DataGridRow>[];
  List<Country>? _countries = <Country>[];

  /// Building DataGridRows
  void buildDataGridRows() {
    if (_countries != null && _countries!.isNotEmpty) {
      _dataGridRows = _countries!.map<DataGridRow>((Country country) {
        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<String>(columnName: 'Id', value: country.countryId),
          DataGridCell<String>(columnName: 'Nombre', value: country.name),
          DataGridCell<String>(columnName: 'Código', value: country.code),
          DataGridCell<bool>(columnName: 'Activo', value: country.active),
        ]);
      }).toList();
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

  final Map<String, Image> _images = <String, Image>{
    '✔': Image.asset('images/Perfect.png'),
    'x': Image.asset('images/Insufficient.png'),
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
        child: _getWidget(_images['x']!, ''),
      );
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

  setCountries(List<Country>? countryData) {
    _countries = countryData;
  }

  List<Country>? getCountries() {
    return _countries;
  }

  /// Update DataSource
  void updateDataSource() {
    notifyListeners();
  }

}

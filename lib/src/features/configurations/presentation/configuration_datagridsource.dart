
/// Packages import
import 'package:flutter/material.dart';

/// DataGrid import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../domain/configuration.dart';

/// Set configuration's data collection to data grid source.
class ConfigurationDataGridSource extends DataGridSource {
  /// Creates the configuration data source class with required details.
  ConfigurationDataGridSource(List<Configuration> configurationData) {
    _configurations = configurationData;
    buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = <DataGridRow>[];
  List<Configuration>? _configurations = <Configuration>[];

  /// Building DataGridRows
  void buildDataGridRows() {
    if (_configurations != null && _configurations!.isNotEmpty) {
      _dataGridRows = _configurations!.map<DataGridRow>((Configuration configuration) {
        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<String>(columnName: 'ID', value: configuration.id),
          DataGridCell<String>(columnName: 'Nombre', value: configuration.name),
          DataGridCell<String>(columnName: 'Moneda', value: configuration.money),
          DataGridCell<int>(columnName: 'Pago Confirmación', value: configuration.payByConfirmation),
          DataGridCell<int>(columnName: 'Pago Diagnóstico', value: configuration.payByDiagnosis),
          DataGridCell<int>(columnName: 'Punto Confirmación', value: configuration.pointByConfirmation),
          DataGridCell<int>(columnName: 'Punto Diagnóstico', value: configuration.pointsByDiagnosis),
          DataGridCell<int>(columnName: 'Pago Mensual', value: configuration.monthlyPayment),
          DataGridCell<int>(columnName: 'Configuración Blockchain', value: configuration.blockChainConfiguration),
          DataGridCell<String>(columnName: 'Hash', value: configuration.hash),
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
        child: Text(row.getCells()[0].value.toString()),
      ),
    ]);
  }

  setConfigurations(List<Configuration>? configurationData) {
    _configurations = configurationData;
  }

  List<Configuration>? getConfigurations() {
    return _configurations;
  }

  /// Update DataSource
  void updateDataSource() {
    notifyListeners();
  }

}

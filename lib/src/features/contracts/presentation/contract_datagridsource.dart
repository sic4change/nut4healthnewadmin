/// Dart import
import 'dart:math' as math;

import 'package:adminnut4health/src/features/points/domain/point.dart';
/// Packages import
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// DataGrid import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../../users/domain/user.dart';
import '../domain/ContractWithScreenerAndMedicalAndPoint.dart';

/// Set contracts's data collection to data grid source.
class ContractDataGridSource extends DataGridSource {
  /// Creates the contract data source class with required details.
  ContractDataGridSource(List<ContractWithScreenerAndMedicalAndPoint> contractData) {
    _contracts = contractData;
    buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = <DataGridRow>[];
  List<ContractWithScreenerAndMedicalAndPoint>? _contracts = <ContractWithScreenerAndMedicalAndPoint>[];

  /// Building DataGridRows
  void buildDataGridRows() {
    if (_contracts != null && _contracts!.isNotEmpty) {
      _dataGridRows = _contracts!.map<DataGridRow>(
              (ContractWithScreenerAndMedicalAndPoint contractWithScreenerAndMedicalAndPoint) {
        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<String>(columnName: 'Id', value: contractWithScreenerAndMedicalAndPoint.contract.contractId),
          DataGridCell<String>(columnName: 'Código', value: contractWithScreenerAndMedicalAndPoint.contract.code),
          DataGridCell<String>(columnName: 'Estado', value: contractWithScreenerAndMedicalAndPoint.contract.status),
          DataGridCell<double>(columnName: 'Perímetro braquial (cm)',
              value: contractWithScreenerAndMedicalAndPoint.contract.armCircunference == 0 ? null : contractWithScreenerAndMedicalAndPoint.contract.armCircunference),
          DataGridCell<double>(columnName: 'Perímetro braquial confirmado (cm)',
              value: contractWithScreenerAndMedicalAndPoint.contract.armCircumferenceMedical == 0 ? null : contractWithScreenerAndMedicalAndPoint.contract.armCircumferenceMedical),
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
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[4].value.toString()),
      ),
    ]);
  }

  setContracts(List<ContractWithScreenerAndMedicalAndPoint>? contractData) {
    _contracts = contractData;
  }

  List<ContractWithScreenerAndMedicalAndPoint>? getContracts() {
    return _contracts;
  }

  /// Update DataSource
  void updateDataSource() {
    notifyListeners();
  }

}

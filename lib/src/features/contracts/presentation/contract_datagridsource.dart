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
          DataGridCell<double>(columnName: 'Peso (kg)',
              value: contractWithScreenerAndMedicalAndPoint.contract.weight == 0 ? null : contractWithScreenerAndMedicalAndPoint.contract.weight),
          DataGridCell<double>(columnName: 'Altura (cm)',
              value: contractWithScreenerAndMedicalAndPoint.contract.height == 0 ? null : contractWithScreenerAndMedicalAndPoint.contract.height),
          DataGridCell<String>(columnName: 'Nombre', value: contractWithScreenerAndMedicalAndPoint.contract.childName),
          DataGridCell<String>(columnName: 'Apellidos', value: contractWithScreenerAndMedicalAndPoint.contract.childSurname),
          DataGridCell<String>(columnName: 'Sexo', value: contractWithScreenerAndMedicalAndPoint.contract.sex),
          DataGridCell<String>(columnName: 'Código Identificación', value: contractWithScreenerAndMedicalAndPoint.contract.childDNI),
          DataGridCell<String>(columnName: 'Madre, Padre o Tutor', value: contractWithScreenerAndMedicalAndPoint.contract.childTutor),
          DataGridCell<String>(columnName: 'Contacto', value: contractWithScreenerAndMedicalAndPoint.contract.childPhoneContract),
          DataGridCell<String>(columnName: 'Lugar', value: contractWithScreenerAndMedicalAndPoint.contract.childAddress),
          DataGridCell<DateTime>(columnName: 'Fecha', value: contractWithScreenerAndMedicalAndPoint.contract.creationDate == DateTime(0, 0, 0) ? null : contractWithScreenerAndMedicalAndPoint.contract.creationDate),
          DataGridCell<String>(columnName: 'Puesto Salud', value: contractWithScreenerAndMedicalAndPoint.point?.fullName ?? ""),
          DataGridCell<String>(columnName: 'Agente Salud', value: contractWithScreenerAndMedicalAndPoint.screener == null ? "" : "${contractWithScreenerAndMedicalAndPoint.screener?.name} ${contractWithScreenerAndMedicalAndPoint.screener?.surname}"),
          DataGridCell<String>(columnName: 'Servicio Salud', value: contractWithScreenerAndMedicalAndPoint.medical == null ? "" : "${contractWithScreenerAndMedicalAndPoint.medical?.name} ${contractWithScreenerAndMedicalAndPoint.medical?.surname}"),
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

  Widget _buildStatus(dynamic value) {
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
    if (value.toString() == 'DUPLICATED') {
      return const TextStyle(color: Colors.orange);
    } else if (value.toString() == 'REGISTERED') {
      return TextStyle(color: Colors.green);
    } else if (value.toString() == 'DERIVED') {
      return const TextStyle(color: Colors.red);
    } else if (value.toString() == 'ADMITTED') {
      return const TextStyle(color: Colors.purple);
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
      _buildStatus(row.getCells()[2].value.toString()),
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
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[11].value.toString()),
      ),
      _buildPhone(row.getCells()[12].value.toString()),
      _buildPoint(row.getCells()[13].value.toString()),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[14].value.toString()),
      ),
      _buildPoint(row.getCells()[15].value.toString()),
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

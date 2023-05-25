/// Dart import
import 'dart:math' as math;

/// Packages import
import 'package:flutter/material.dart';

/// DataGrid import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
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
                var desnutritionValue = 'Normopeso (NW)';
                if (contractWithScreenerAndMedicalAndPoint.contract.percentage! < 50) {
                  desnutritionValue = 'Normopeso (NW)';
                } else if (contractWithScreenerAndMedicalAndPoint.contract.percentage == 50) {
                  desnutritionValue = 'Desnutrición Aguda Moderada (MAM)';
                } else {
                  desnutritionValue =  'Desnutrición Aguda Severa (SAM)';
                }
        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<String>(columnName: 'Id', value: contractWithScreenerAndMedicalAndPoint.contract.contractId),
          DataGridCell<String>(columnName: 'Código', value: contractWithScreenerAndMedicalAndPoint.contract.code),
          DataGridCell<String>(columnName: 'Estado', value: contractWithScreenerAndMedicalAndPoint.contract.status),
          DataGridCell<String>(columnName: 'Desnutrición', value: desnutritionValue),
          DataGridCell<double>(columnName: 'Perímetro braquial (cm)',
              value: contractWithScreenerAndMedicalAndPoint.contract.armCircunference == 0 ? null : contractWithScreenerAndMedicalAndPoint.contract.armCircunference),
          DataGridCell<double>(columnName: 'Perímetro braquial confirmado (cm)',
              value: contractWithScreenerAndMedicalAndPoint.contract.armCircumferenceMedical == 0 ? null : contractWithScreenerAndMedicalAndPoint.contract.armCircumferenceMedical),
          DataGridCell<double>(columnName: 'Peso (kg)',
              value: contractWithScreenerAndMedicalAndPoint.contract.weight == 0 ? null : contractWithScreenerAndMedicalAndPoint.contract.weight),
          DataGridCell<double>(columnName: 'Altura (cm)',
              value: contractWithScreenerAndMedicalAndPoint.contract.height == 0 ? null : contractWithScreenerAndMedicalAndPoint.contract.height),
          DataGridCell<String>(columnName: 'Nombre', value: contractWithScreenerAndMedicalAndPoint.contract.childName?.replaceAll('ء', '\\u1574')),
          DataGridCell<String>(columnName: 'Apellidos', value: contractWithScreenerAndMedicalAndPoint.contract.childSurname?.replaceAll('ء', '\\u1574')),
          DataGridCell<String>(columnName: 'Sexo', value: contractWithScreenerAndMedicalAndPoint.contract.sex),
          DataGridCell<String>(columnName: 'Código Identificación', value: contractWithScreenerAndMedicalAndPoint.contract.childDNI),
          DataGridCell<String>(columnName: 'Madre, Padre o Tutor', value: contractWithScreenerAndMedicalAndPoint.contract.childTutor?.replaceAll('ء', '\\u1574')),
          DataGridCell<String>(columnName: 'Contacto', value: contractWithScreenerAndMedicalAndPoint.contract.childPhoneContract),
          DataGridCell<String>(columnName: 'Lugar', value: contractWithScreenerAndMedicalAndPoint.contract.childAddress?.replaceAll('ء', '\\u1574')),
          DataGridCell<DateTime>(columnName: 'Fecha', value: contractWithScreenerAndMedicalAndPoint.contract.creationDate == DateTime(0, 0, 0) ? null : contractWithScreenerAndMedicalAndPoint.contract.creationDate),
          DataGridCell<String>(columnName: 'Puesto Salud', value: contractWithScreenerAndMedicalAndPoint.point?.fullName?.replaceAll('ء', '\\u1574') ?? ""),
          DataGridCell<String>(columnName: 'Agente Salud', value: contractWithScreenerAndMedicalAndPoint.screener == null ? "" : "${contractWithScreenerAndMedicalAndPoint.screener?.name} ${contractWithScreenerAndMedicalAndPoint.screener?.surname}"),
          DataGridCell<String>(columnName: 'Servicio Salud', value: contractWithScreenerAndMedicalAndPoint.medical == null ? "" : "${contractWithScreenerAndMedicalAndPoint.medical?.name} ${contractWithScreenerAndMedicalAndPoint.medical?.surname}"),
          DataGridCell<DateTime>(columnName: 'Fecha Atención Médica', value: contractWithScreenerAndMedicalAndPoint.contract.medicalDate == DateTime(0, 0, 0) ? null : contractWithScreenerAndMedicalAndPoint.contract.medicalDate),
          DataGridCell<bool>(columnName: 'SMS Enviado', value: contractWithScreenerAndMedicalAndPoint.contract.smsSent ?? false),
          DataGridCell<String>(columnName: 'Duración', value: contractWithScreenerAndMedicalAndPoint.contract.duration ?? "0"),
          DataGridCell<String>(columnName: 'Hash transacción', value: contractWithScreenerAndMedicalAndPoint.contract.transactionHash),
          DataGridCell<String>(columnName: 'Hash transacción validada', value: contractWithScreenerAndMedicalAndPoint.contract.transactionValidateHash),
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

  Widget _buildDouble(dynamic value) {
    String valueString = value.toString();
    if (valueString == null || valueString.isEmpty || valueString == 'null') {
      return const Text("");
    } else {
      return Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(valueString),
      );
    }
  }

  Widget _buildDuration(dynamic value) {
    String valueString = value.toString();
    if (valueString == null || valueString.isEmpty || valueString == '0') {
      return const Text("");
    } else {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: _getWidget(const Icon(Icons.timer, size: 20), value),
      );
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

  Widget _buildDesnutritionStatus(dynamic value) {
    return Center(
      child: Text(
        value,
        style: _getDesnutritionStatusTextStyle(value),
        overflow: TextOverflow.ellipsis,
      ),
    );
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

  Widget _buildDate(dynamic value) {
    String valueString = value.toString();
    if (valueString == null || valueString.isEmpty || valueString == '1970-01-01 00:00:00.000') {
      return const Text("");
    } else {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: _getWidget(const Icon(Icons.calendar_month, size: 20), value.toString()),
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

  TextStyle _getDesnutritionStatusTextStyle(dynamic value) {
    if (value.toString() == 'Desnutrición Aguda Moderada (MAM)') {
      return const TextStyle(color: Colors.orange);
    } else if (value.toString() == 'Normopeso (NW)') {
      return TextStyle(color: Colors.green);
    } else if (value.toString() == 'Desnutrición Aguda Severa (SAM)') {
      return const TextStyle(color: Colors.red);
    }  else {
      return const TextStyle(color: Colors.orange);
    }
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

  final Map<String, Image> _images = <String, Image>{
    '✔': Image.asset('images/Perfect.png'),
    '✘': Image.asset('images/Insufficient.png'),
  };

  Widget _buildSMSSent(bool value) {
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
      _buildDesnutritionStatus(row.getCells()[3].value.toString()),
      _buildDouble(row.getCells()[4].value),
      _buildDouble(row.getCells()[5].value),
      _buildDouble(row.getCells()[6].value),
      _buildDouble(row.getCells()[7].value),
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
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[12].value.toString()),
      ),
      _buildPhone(row.getCells()[13].value.toString()),
      _buildPoint(row.getCells()[14].value.toString()),
      _buildDate(row.getCells()[15].value.toString()),
      _buildPoint(row.getCells()[16].value.toString()),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[17].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[18].value.toString()),
      ),
      _buildDate(row.getCells()[19].value.toString()),
      _buildSMSSent(row.getCells()[20].value),
      _buildDuration(row.getCells()[21].value.toString()),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[22].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[23].value.toString()),
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

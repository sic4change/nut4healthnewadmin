/// Dart import
import 'dart:math' as math;

import 'package:adminnut4health/src/features/contracts/domain/contract.dart';
import 'package:adminnut4health/src/features/contracts/presentation/contracts_screen_controller.dart';
/// Packages import
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// DataGrid import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../../users/domain/user.dart';
import '../domain/ContractWithScreenerAndMedicalAndPoint.dart';

/// Set contracts's data collection to data grid source.
class ContractDataGridSource extends DataGridSource {

  dynamic newCellValue;

  /// Helps to control the editable text in the [TextField] widget.
  TextEditingController editingController = TextEditingController();

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
                  desnutritionValue = 'Desnutrición Aguda Severa (SAM)';
                }
        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<String>(columnName: 'ID', value: contractWithScreenerAndMedicalAndPoint.contract.contractId),
          DataGridCell<String>(columnName: 'Código', value: contractWithScreenerAndMedicalAndPoint.contract.code),
          DataGridCell<String>(columnName: 'FEFA', value: contractWithScreenerAndMedicalAndPoint.contract.isFEFA! ? '✔' : '✘'),
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
          DataGridCell<DateTime>(columnName: 'Fecha nacimiento', value: contractWithScreenerAndMedicalAndPoint.contract.childBirthdate == DateTime(0, 0, 0) ? null :contractWithScreenerAndMedicalAndPoint.contract.childBirthdate),
          DataGridCell<String>(columnName: 'Código Identificación', value: contractWithScreenerAndMedicalAndPoint.contract.childDNI),
          DataGridCell<String>(columnName: 'Madre, Padre o Tutor', value: contractWithScreenerAndMedicalAndPoint.contract.childTutor?.replaceAll('ء', '\\u1574')),
          DataGridCell<DateTime>(columnName: 'Fecha nacimiento tutor', value: contractWithScreenerAndMedicalAndPoint.contract.tutorBirthdate == DateTime(0, 0, 0) ? null :contractWithScreenerAndMedicalAndPoint.contract.tutorBirthdate),
          DataGridCell<String>(columnName: 'Código Identificación tutor', value: contractWithScreenerAndMedicalAndPoint.contract.tutorDNI),
          DataGridCell<String>(columnName: 'Estado tutor', value: contractWithScreenerAndMedicalAndPoint.contract.tutorStatus),
          DataGridCell<int>(columnName: 'Semanas embarazo', value: contractWithScreenerAndMedicalAndPoint.contract.weeks == 0 ? null : contractWithScreenerAndMedicalAndPoint.contract.weeks),
          DataGridCell<String>(columnName: 'Hijo/a menor a 6 meses', value: contractWithScreenerAndMedicalAndPoint.contract.childMinor == null ? '' : (contractWithScreenerAndMedicalAndPoint.contract.childMinor != null &&  contractWithScreenerAndMedicalAndPoint.contract.childMinor == false) ? '✘' : '✔'),
          DataGridCell<String>(columnName: 'Contacto', value: contractWithScreenerAndMedicalAndPoint.contract.childPhoneContract),
          DataGridCell<String>(columnName: 'Lugar', value: contractWithScreenerAndMedicalAndPoint.contract.childAddress?.replaceAll('ء', '\\u1574')),
          DataGridCell<DateTime>(columnName: 'Fecha', value: contractWithScreenerAndMedicalAndPoint.contract.creationDate == DateTime(0, 0, 0) ? null : contractWithScreenerAndMedicalAndPoint.contract.creationDate),
          DataGridCell<String>(columnName: 'Puesto Salud', value: contractWithScreenerAndMedicalAndPoint.point?.name.replaceAll('ء', '\\u1574') ?? ""),
          DataGridCell<String>(columnName: 'Agente Salud', value: contractWithScreenerAndMedicalAndPoint.screener == null ? "" : "${contractWithScreenerAndMedicalAndPoint.screener?.name} ${contractWithScreenerAndMedicalAndPoint.screener?.surname}"),
          DataGridCell<String>(columnName: 'Servicio Salud', value: contractWithScreenerAndMedicalAndPoint.medical == null ? "" : "${contractWithScreenerAndMedicalAndPoint.medical?.name} ${contractWithScreenerAndMedicalAndPoint.medical?.surname}"),
          DataGridCell<DateTime>(columnName: 'Fecha Atención Médica', value: contractWithScreenerAndMedicalAndPoint.contract.medicalDate == DateTime(0, 0, 0) ? null : contractWithScreenerAndMedicalAndPoint.contract.medicalDate),
          DataGridCell<bool>(columnName: 'SMS Enviado', value: contractWithScreenerAndMedicalAndPoint.contract.smsSent ?? false),
          DataGridCell<String>(columnName: 'Duración', value: contractWithScreenerAndMedicalAndPoint.contract.duration ?? "0"),
          DataGridCell<String>(columnName: 'Hash transacción', value: contractWithScreenerAndMedicalAndPoint.contract.transactionHash),
          DataGridCell<String>(columnName: 'Hash transacción validada', value: contractWithScreenerAndMedicalAndPoint.contract.transactionValidateHash),
          DataGridCell<bool>(columnName: 'Validación Médico Jefe', value: contractWithScreenerAndMedicalAndPoint.contract.chefValidation),
          DataGridCell<bool>(columnName: 'Validación Dirección Regional', value: contractWithScreenerAndMedicalAndPoint.contract.regionalValidation),
          DataGridCell<String>(columnName: 'Servicio Salud ID', value: contractWithScreenerAndMedicalAndPoint.contract.medicalId),
          DataGridCell<String>(columnName: 'Agente Salud ID', value: contractWithScreenerAndMedicalAndPoint.contract.screenerId),
          DataGridCell<String>(columnName: 'Punto ID', value: contractWithScreenerAndMedicalAndPoint.point?.pointId),
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

  Widget _buildDate(dynamic value) {
    String valueString = value.toString();
    if (valueString == null || valueString.isEmpty || valueString == '1970-01-01 00:00:00.000'
    || valueString == '-0001-11-30 00:00:00.000') {
      return const Text("");
    } else {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: _getWidget(const Icon(Icons.calendar_month, size: 20), value.toString()),
      );
    }
  }

  Widget _buildBirthDate(dynamic value) {
    String valueString = value.toString();
    if (valueString == null || valueString.isEmpty || valueString == '1970-01-01 00:00:00.000'
        || valueString == '-0001-11-30 00:00:00.000') {
      return const Text("");
    } else {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: _getWidget(const Icon(Icons.calendar_month, size: 20), value.toString().replaceAll(' 00:00:00.000', '')),
      );
    }
  }


  Widget _buildBoolean(bool value) {
    final Map<String, Image> images = <String, Image>{
      '✔': Image.asset('images/Perfect.png'),
      '✘': Image.asset('images/Insufficient.png'),
    };

    if (value) {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: _getWidget(images['✔']!, ''),
      );
    } else  {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: _getWidget(images['✘']!, ''),
      );
    }
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

  Widget _buildInt(dynamic value) {
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
      _buildBoolean(row.getCells()[31].value),
      _buildBoolean(row.getCells()[32].value),
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
      _buildDesnutritionStatus(row.getCells()[4].value.toString()),
      _buildDouble(row.getCells()[5].value),
      _buildDouble(row.getCells()[6].value),
      _buildDouble(row.getCells()[7].value),
      _buildDouble(row.getCells()[8].value),
      User.currentRole != 'donante' ? Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: Text(row.getCells()[9].value.toString()),
        ) : Container(padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: const Text('---------'),
      ),
    User.currentRole != 'donante' ? Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[10].value.toString()),
      ) : Container(padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: const Text('---------'),
    ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[11].value.toString()),
      ),
      _buildBirthDate(row.getCells()[12].value),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[13].value.toString()),
      ),
      User.currentRole != 'donante' ? Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[14].value.toString()),
      ) : Container(padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: const Text('---------'),
      ),
      _buildBirthDate(row.getCells()[15].value),
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
      _buildInt(row.getCells()[18].value),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[19].value.toString()),
      ),
      _buildPhone(row.getCells()[20].value.toString()),
      //_buildPoint(row.getCells()[21].value.toString()),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[21].value.toString()),
      ),
      /*if (row.getCells()[21].columnName == 'Lugar')
        Consumer(
          builder: (context, ref, _) {
            final contractsController = ref.watch(contractsScreenControllerProvider.notifier);
            return TextField(
              controller: TextEditingController(text: row.getCells()[21].value.toString()),
              onSubmitted: (newValue) async {
                await contractsController.updateLocalizationContract(row.getCells()[0].value.toString(), newValue);
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(8.0),
              ),
            );
          }
        ),*/
      _buildDate(row.getCells()[22].value.toString()),
      _buildPoint(row.getCells()[23].value.toString()),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[24].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[25].value.toString()),
      ),
      _buildDate(row.getCells()[26].value.toString()),
      _buildSMSSent(row.getCells()[27].value),
      _buildDuration(row.getCells()[28].value.toString()),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[29].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[30].value.toString()),
      ),
      _buildStandardContainer(row.getCells()[0].value),
      _buildStandardContainer(row.getCells()[33].value),
      _buildStandardContainer(row.getCells()[34].value),
      _buildStandardContainer(row.getCells()[35].value),
    ]);
  }

  Widget _buildStandardContainer(String value) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.centerLeft,
      child: Text(value),
    );
  }

  @override
  Future<void> onCellSubmit(DataGridRow row, RowColumnIndex rowColumnIndex, GridColumn column) async {
    if (column.columnName == 'Lugar') {
      final int rowIndex = rowColumnIndex.rowIndex - 1; // Ajusta el índice si es necesario
      final String newValue = row.getCells()[23].value.toString(); // Obtiene el nuevo valor

      var contract = _contracts![rowIndex];
      var updatedContract = contract.contract.copyWith(childAddress: newValue);
      contract.contract = updatedContract;

      // Actualiza la lista de contratos
      _contracts![rowIndex] = contract;

      // Reconstruye las filas de datos para reflejar el cambio
      buildDataGridRows();
      notifyListeners();
    }
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


/// Packages import
import 'package:adminnut4health/src/features/visitsWithoutDiagnosis/domain/visitWithoutDiagnosisCombined.dart';
import 'package:flutter/material.dart';

/// DataGrid import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../users/domain/user.dart';

/// Set visit's data collection to data grid source.
class VisitWithoutDiagnosisDataGridSource extends DataGridSource {
  /// Creates the visit data source class with required details.
  VisitWithoutDiagnosisDataGridSource(List<VisitWithoutDiagnosisCombined> visitData) {
    _visits = visitData;
    buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = <DataGridRow>[];
  List<VisitWithoutDiagnosisCombined>? _visits = <VisitWithoutDiagnosisCombined>[];

  /// Building DataGridRows
  void buildDataGridRows() {
    if (_visits != null && _visits!.isNotEmpty) {
      _dataGridRows = _visits!.map<DataGridRow>((VisitWithoutDiagnosisCombined visitCombined) {
        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<String>(columnName: 'ID', value: visitCombined.visitWithoutDiagnosis.id),
          DataGridCell<String>(columnName: 'Punto', value: visitCombined.point?.name??""),
          DataGridCell<String>(columnName: 'Madre, padre o tutor', value: visitCombined.tutor?.name?? ""),
          DataGridCell<String>(columnName: 'Niño/a', value: visitCombined.child?.name?? ""),
          DataGridCell<DateTime>(columnName: 'Fecha de alta', value: visitCombined.visitWithoutDiagnosis.createDate),
          DataGridCell<double>(columnName: 'Altura (cm)', value: visitCombined.visitWithoutDiagnosis.height),
          DataGridCell<double>(columnName: 'Peso (kg)', value: visitCombined.visitWithoutDiagnosis.weight),
          DataGridCell<double>(columnName: 'IMC', value: visitCombined.visitWithoutDiagnosis.imc),
          DataGridCell<double>(columnName: 'Perímetro braquial (cm)', value: visitCombined.visitWithoutDiagnosis.armCircunference),
          DataGridCell<String>(columnName: 'Observaciones', value: visitCombined.visitWithoutDiagnosis.observations),
          DataGridCell<String>(columnName: 'Punto ID', value: visitCombined.visitWithoutDiagnosis.pointId),
          DataGridCell<String>(columnName: 'Madre, padre o tutor ID', value: visitCombined.visitWithoutDiagnosis.tutorId),
          DataGridCell<String>(columnName: 'Niño/a ID', value: visitCombined.visitWithoutDiagnosis.childId),
          DataGridCell<bool>(columnName: 'FEFA', value: visitCombined.visitWithoutDiagnosis.fefaId.isNotEmpty),
          DataGridCell<bool>(columnName: 'Validación Médico Jefe', value: visitCombined.visitWithoutDiagnosis.chefValidation),
          DataGridCell<bool>(columnName: 'Validación Dirección Regional', value: visitCombined.visitWithoutDiagnosis.regionalValidation),
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
      _buildBoolean(row.getCells()[13].value),
      _buildBoolean(row.getCells()[14].value),
      _buildBoolean(row.getCells()[15].value),
      _buildStandardContainer(row.getCells()[1].value.toString()),
      _buildStandardContainer(row.getCells()[2].value.toString()),
      _buildStandardContainer(row.getCells()[3].value.toString()),
      _buildDate(row.getCells()[4].value),
      _buildStandardContainer(row.getCells()[5].value.toString()),
      _buildStandardContainer(row.getCells()[6].value.toString()),
      _buildStandardContainer(row.getCells()[7].value.toString()),
      _buildStandardContainer(row.getCells()[8].value.toString()),
      _buildStandardContainer(row.getCells()[9].value.toString()),
      _buildStandardContainer(row.getCells()[0].value.toString()),
      _buildStandardContainer(row.getCells()[10].value.toString()),
      _buildStandardContainer(row.getCells()[11].value.toString()),
      _buildStandardContainer(row.getCells()[12].value.toString()),
    ]);
  }

  setVisitsWithoutDiagnosis(List<VisitWithoutDiagnosisCombined>? visitData) {
    _visits = visitData;
  }

  List<VisitWithoutDiagnosisCombined>? getVisitsWithoutDiagnosis() {
    return _visits;
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

  /// Update DataSource
  void updateDataSource() {
    notifyListeners();
  }

  final Map<String, Image> _images = <String, Image>{
    '✔': Image.asset('images/Perfect.png'),
    '✘': Image.asset('images/Insufficient.png'),
  };

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

  Widget _buildStandardContainer(String value) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.centerLeft,
      child: Text(value),
    );
  }
}


/// Packages import
import 'package:adminnut4health/src/features/symptoms/domain/symptom.dart';
import 'package:adminnut4health/src/features/treatments/domain/treatment.dart';
import 'package:adminnut4health/src/features/visits/domain/visitCombined.dart';
import 'package:flutter/material.dart';

/// DataGrid import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

/// Set visit's data collection to data grid source.
class VisitDataGridSource extends DataGridSource {
  /// Creates the visit data source class with required details.
  VisitDataGridSource(List<VisitCombined> visitData) {
    _visits = visitData;
    buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = <DataGridRow>[];
  List<VisitCombined>? _visits = <VisitCombined>[];

  /// Building DataGridRows
  void buildDataGridRows() {
    if (_visits != null && _visits!.isNotEmpty) {
      _dataGridRows = _visits!.map<DataGridRow>((VisitCombined visitCombined) {
        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<String>(columnName: 'Id', value: visitCombined.visit.visitId),
          DataGridCell<String>(columnName: 'Punto', value: visitCombined.point?.name??""),
          DataGridCell<String>(columnName: 'Madre, padre o tutor', value: visitCombined.tutor?.name?? ""),
          DataGridCell<String>(columnName: 'Niño/a', value: visitCombined.child?.name?? ""),
          DataGridCell<String>(columnName: 'Caso', value: visitCombined.myCase?.name?? ""),
          DataGridCell<DateTime>(columnName: 'Fecha de alta', value: visitCombined.visit.createDate),
          DataGridCell<double>(columnName: 'Altura (cm)', value: visitCombined.visit.height),
          DataGridCell<double>(columnName: 'Peso (kg)', value: visitCombined.visit.weight),
          DataGridCell<double>(columnName: 'IMC', value: visitCombined.visit.imc),
          DataGridCell<double>(columnName: 'Perímetro braquial (cm)', value: visitCombined.visit.armCircunference),
          DataGridCell<String>(columnName: 'Estado', value: visitCombined.visit.status),
          DataGridCell<String>(columnName: 'Edema', value: visitCombined.visit.edema),
          DataGridCell<bool>(columnName: 'Vacunado del sarampión', value: visitCombined.visit.measlesVaccinated),
          DataGridCell<bool>(columnName: 'Programa de vacunación Vitamina A', value: visitCombined.visit.vitamineAVaccinated),
          DataGridCell<String>(columnName: 'Síntomas (ES)', value: _symptomsESString(visitCombined.visit.symptoms)),
          DataGridCell<String>(columnName: 'Síntomas (EN)', value: _symptomsENString(visitCombined.visit.symptoms)),
          DataGridCell<String>(columnName: 'Síntomas (FR)', value: _symptomsFRString(visitCombined.visit.symptoms)),
          DataGridCell<String>(columnName: 'Tratamientos (ES)', value: _treatmentsES(visitCombined.visit.treatments)),
          DataGridCell<String>(columnName: 'Tratamientos (EN)', value: _treatmentsEN(visitCombined.visit.treatments)),
          DataGridCell<String>(columnName: 'Tratamientos (FR)', value: _treatmentsFR(visitCombined.visit.treatments)),
          DataGridCell<String>(columnName: 'Observaciones', value: visitCombined.visit.observations),
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
      _buildStandardContainer(row.getCells()[1].value.toString()),
      _buildStandardContainer(row.getCells()[2].value.toString()),
      _buildStandardContainer(row.getCells()[3].value.toString()),
      _buildStandardContainer(row.getCells()[4].value.toString()),
      _buildDate(row.getCells()[5].value),
      _buildStandardContainer(row.getCells()[6].value.toString()),
      _buildStandardContainer(row.getCells()[7].value.toString()),
      _buildStandardContainer(row.getCells()[8].value.toString()),
      _buildStandardContainer(row.getCells()[9].value.toString()),
      _buildStandardContainer(row.getCells()[10].value.toString()),
      _buildStandardContainer(row.getCells()[11].value.toString()),
      _buildBoolean(row.getCells()[12].value),
      _buildBoolean(row.getCells()[13].value),
      _buildStandardContainer(row.getCells()[14].value.toString()),
      _buildStandardContainer(row.getCells()[15].value.toString()),
      _buildStandardContainer(row.getCells()[16].value.toString()),
      _buildStandardContainer(row.getCells()[17].value.toString()),
      _buildStandardContainer(row.getCells()[18].value.toString()),
      _buildStandardContainer(row.getCells()[19].value.toString()),
      _buildStandardContainer(row.getCells()[20].value.toString()),
    ]);
  }

  setVisits(List<VisitCombined>? visitData) {
    _visits = visitData;
  }

  List<VisitCombined>? getVisits() {
    return _visits;
  }

  /// Update DataSource
  void updateDataSource() {
    notifyListeners();
  }

  final Map<String, Image> _images = <String, Image>{
    '✔': Image.asset('images/Perfect.png'),
    '✘': Image.asset('images/Insufficient.png'),
  };

  Widget _buildBoolean(bool value) {
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

  String _symptomsESString(List<Symptom> value){
    var symptoms = "";

    for (var symptom in value) {
      symptoms = "$symptoms${symptom.name}, ";
    }

    if (symptoms.contains(", ")) {
      symptoms = symptoms.substring(0, symptoms.lastIndexOf(", "));
    }

    return symptoms;
  }

  String _symptomsENString(List<Symptom> value){
    var symptoms = "";

    for (var symptom in value) {
      symptoms = "$symptoms${symptom.nameEn}, ";
    }

    if (symptoms.contains(", ")) {
      symptoms = symptoms.substring(0, symptoms.lastIndexOf(", "));
    }

    return symptoms;
  }

  String _symptomsFRString(List<Symptom> value){
    var symptoms = "";

    for (var symptom in value) {
      symptoms = "$symptoms${symptom.nameFr}, ";
    }

    if (symptoms.contains(", ")) {
      symptoms = symptoms.substring(0, symptoms.lastIndexOf(", "));
    }

    return symptoms;
  }

  String _treatmentsES(List<Treatment> value){
    var treatments = "";

    for (var treatment in value) {
      treatments = "$treatments${treatment.name}, ";
    }

    if (treatments.contains(", ")) {
      treatments = treatments.substring(0, treatments.lastIndexOf(", "));
    }

    return treatments;
  }

  String _treatmentsEN(List<Treatment> value){
    var treatments = "";

    for (var treatment in value) {
      treatments = "$treatments${treatment.nameEn}, ";
    }

    if (treatments.contains(", ")) {
      treatments = treatments.substring(0, treatments.lastIndexOf(", "));
    }

    return treatments;
  }

  String _treatmentsFR(List<Treatment> value){
    var treatments = "";

    for (var treatment in value) {
      treatments = "$treatments${treatment.nameFr}, ";
    }

    if (treatments.contains(", ")) {
      treatments = treatments.substring(0, treatments.lastIndexOf(", "));
    }

    return treatments;
  }

  Widget _buildStandardContainer(String value) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.centerLeft,
      child: Text(value),
    );
  }
}

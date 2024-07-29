
/// Packages import
import 'package:adminnut4health/src/features/complications/domain/complication.dart';
import 'package:adminnut4health/src/features/visits/domain/visitCombined.dart';
import 'package:flutter/material.dart';

/// DataGrid import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../users/domain/user.dart';

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
          DataGridCell<String>(columnName: 'ID', value: visitCombined.visit.visitId),
          DataGridCell<String>(columnName: 'Punto', value: visitCombined.point?.name??""),
          DataGridCell<String>(columnName: 'Madre, padre o tutor', value: visitCombined.tutor?.name?? ""),
          DataGridCell<String>(columnName: 'Niño/a', value: visitCombined.child?.name?? ""),
          DataGridCell<String>(columnName: 'Caso', value: visitCombined.myCase?.name?? ""),
          DataGridCell<String>(columnName: 'Admisión', value: visitCombined.visit.admission),
          DataGridCell<DateTime>(columnName: 'Fecha de alta', value: visitCombined.visit.createDate),
          DataGridCell<double>(columnName: 'Altura (cm)', value: visitCombined.visit.height),
          DataGridCell<double>(columnName: 'Peso (kg)', value: visitCombined.visit.weight),
          DataGridCell<double>(columnName: 'IMC', value: visitCombined.visit.imc),
          DataGridCell<double>(columnName: 'Perímetro braquial (cm)', value: visitCombined.visit.armCircunference),
          DataGridCell<String>(columnName: 'Estado', value: visitCombined.visit.status),
          DataGridCell<String>(columnName: 'Edema', value: visitCombined.visit.edema),
          DataGridCell<String>(columnName: 'Respiración', value: visitCombined.visit.respiratonStatus),
          DataGridCell<String>(columnName: 'Apetito', value: visitCombined.visit.appetiteTest),
          DataGridCell<String>(columnName: 'Infección', value: visitCombined.visit.infection),
          DataGridCell<String>(columnName: 'Deficiencia ojos', value: visitCombined.visit.eyesDeficiency),
          DataGridCell<String>(columnName: 'Deshidratación', value: visitCombined.visit.deshidratation),
          DataGridCell<String>(columnName: 'Vómitos', value: visitCombined.visit.vomiting),
          DataGridCell<String>(columnName: 'Diarrea', value: visitCombined.visit.diarrhea),
          DataGridCell<String>(columnName: 'Fiebre', value: visitCombined.visit.fever),
          DataGridCell<String>(columnName: 'Temperatura', value: visitCombined.visit.temperature),
          DataGridCell<String>(columnName: 'Tos', value: visitCombined.visit.cough),
          DataGridCell<String>(columnName: 'Carta de vacunación', value: visitCombined.visit.vaccinationCard),
          DataGridCell<String>(columnName: 'Vacunación rubéola', value: visitCombined.visit.rubeolaVaccinated),
          DataGridCell<String>(columnName: 'Programa de vacunación Vitamina A', value: visitCombined.visit.vitamineAVaccinated),
          DataGridCell<String>(columnName: 'Vacunación Ácido fólico y Hierro', value: visitCombined.visit.acidfolicAndFerroVaccinated),
          DataGridCell<String>(columnName: 'Amoxicilina', value: visitCombined.visit.amoxicilina),
          DataGridCell<String>(columnName: 'Otros tratamientos', value: visitCombined.visit.otherTratments),
          DataGridCell<String>(columnName: 'Complicaciones (ES)', value: _complicationsESString(visitCombined.visit.complications)),
          DataGridCell<String>(columnName: 'Complicaciones (EN)', value: _complicationsENString(visitCombined.visit.complications)),
          DataGridCell<String>(columnName: 'Complicaciones (FR)', value: _complicationsFRString(visitCombined.visit.complications)),
          DataGridCell<String>(columnName: 'Observaciones', value: visitCombined.visit.observations),
          DataGridCell<bool>(columnName: 'Validación Médico Jefe', value: visitCombined.visit.chefValidation),
          DataGridCell<bool>(columnName: 'Validación Dirección Regional', value: visitCombined.visit.regionalValidation),
          DataGridCell<String>(columnName: 'Caso ID', value: visitCombined.visit.caseId),
          DataGridCell<String>(columnName: 'Punto ID', value: visitCombined.visit.pointId),
          DataGridCell<String>(columnName: 'Madre, padre o tutor ID', value: visitCombined.visit.tutorId),
          DataGridCell<String>(columnName: 'Niño/a ID', value: visitCombined.visit.childId),
          DataGridCell<bool>(columnName: 'FEFA', value: visitCombined.myCase!.fefaId.isNotEmpty),
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
      _buildBoolean(row.getCells()[39].value),
      _buildBoolean(row.getCells()[33].value),
      _buildBoolean(row.getCells()[34].value),
      _buildStandardContainer(row.getCells()[1].value.toString()),
      /* User.currentRole != 'donante' ? Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[2].value.toString()),
      ) : */ Container(padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: const Text('---------'),
      ),
      /*User.currentRole != 'donante' ? Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[3].value.toString()),
      ) : */ Container(padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: const Text('---------'),
      ),
      _buildStandardContainer(row.getCells()[4].value.toString()),
      _buildStandardContainer(row.getCells()[5].value.toString()),
      _buildDate(row.getCells()[6].value),
      _buildStandardContainer(row.getCells()[7].value.toString()),
      _buildStandardContainer(row.getCells()[8].value.toString()),
      _buildStandardContainer(row.getCells()[9].value.toString()),
      _buildStandardContainer(row.getCells()[10].value.toString()),
      _buildStandardContainer(row.getCells()[11].value.toString()),
      _buildStandardContainer(row.getCells()[12].value.toString()),
      _buildStandardContainer(row.getCells()[13].value.toString()),
      _buildStandardContainer(row.getCells()[14].value.toString()),
      _buildStandardContainer(row.getCells()[15].value.toString()),
      _buildStandardContainer(row.getCells()[16].value.toString()),
      _buildStandardContainer(row.getCells()[17].value.toString()),
      _buildStandardContainer(row.getCells()[18].value.toString()),
      _buildStandardContainer(row.getCells()[19].value.toString()),
      _buildStandardContainer(row.getCells()[20].value.toString()),
      _buildStandardContainer(row.getCells()[21].value.toString()),
      _buildStandardContainer(row.getCells()[22].value.toString()),
      _buildStandardContainer(row.getCells()[23].value),
      _buildStandardContainer(row.getCells()[24].value.toString()),
      _buildStandardContainer(row.getCells()[25].value.toString()),
      _buildStandardContainer(row.getCells()[26].value.toString()),
      _buildStandardContainer(row.getCells()[27].value.toString()),
      _buildStandardContainer(row.getCells()[28].value.toString()),
      _buildStandardContainer(row.getCells()[29].value.toString()),
      _buildStandardContainer(row.getCells()[30].value.toString()),
      _buildStandardContainer(row.getCells()[31].value.toString()),
      _buildStandardContainer(row.getCells()[32].value.toString()),
      _buildStandardContainer(row.getCells()[0].value.toString()),
      _buildStandardContainer(row.getCells()[35].value.toString()),
      _buildStandardContainer(row.getCells()[36].value.toString()),
      _buildStandardContainer(row.getCells()[37].value.toString()),
      _buildStandardContainer(row.getCells()[38].value.toString()),
    ]);
  }

  setVisits(List<VisitCombined>? visitData) {
    _visits = visitData;
  }

  List<VisitCombined>? getVisits() {
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

  String _complicationsESString(List<Complication> value){
    var complications = "";

    for (var complication in value) {
      complications = "$complications${complication.name}, ";
    }

    if (complications.contains(", ")) {
      complications = complications.substring(0, complications.lastIndexOf(", "));
    }

    return complications;
  }

  String _complicationsENString(List<Complication> value){
    var complications = "";

    for (var complication in value) {
      complications = "$complications${complication.nameEn}, ";
    }

    if (complications.contains(", ")) {
      complications = complications.substring(0, complications.lastIndexOf(", "));
    }

    return complications;
  }

  String _complicationsFRString(List<Complication> value){
    var complications = "";

    for (var complication in value) {
      complications = "$complications${complication.nameFr}, ";
    }

    if (complications.contains(", ")) {
      complications = complications.substring(0, complications.lastIndexOf(", "));
    }

    return complications;
  }

  Widget _buildStandardContainer(String value) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.centerLeft,
      child: Text(value),
    );
  }
}

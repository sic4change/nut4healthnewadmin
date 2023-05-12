
/// Packages import
import 'package:adminnut4health/src/features/tutors/domain/tutorWithPoint.dart';
import 'package:flutter/material.dart';

/// DataGrid import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

/// Set tutor's data collection to data grid source.
class TutorDataGridSource extends DataGridSource {
  /// Creates the tutor data source class with required details.
  TutorDataGridSource(List<TutorWithPoint> tutorData) {
    _tutors = tutorData;
    buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = <DataGridRow>[];
  List<TutorWithPoint>? _tutors = <TutorWithPoint>[];

  /// Building DataGridRows
  void buildDataGridRows() {
    if (_tutors != null && _tutors!.isNotEmpty) {
      _dataGridRows = _tutors!.map<DataGridRow>((TutorWithPoint tutorWithUser) {
        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<String>(columnName: 'Id', value: tutorWithUser.tutor.tutorId),
          DataGridCell<String>(columnName: 'Punto', value: tutorWithUser.point?.name??""),
          DataGridCell<String>(columnName: 'Nombre', value: tutorWithUser.tutor.name),
          DataGridCell<String>(columnName: 'Apellidos', value: tutorWithUser.tutor.surnames),
          DataGridCell<String>(columnName: 'Vecindario', value: tutorWithUser.tutor.address),
          DataGridCell<String>(columnName: 'Teléfono', value: tutorWithUser.tutor.phone),
          DataGridCell<DateTime>(columnName: 'Fecha de nacimiento', value: tutorWithUser.tutor.birthdate),
          DataGridCell<DateTime>(columnName: 'Fecha de alta', value: tutorWithUser.tutor.createDate),
          DataGridCell<String>(columnName: 'Etnia', value: tutorWithUser.tutor.ethnicity),
          DataGridCell<String>(columnName: 'Sexo', value: tutorWithUser.tutor.sex),
          DataGridCell<String>(columnName: 'Vínculo', value: tutorWithUser.tutor.maleRelation),
          DataGridCell<double>(columnName: 'Peso (kg)', value: tutorWithUser.tutor.weight),
          DataGridCell<double>(columnName: 'Altura (cm)', value: tutorWithUser.tutor.height),
          DataGridCell<String>(columnName: 'Estado', value: tutorWithUser.tutor.status),
          DataGridCell<String>(columnName: 'Embarazada', value: tutorWithUser.tutor.pregnant),
          DataGridCell<int>(columnName: 'Semanas', value: tutorWithUser.tutor.weeks),
          DataGridCell<String>(columnName: 'Hijos/as menores a 6 meses', value: tutorWithUser.tutor.childMinor),
          DataGridCell<String>(columnName: 'Observaciones', value: tutorWithUser.tutor.observations),
          DataGridCell<bool>(columnName: 'Activo', value: tutorWithUser.tutor.active),
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
      _buildStandardContainer(row.getCells()[5].value.toString()),
      _buildDate(row.getCells()[6].value),
      _buildDate(row.getCells()[7].value),
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
      _buildActive(row.getCells()[18].value),
    ]);
  }

  setTutors(List<TutorWithPoint>? tutorData) {
    _tutors = tutorData;
  }

  List<TutorWithPoint>? getTutors() {
    return _tutors;
  }

  /// Update DataSource
  void updateDataSource() {
    notifyListeners();
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

  Widget _buildEmail(dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: _getWidget(const Icon(Icons.email, size: 20), value),
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

  Widget _buildStandardContainer(String value) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.centerLeft,
      child: Text(value),
    );
  }
}

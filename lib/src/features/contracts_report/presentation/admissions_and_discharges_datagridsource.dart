import 'package:adminnut4health/src/features/contracts_report/domain/admissions_and_discharges_inform.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';


class AdmissionsAndDischargesDataGridSource extends DataGridSource {
  AdmissionsAndDischargesDataGridSource(List<AdmissionsAndDischargesInform> informData) {
    _mainInforms = informData;
    buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = <DataGridRow>[];
  List<AdmissionsAndDischargesInform>? _mainInforms = <AdmissionsAndDischargesInform>[];

  /// Building DataGridRows
  void buildDataGridRows() {
    if (_mainInforms != null && _mainInforms!.isNotEmpty) {

      _dataGridRows = _mainInforms!.map<DataGridRow>((AdmissionsAndDischargesInform mainInform) {

        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<String>(columnName: 'Categoría', value: mainInform.category),
          DataGridCell<int>(columnName: 'Pacientes al inicio', value: mainInform.patientsAtBeginning),
          DataGridCell<int>(columnName: 'Nuevos casos', value: mainInform.newAdmissions),
          DataGridCell<int>(columnName: 'Readmisiones', value: mainInform.reAdmissions),
          DataGridCell<int>(columnName: 'Recaídas', value: mainInform.relapses),
          DataGridCell<int>(columnName: 'Referidos (Admisión)', value: mainInform.referredIn),
          DataGridCell<int>(columnName: 'Transferidos (Admisión)', value: mainInform.transferedIn),
          DataGridCell<int>(columnName: 'TOTAL ADMISIONES', value: mainInform.totalAdmissions()),
          DataGridCell<int>(columnName: 'TOTAL ATENDIDOS/AS', value: mainInform.totalAttended()),
          DataGridCell<int>(columnName: 'Recuperados', value: mainInform.recovered),
          DataGridCell<int>(columnName: 'Sin respuesta', value: mainInform.unresponsive),
          DataGridCell<int>(columnName: 'Abandonos', value: mainInform.abandonment),
          DataGridCell<int>(columnName: 'Referidos (Alta)', value: mainInform.referredOut),
          DataGridCell<int>(columnName: 'Transferidos (Alta)', value: mainInform.transferedOut),
          DataGridCell<int>(columnName: 'TOTAL ALTAS', value: mainInform.totalDischarges()),
          DataGridCell<int>(columnName: 'TOTAL AL FINAL', value: mainInform.totalAtTheEnd()),
        ]);
      }).toList();
    }
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final rowColor = row.getCells()[0].value.toString().contains("Total")? Colors.grey.withOpacity(0.3):
        row.getCells()[0].value.toString().contains("Subtotal")? Colors.grey.withOpacity(0.15): Colors.white;
    final textStyle = row.getCells()[0].value.toString().contains("Total")? const TextStyle(fontWeight: FontWeight.bold):
    row.getCells()[0].value.toString().contains("Subtotal")? const TextStyle(fontWeight: FontWeight.w600): const TextStyle();
    
    return DataGridRowAdapter(
        cells: row.getCells().map((c) =>
            _buildStandardContainer(c.value.toString(), textStyle)
        ).toList(),
        color: rowColor
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

  Widget _buildStandardContainer(String value, TextStyle textStyle) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.centerLeft,
      child: Text(value, style: textStyle),
    );
  }

  setMainInforms(List<AdmissionsAndDischargesInform> informs) {
    _mainInforms = informs;
  }

  List<AdmissionsAndDischargesInform>? getMainInforms() {
    return _mainInforms;
  }

  /// Update DataSource
  void updateDataSource() {
    notifyListeners();
  }

}

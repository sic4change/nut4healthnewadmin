import 'package:adminnut4health/src/features/contracts_report/domain/admissions_and_discharges_by_point_inform.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';


class AdmissionsAndDischargesByPointDataGridSource extends DataGridSource {
  AdmissionsAndDischargesByPointDataGridSource(List<AdmissionsAndDischargesByPointInform> informData) {
    _mainInforms = informData;
    buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = <DataGridRow>[];
  List<AdmissionsAndDischargesByPointInform>? _mainInforms = <AdmissionsAndDischargesByPointInform>[];

  /// Building DataGridRows
  void buildDataGridRows() {
    if (_mainInforms != null && _mainInforms!.isNotEmpty) {

      _dataGridRows = _mainInforms!.map<DataGridRow>((AdmissionsAndDischargesByPointInform mainInform) {

        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<String>(columnName: 'País', value: mainInform.country),
          DataGridCell<String>(columnName: 'Región', value: mainInform.region),
          DataGridCell<String>(columnName: 'Provincia', value: mainInform.location),
          DataGridCell<String>(columnName: 'Municipio', value: mainInform.province),
          DataGridCell<String>(columnName: 'Puesto de salud', value: mainInform.point),
          DataGridCell<int>(columnName: 'Pacientes al inicio (M)', value: mainInform.patientsAtBeginningBoy),
          DataGridCell<int>(columnName: 'Pacientes al inicio (F)', value: mainInform.patientsAtBeginningGirl),
          DataGridCell<int>(columnName: 'Pacientes al inicio (FEFA)', value: mainInform.patientsAtBeginningFEFA),
          DataGridCell<int>(columnName: 'Nuevos casos (M)', value: mainInform.newAdmissionsBoy),
          DataGridCell<int>(columnName: 'Nuevos casos (F)', value: mainInform.newAdmissionsGirl),
          DataGridCell<int>(columnName: 'Nuevos casos (FEFA)', value: mainInform.newAdmissionsFEFA),
          DataGridCell<int>(columnName: 'Readmisiones (M)', value: mainInform.reAdmissionsBoy),
          DataGridCell<int>(columnName: 'Readmisiones (F)', value: mainInform.reAdmissionsGirl),
          DataGridCell<int>(columnName: 'Readmisiones (FEFA)', value: mainInform.reAdmissionsFEFA),
          DataGridCell<int>(columnName: 'Recaídas (M)', value: mainInform.relapsesBoy),
          DataGridCell<int>(columnName: 'Recaídas (F)', value: mainInform.relapsesGirl),
          DataGridCell<int>(columnName: 'Recaídas (FEFA)', value: mainInform.relapsesFEFA),
          DataGridCell<int>(columnName: 'Referidos (Admisión) (M)', value: mainInform.referredInBoy),
          DataGridCell<int>(columnName: 'Referidos (Admisión) (F)', value: mainInform.referredInGirl),
          DataGridCell<int>(columnName: 'Referidos (Admisión) (FEFA)', value: mainInform.referredInFEFA),
          DataGridCell<int>(columnName: 'Transferidos (Admisión) (M)', value: mainInform.transferedInBoy),
          DataGridCell<int>(columnName: 'Transferidos (Admisión) (F)', value: mainInform.transferedInGirl),
          DataGridCell<int>(columnName: 'Transferidos (Admisión) (FEFA)', value: mainInform.transferedInFEFA),
          DataGridCell<int>(columnName: 'TOTAL ADMISIONES (M)', value: mainInform.totalAdmissionsBoy()),
          DataGridCell<int>(columnName: 'TOTAL ADMISIONES (F)', value: mainInform.totalAdmissionsGirl()),
          DataGridCell<int>(columnName: 'TOTAL ADMISIONES (FEFA)', value: mainInform.totalAdmissionsFEFA()),
          DataGridCell<int>(columnName: 'TOTAL ATENDIDOS (M)', value: mainInform.totalAttendedBoy()),
          DataGridCell<int>(columnName: 'TOTAL ATENDIDAS (F)', value: mainInform.totalAttendedGirl()),
          DataGridCell<int>(columnName: 'TOTAL ATENDIDAS (FEFA)', value: mainInform.totalAttendedFEFA()),
          DataGridCell<int>(columnName: 'Recuperados (M)', value: mainInform.recoveredBoy),
          DataGridCell<int>(columnName: 'Recuperados (F)', value: mainInform.recoveredGirl),
          DataGridCell<int>(columnName: 'Recuperados (FEFA)', value: mainInform.recoveredFEFA),
          DataGridCell<int>(columnName: 'Sin respuesta (M)', value: mainInform.unresponsiveBoy),
          DataGridCell<int>(columnName: 'Sin respuesta (F)', value: mainInform.unresponsiveGirl),
          DataGridCell<int>(columnName: 'Sin respuesta (FEFA)', value: mainInform.unresponsiveFEFA),
          DataGridCell<int>(columnName: 'Fallecimientos (M)', value: mainInform.deathsBoy),
          DataGridCell<int>(columnName: 'Fallecimientos (F)', value: mainInform.deathsGirl),
          DataGridCell<int>(columnName: 'Fallecimientos (FEFA)', value: mainInform.deathsFEFA),
          DataGridCell<int>(columnName: 'Abandonos (M)', value: mainInform.abandonmentBoy),
          DataGridCell<int>(columnName: 'Abandonos (F)', value: mainInform.abandonmentGirl),
          DataGridCell<int>(columnName: 'Abandonos (FEFA)', value: mainInform.abandonmentFEFA),
          DataGridCell<int>(columnName: 'Referidos (Alta) (M)', value: mainInform.referredOutBoy),
          DataGridCell<int>(columnName: 'Referidos (Alta) (F)', value: mainInform.referredOutGirl),
          DataGridCell<int>(columnName: 'Referidos (Alta) (FEFA)', value: mainInform.referredOutFEFA),
          DataGridCell<int>(columnName: 'Transferidos (Alta) (M)', value: mainInform.transferedOutBoy),
          DataGridCell<int>(columnName: 'Transferidos (Alta) (F)', value: mainInform.transferedOutGirl),
          DataGridCell<int>(columnName: 'Transferidos (Alta) (FEFA)', value: mainInform.transferedOutFEFA),
          DataGridCell<int>(columnName: 'TOTAL ALTAS (M)', value: mainInform.point.contains("PORCENTAJES")? 0: mainInform.totalDischargesBoy()),
          DataGridCell<int>(columnName: 'TOTAL ALTAS (F)', value: mainInform.point.contains("PORCENTAJES")? 0: mainInform.totalDischargesGirl()),
          DataGridCell<int>(columnName: 'TOTAL ALTAS (FEFA)', value: mainInform.point.contains("PORCENTAJES")? 0: mainInform.totalDischargesFEFA()),
          DataGridCell<int>(columnName: 'TOTAL AL FINAL (M)', value: mainInform.point.contains("PORCENTAJES")? mainInform.percentageBoyAtTheEnd: mainInform.totalAtTheEndBoy()),
          DataGridCell<int>(columnName: 'TOTAL AL FINAL (F)', value: mainInform.point.contains("PORCENTAJES")? mainInform.percentageGirlAtTheEnd: mainInform.totalAtTheEndGirl()),
          DataGridCell<int>(columnName: 'TOTAL AL FINAL (FEFA)', value: mainInform.point.contains("PORCENTAJES")? mainInform.percentageFEFAAtTheEnd: mainInform.totalAtTheEndFEFA()),
        ]);
      }).toList();
    }
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final rowColor = row.getCells()[4].value.toString().contains("TOTAL") || row.getCells()[4].value.toString().contains("PORCENTAJES")? Colors.grey.withOpacity(0.3): Colors.white;
    final textStyle = row.getCells()[4].value.toString().contains("TOTAL")|| row.getCells()[4].value.toString().contains("PORCENTAJES")? const TextStyle(fontWeight: FontWeight.bold): const TextStyle();

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

  setMainInforms(List<AdmissionsAndDischargesByPointInform> informs) {
    _mainInforms = informs;
  }

  List<AdmissionsAndDischargesByPointInform>? getMainInforms() {
    return _mainInforms;
  }

  /// Update DataSource
  void updateDataSource() {
    notifyListeners();
  }
}

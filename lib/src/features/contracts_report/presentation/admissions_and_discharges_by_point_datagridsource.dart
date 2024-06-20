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

        bool isPercentageRow = mainInform.point.contains("PORCENTAJES (%)");
        bool isBoyGirlRow = mainInform.point.contains("TOTALES NIÑAS Y NIÑOS");
        bool isBoyGirlFefaRow = mainInform.point.contains("TOTALES NIÑAS, NIÑOS Y MEL");
        
        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<String>(columnName: 'País', value: mainInform.country),
          DataGridCell<String>(columnName: 'Región', value: mainInform.region),
          DataGridCell<String>(columnName: 'Provincia', value: mainInform.location),
          DataGridCell<String>(columnName: 'Municipio', value: mainInform.province),
          DataGridCell<String>(columnName: 'Puesto de salud', value: mainInform.point),
          DataGridCell<String>(columnName: 'Pacientes al inicio (M)', value: isPercentageRow? "": isBoyGirlRow? "Niñas + niños:": isBoyGirlFefaRow? "":mainInform.patientsAtBeginningBoy.toString()),
          DataGridCell<String>(columnName: 'Pacientes al inicio (F)', value: isPercentageRow? "": isBoyGirlFefaRow? "Niñas + niños + FEFA:":mainInform.patientsAtBeginningGirl.toString()),
          DataGridCell<String>(columnName: 'Pacientes al inicio (FEFA)', value: isPercentageRow? "":mainInform.patientsAtBeginningFEFA.toString()),
          DataGridCell<String>(columnName: 'Nuevos casos (M)', value: isPercentageRow? "": isBoyGirlRow? "Niñas + niños:": isBoyGirlFefaRow? "":mainInform.newAdmissionsBoy.toString()),
          DataGridCell<String>(columnName: 'Nuevos casos (F)', value: isPercentageRow? "": isBoyGirlFefaRow? "Niñas + niños + FEFA:":mainInform.newAdmissionsGirl.toString()),
          DataGridCell<String>(columnName: 'Nuevos casos (FEFA)', value: isPercentageRow? "":mainInform.newAdmissionsFEFA.toString()),
          DataGridCell<String>(columnName: 'Readmisiones (M)', value: isPercentageRow? "": isBoyGirlRow? "Niñas + niños:": isBoyGirlFefaRow? "":mainInform.reAdmissionsBoy.toString()),
          DataGridCell<String>(columnName: 'Readmisiones (F)', value: isPercentageRow? "": isBoyGirlFefaRow? "Niñas + niños + FEFA:":mainInform.reAdmissionsGirl.toString()),
          DataGridCell<String>(columnName: 'Readmisiones (FEFA)', value: isPercentageRow? "":mainInform.reAdmissionsFEFA.toString()),
          DataGridCell<String>(columnName: 'Recaídas (M)', value: isPercentageRow? "": isBoyGirlRow? "Niñas + niños:": isBoyGirlFefaRow? "":mainInform.relapsesBoy.toString()),
          DataGridCell<String>(columnName: 'Recaídas (F)', value: isPercentageRow? "": isBoyGirlFefaRow? "Niñas + niños + FEFA:":mainInform.relapsesGirl.toString()),
          DataGridCell<String>(columnName: 'Recaídas (FEFA)', value: isPercentageRow? "":mainInform.relapsesFEFA.toString()),
          DataGridCell<String>(columnName: 'Referidos (Admisión) (M)', value: isPercentageRow? "": isBoyGirlRow? "Niñas + niños:": isBoyGirlFefaRow? "":mainInform.referredInBoy.toString()),
          DataGridCell<String>(columnName: 'Referidos (Admisión) (F)', value: isPercentageRow? "": isBoyGirlFefaRow? "Niñas + niños + FEFA:":mainInform.referredInGirl.toString()),
          DataGridCell<String>(columnName: 'Referidos (Admisión) (FEFA)', value: mainInform.referredInFEFA.toString()),
          DataGridCell<String>(columnName: 'Transferidos (Admisión) (M)', value: isPercentageRow? "": isBoyGirlRow? "Niñas + niños:": isBoyGirlFefaRow? "":mainInform.transferedInBoy.toString()),
          DataGridCell<String>(columnName: 'Transferidos (Admisión) (F)', value: isPercentageRow? "": isBoyGirlFefaRow? "Niñas + niños + FEFA:":mainInform.transferedInGirl.toString()),
          DataGridCell<String>(columnName: 'Transferidos (Admisión) (FEFA)', value: isPercentageRow? "":mainInform.transferedInFEFA.toString()),
          DataGridCell<String>(columnName: 'TOTAL ADMISIONES (M)', value: isPercentageRow? "": isBoyGirlRow? "Niñas + niños:": isBoyGirlFefaRow? "":mainInform.totalAdmissionsBoy().toString()),
          DataGridCell<String>(columnName: 'TOTAL ADMISIONES (F)', value: isPercentageRow? "": isBoyGirlFefaRow? "Niñas + niños + FEFA:":mainInform.totalAdmissionsGirl().toString()),
          DataGridCell<String>(columnName: 'TOTAL ADMISIONES (FEFA)', value: isPercentageRow? "":mainInform.totalAdmissionsFEFA().toString()),
          DataGridCell<String>(columnName: 'TOTAL ATENDIDOS (M)', value: isPercentageRow? "": isBoyGirlRow? "Niñas + niños:": isBoyGirlFefaRow? "":mainInform.totalAttendedBoy().toString()),
          DataGridCell<String>(columnName: 'TOTAL ATENDIDAS (F)', value: isPercentageRow? "": isBoyGirlFefaRow? "Niñas + niños + FEFA:":mainInform.totalAttendedGirl().toString()),
          DataGridCell<String>(columnName: 'TOTAL ATENDIDAS (FEFA)', value: isPercentageRow? "":mainInform.totalAttendedFEFA().toString()),
          DataGridCell<String>(columnName: 'Recuperados (M)', value: isPercentageRow? "": isBoyGirlRow? "Niñas + niños:": isBoyGirlFefaRow? "":mainInform.recoveredBoy.toString()),
          DataGridCell<String>(columnName: 'Recuperados (F)', value: isPercentageRow? "": isBoyGirlFefaRow? "Niñas + niños + FEFA:":mainInform.recoveredGirl.toString()),
          DataGridCell<String>(columnName: 'Recuperados (FEFA)', value: mainInform.recoveredFEFA.toString()),
          DataGridCell<String>(columnName: 'Sin respuesta (M)', value: isPercentageRow? "": isBoyGirlRow? "Niñas + niños:": isBoyGirlFefaRow? "":mainInform.unresponsiveBoy.toString()),
          DataGridCell<String>(columnName: 'Sin respuesta (F)', value: isPercentageRow? "": isBoyGirlFefaRow? "Niñas + niños + FEFA:":mainInform.unresponsiveGirl.toString()),
          DataGridCell<String>(columnName: 'Sin respuesta (FEFA)', value: mainInform.unresponsiveFEFA.toString()),
          DataGridCell<String>(columnName: 'Fallecimientos (M)', value: isPercentageRow? "": isBoyGirlRow? "Niñas + niños:": isBoyGirlFefaRow? "":mainInform.deathsBoy.toString()),
          DataGridCell<String>(columnName: 'Fallecimientos (F)', value: isPercentageRow? "": isBoyGirlFefaRow? "Niñas + niños + FEFA:":mainInform.deathsGirl.toString()),
          DataGridCell<String>(columnName: 'Fallecimientos (FEFA)', value: mainInform.deathsFEFA.toString()),
          DataGridCell<String>(columnName: 'Abandonos (M)', value: isPercentageRow? "": isBoyGirlRow? "Niñas + niños:": isBoyGirlFefaRow? "":mainInform.abandonmentBoy.toString()),
          DataGridCell<String>(columnName: 'Abandonos (F)', value: isPercentageRow? "": isBoyGirlFefaRow? "Niñas + niños + FEFA:":mainInform.abandonmentGirl.toString()),
          DataGridCell<String>(columnName: 'Abandonos (FEFA)', value: mainInform.abandonmentFEFA.toString()),
          DataGridCell<String>(columnName: 'Referidos (Alta) (M)', value: isPercentageRow? "": isBoyGirlRow? "Niñas + niños:": isBoyGirlFefaRow? "":mainInform.referredOutBoy.toString()),
          DataGridCell<String>(columnName: 'Referidos (Alta) (F)', value: isPercentageRow? "": isBoyGirlFefaRow? "Niñas + niños + FEFA:":mainInform.referredOutGirl.toString()),
          DataGridCell<String>(columnName: 'Referidos (Alta) (FEFA)', value: isPercentageRow? "":mainInform.referredOutFEFA.toString()),
          DataGridCell<String>(columnName: 'Transferidos (Alta) (M)', value: isPercentageRow? "": isBoyGirlRow? "Niñas + niños:": isBoyGirlFefaRow? "":mainInform.transferedOutBoy.toString()),
          DataGridCell<String>(columnName: 'Transferidos (Alta) (F)', value: isPercentageRow? "": isBoyGirlFefaRow? "Niñas + niños + FEFA:":mainInform.transferedOutGirl.toString()),
          DataGridCell<String>(columnName: 'Transferidos (Alta) (FEFA)', value: isPercentageRow? "":mainInform.transferedOutFEFA.toString()),
          DataGridCell<String>(columnName: 'TOTAL ALTAS (M)', value: isPercentageRow? "": isBoyGirlRow? "Niñas + niños:": isBoyGirlFefaRow? "": mainInform.totalDischargesBoy().toString()),
          DataGridCell<String>(columnName: 'TOTAL ALTAS (F)', value: isPercentageRow? "": isBoyGirlFefaRow? "Niñas + niños + FEFA:":mainInform.totalDischargesGirl().toString()),
          DataGridCell<String>(columnName: 'TOTAL ALTAS (FEFA)', value: isPercentageRow? "": mainInform.totalDischargesFEFA().toString()),
          DataGridCell<String>(columnName: 'TOTAL AL FINAL (M)', value: isPercentageRow? mainInform.percentageBoyAtTheEnd.toString(): isBoyGirlRow? "Niñas + niños:": isBoyGirlFefaRow? "": mainInform.totalAtTheEndBoy().toString()),
          DataGridCell<String>(columnName: 'TOTAL AL FINAL (F)', value: isPercentageRow? mainInform.percentageGirlAtTheEnd.toString(): isBoyGirlFefaRow? "Niñas + niños + FEFA:": mainInform.totalAtTheEndGirl().toString()),
          DataGridCell<String>(columnName: 'TOTAL AL FINAL (FEFA)', value: isPercentageRow? mainInform.percentageFEFAAtTheEnd.toString(): mainInform.totalAtTheEndFEFA().toString()),
        ]);
      }).toList();
    }
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final rowColor = row.getCells()[4].value.toString().contains("TOTAL") || row.getCells()[4].value.toString().contains("PORCENTAJES (%)")? Colors.grey.withOpacity(0.3): Colors.white;
    final textStyle = row.getCells()[4].value.toString().contains("TOTAL")|| row.getCells()[4].value.toString().contains("PORCENTAJES (%)")? const TextStyle(fontWeight: FontWeight.bold): const TextStyle();

    return DataGridRowAdapter(
        cells: row.getCells().map((c){
          var text = c.value.toString();
          if (row.getCells()[4].value.toString().contains("PORCENTAJES (%)") && text.isNotEmpty && text != "PORCENTAJES (%)") {
            text = "$text%";
          }
          return _buildStandardContainer(text, textStyle);
        }).toList(),
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

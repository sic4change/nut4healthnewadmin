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
  String selectedLocale = "";

  /// Building DataGridRows
  void buildDataGridRows() {
    if (_mainInforms != null && _mainInforms!.isNotEmpty) {

      _dataGridRows = _mainInforms!.map<DataGridRow>((AdmissionsAndDischargesByPointInform mainInform) {
        bool isPercentageRow = mainInform.point.contains("(%)");
        bool isBoyGirlRow = mainInform.point.contains("TOTALES NIÑAS Y NIÑOS") || mainInform.point.contains("TOTAL FILLES ET GARÇONS") || mainInform.point.contains("TOTAL GIRLS AND BOYS");
        bool isBoyGirlFefaRow = mainInform.point.contains("TOTALES NIÑAS, NIÑOS Y MEL") || mainInform.point.contains("TOTAL FILLES, GARCONS ET FEFA") || mainInform.point.contains("TOTAL GIRLS, BOYS AND FEFA");

        String boyGirls = "Niñas + niños:";
        String boyGirlsFEFA = "Niñas + niños + MEL:";
        switch (selectedLocale) {
          case 'en_US':
            boyGirls = "Girls + boys:";
            boyGirlsFEFA = "Girls + boys + FEFA:";
            break;
          case "es_ES":
            boyGirls = "Niñas + niños:";
            boyGirlsFEFA = "Niñas + niños + MEL:";
            break;
          case 'fr_FR':
            boyGirls = "Filles + garçons:";
            boyGirlsFEFA = "Filles + garçons + FEFA:";
            break;
        }

        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<String>(columnName: 'País', value: mainInform.country),
          DataGridCell<String>(columnName: 'Región', value: mainInform.region),
          DataGridCell<String>(columnName: 'Provincia', value: mainInform.location),
          DataGridCell<String>(columnName: 'Municipio', value: mainInform.province),
          DataGridCell<String>(columnName: 'Puesto de salud', value: mainInform.point),
          DataGridCell<String>(columnName: 'Pacientes al inicio (M)', value: isPercentageRow? "": isBoyGirlRow? boyGirls: isBoyGirlFefaRow? "":mainInform.patientsAtBeginningBoy.toString()),
          DataGridCell<String>(columnName: 'Pacientes al inicio (F)', value: isPercentageRow? "": isBoyGirlFefaRow? boyGirlsFEFA:mainInform.patientsAtBeginningGirl.toString()),
          DataGridCell<String>(columnName: 'Pacientes al inicio (FEFA)', value: isPercentageRow? "":mainInform.patientsAtBeginningFEFA.toString()),
          DataGridCell<String>(columnName: 'Nuevos casos (M)', value: isPercentageRow? "": isBoyGirlRow? boyGirls: isBoyGirlFefaRow? "":mainInform.newAdmissionsBoy.toString()),
          DataGridCell<String>(columnName: 'Nuevos casos (F)', value: isPercentageRow? "": isBoyGirlFefaRow? boyGirlsFEFA:mainInform.newAdmissionsGirl.toString()),
          DataGridCell<String>(columnName: 'Nuevos casos (FEFA)', value: isPercentageRow? "":mainInform.newAdmissionsFEFA.toString()),
          DataGridCell<String>(columnName: 'Readmisiones (M)', value: isPercentageRow? "": isBoyGirlRow? boyGirls: isBoyGirlFefaRow? "":mainInform.reAdmissionsBoy.toString()),
          DataGridCell<String>(columnName: 'Readmisiones (F)', value: isPercentageRow? "": isBoyGirlFefaRow? boyGirlsFEFA:mainInform.reAdmissionsGirl.toString()),
          DataGridCell<String>(columnName: 'Readmisiones (FEFA)', value: isPercentageRow? "":mainInform.reAdmissionsFEFA.toString()),
          DataGridCell<String>(columnName: 'Recaídas (M)', value: isPercentageRow? "": isBoyGirlRow? boyGirls: isBoyGirlFefaRow? "":mainInform.relapsesBoy.toString()),
          DataGridCell<String>(columnName: 'Recaídas (F)', value: isPercentageRow? "": isBoyGirlFefaRow? boyGirlsFEFA:mainInform.relapsesGirl.toString()),
          DataGridCell<String>(columnName: 'Recaídas (FEFA)', value: isPercentageRow? "":mainInform.relapsesFEFA.toString()),
          DataGridCell<String>(columnName: 'Referidos (Admisión) (M)', value: isPercentageRow? "": isBoyGirlRow? boyGirls: isBoyGirlFefaRow? "":mainInform.referredInBoy.toString()),
          DataGridCell<String>(columnName: 'Referidos (Admisión) (F)', value: isBoyGirlFefaRow? boyGirlsFEFA:mainInform.referredInGirl.toString()),
          DataGridCell<String>(columnName: 'Referidos (Admisión) (FEFA)', value: isPercentageRow? "": mainInform.referredInFEFA.toString()),
          DataGridCell<String>(columnName: 'Transferidos (Admisión) (M)', value: isPercentageRow? "": isBoyGirlRow? boyGirls: isBoyGirlFefaRow? "":mainInform.transferedInBoy.toString()),
          DataGridCell<String>(columnName: 'Transferidos (Admisión) (F)', value: isPercentageRow? "": isBoyGirlFefaRow? boyGirlsFEFA:mainInform.transferedInGirl.toString()),
          DataGridCell<String>(columnName: 'Transferidos (Admisión) (FEFA)', value: isPercentageRow? "":mainInform.transferedInFEFA.toString()),
          DataGridCell<String>(columnName: 'TOTAL ADMISIONES (M)', value: isPercentageRow? "": isBoyGirlRow? boyGirls: isBoyGirlFefaRow? "":mainInform.totalAdmissionsBoy().toString()),
          DataGridCell<String>(columnName: 'TOTAL ADMISIONES (F)', value: isPercentageRow? "": isBoyGirlFefaRow? boyGirlsFEFA:mainInform.totalAdmissionsGirl().toString()),
          DataGridCell<String>(columnName: 'TOTAL ADMISIONES (FEFA)', value: isPercentageRow? "":mainInform.totalAdmissionsFEFA().toString()),
          DataGridCell<String>(columnName: 'TOTAL ATENDIDOS (M)', value: isPercentageRow? "": isBoyGirlRow? boyGirls: isBoyGirlFefaRow? "":mainInform.totalAttendedBoy().toString()),
          DataGridCell<String>(columnName: 'TOTAL ATENDIDAS (F)', value: isPercentageRow? "": isBoyGirlFefaRow? boyGirlsFEFA:mainInform.totalAttendedGirl().toString()),
          DataGridCell<String>(columnName: 'TOTAL ATENDIDAS (FEFA)', value: isPercentageRow? "":mainInform.totalAttendedFEFA().toString()),
          DataGridCell<String>(columnName: 'Recuperados (M)', value: isPercentageRow? "": isBoyGirlRow? boyGirls: isBoyGirlFefaRow? "":mainInform.recoveredBoy.toString()),
          DataGridCell<String>(columnName: 'Recuperados (F)', value: isPercentageRow? "": isBoyGirlFefaRow? boyGirlsFEFA:mainInform.recoveredGirl.toString()),
          DataGridCell<String>(columnName: 'Recuperados (FEFA)', value: mainInform.recoveredFEFA.toString()),
          DataGridCell<String>(columnName: 'Sin respuesta (M)', value: isPercentageRow? "": isBoyGirlRow? boyGirls: isBoyGirlFefaRow? "":mainInform.unresponsiveBoy.toString()),
          DataGridCell<String>(columnName: 'Sin respuesta (F)', value: isPercentageRow? "": isBoyGirlFefaRow? boyGirlsFEFA:mainInform.unresponsiveGirl.toString()),
          DataGridCell<String>(columnName: 'Sin respuesta (FEFA)', value: mainInform.unresponsiveFEFA.toString()),
          DataGridCell<String>(columnName: 'Fallecimientos (M)', value: isPercentageRow? "": isBoyGirlRow? boyGirls: isBoyGirlFefaRow? "":mainInform.deathsBoy.toString()),
          DataGridCell<String>(columnName: 'Fallecimientos (F)', value: isPercentageRow? "": isBoyGirlFefaRow? boyGirlsFEFA:mainInform.deathsGirl.toString()),
          DataGridCell<String>(columnName: 'Fallecimientos (FEFA)', value: mainInform.deathsFEFA.toString()),
          DataGridCell<String>(columnName: 'Abandonos (M)', value: isPercentageRow? "": isBoyGirlRow? boyGirls: isBoyGirlFefaRow? "":mainInform.abandonmentBoy.toString()),
          DataGridCell<String>(columnName: 'Abandonos (F)', value: isPercentageRow? "": isBoyGirlFefaRow? boyGirlsFEFA:mainInform.abandonmentGirl.toString()),
          DataGridCell<String>(columnName: 'Abandonos (FEFA)', value: mainInform.abandonmentFEFA.toString()),
          DataGridCell<String>(columnName: 'Referidos (Alta) (M)', value: isPercentageRow? "": isBoyGirlRow? boyGirls: isBoyGirlFefaRow? "":mainInform.referredOutBoy.toString()),
          DataGridCell<String>(columnName: 'Referidos (Alta) (F)', value: isPercentageRow? "": isBoyGirlFefaRow? boyGirlsFEFA:mainInform.referredOutGirl.toString()),
          DataGridCell<String>(columnName: 'Referidos (Alta) (FEFA)', value: isPercentageRow? "":mainInform.referredOutFEFA.toString()),
          DataGridCell<String>(columnName: 'Transferidos (Alta) (M)', value: isPercentageRow? "": isBoyGirlRow? boyGirls: isBoyGirlFefaRow? "":mainInform.transferedOutBoy.toString()),
          DataGridCell<String>(columnName: 'Transferidos (Alta) (F)', value: isPercentageRow? "": isBoyGirlFefaRow? boyGirlsFEFA:mainInform.transferedOutGirl.toString()),
          DataGridCell<String>(columnName: 'Transferidos (Alta) (FEFA)', value: isPercentageRow? "":mainInform.transferedOutFEFA.toString()),
          DataGridCell<String>(columnName: 'TOTAL ALTAS (M)', value: isPercentageRow? "": isBoyGirlRow? boyGirls: isBoyGirlFefaRow? "": mainInform.totalDischargesBoy().toString()),
          DataGridCell<String>(columnName: 'TOTAL ALTAS (F)', value: isPercentageRow? "": isBoyGirlFefaRow? boyGirlsFEFA:mainInform.totalDischargesGirl().toString()),
          DataGridCell<String>(columnName: 'TOTAL ALTAS (FEFA)', value: isPercentageRow? "": mainInform.totalDischargesFEFA().toString()),
          DataGridCell<String>(columnName: 'TOTAL AL FINAL (M)', value: isPercentageRow? mainInform.percentageBoyAtTheEnd.toString(): isBoyGirlRow? boyGirls: isBoyGirlFefaRow? "": mainInform.totalAtTheEndBoy().toString()),
          DataGridCell<String>(columnName: 'TOTAL AL FINAL (F)', value: isPercentageRow? mainInform.percentageGirlAtTheEnd.toString(): isBoyGirlFefaRow? boyGirlsFEFA: mainInform.totalAtTheEndGirl().toString()),
          DataGridCell<String>(columnName: 'TOTAL AL FINAL (FEFA)', value: isPercentageRow? mainInform.percentageFEFAAtTheEnd.toString(): mainInform.totalAtTheEndFEFA().toString()),
        ]);
      }).toList();
    }
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final rowColor = row.getCells()[4].value.toString().contains("TOTAL") || row.getCells()[4].value.toString().contains("(%)")? Colors.grey.withOpacity(0.3): Colors.white;
    final textStyle = row.getCells()[4].value.toString().contains("TOTAL")|| row.getCells()[4].value.toString().contains("(%)")? const TextStyle(fontWeight: FontWeight.bold): const TextStyle();

    return DataGridRowAdapter(
        cells: row.getCells().map((c){
          var text = c.value.toString();
          if (row.getCells()[4].value.toString().contains("(%)") && text.isNotEmpty && !text.contains("(%)")) {
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

  void updateSelectedLocale(String selectedLocale) {
    this.selectedLocale = selectedLocale;
  }
}

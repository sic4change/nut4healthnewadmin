/// Package imports
/// import 'package:flutter/foundation.dart';

import 'package:adminnut4health/src/features/users/domain/user.dart';
import 'package:adminnut4health/src/features/visits/domain/visit.dart';
import 'package:adminnut4health/src/features/visits/domain/visitCombined.dart';
import 'package:adminnut4health/src/utils/alert_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Barcode import
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../../sample/model/sample_view.dart';
import '../../authentication/data/firebase_auth_repository.dart';
import '../data/firestore_repository.dart';

import 'visits_screen_controller.dart';
import 'visit_datagridsource.dart';

import '../../../common_widgets/export/save_file_mobile.dart'
if (dart.library.html) '../../../common_widgets/export/save_file_web.dart' as helper;

import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Render child data grid
class VisitDataGrid extends LocalizationSampleView {
  /// Creates getting started data grid
  const VisitDataGrid({Key? key}) : super(key: key);

  @override
  _VisitDataGridState createState() => _VisitDataGridState();
}

class _VisitDataGridState extends LocalizationSampleViewState {

  final GlobalKey<SfDataGridState> _key = GlobalKey<SfDataGridState>();

  /// DataGridSource required for SfDataGrid to obtain the row data.
  late VisitDataGridSource visitDataGridSource;

  static const double dataPagerHeight = 60;
  int _rowsPerPage = 15;

  /// Selected locale
  late String selectedLocale;

  /// Translate names
  late String _chefValidation, _regionalValidation, _point, _tutor, _child, _case, _admission, _createDate,  _height, _weight, _imc,
      _armCirunference, _status, _edema, _respirationStatus, _appetiteTest,
      _infection, _eyesDeficiency, _deshidratation, _vomiting, _diarrhea, _fever,
      _temperature, _cough, _vaccinationCard, _rubeolaVaccinated, _vitamineAVaccinated,
      _acidFolicAndFerroVaccinated, _amoxicilina, _otherTratments, _complicationsES,
      _complicationsEN, _complicationsFR, _observations, _exportXLS, _exportPDF,
      _total, _visits, _validateData, _pointId, _visitId, _caseId, _tutorId, _childId;

  late Map<String, double> columnWidths = {
    'Validación Médico Jefe': 200,
    'Validación Dirección Regional': 200,
    'Punto': 150,
    'Madre, padre o tutor': 150,
    'Niño/a': 150,
    'Caso': 150,
    'Admisión': 150,
    'Fecha de alta': 150,
    'Altura (cm)': 150,
    'Peso (kg)': 150,
    'IMC': 150,
    'Perímetro braquial (cm)': 150,
    'Estado': 150,
    'Edema': 150,
    'Respiración': 150,
    'Apetito': 150,
    'Infección': 150,
    'Deficiencia ojos': 150,
    'Deshidratación': 150,
    'Vómitos': 150,
    'Diarrea': 150,
    'Fiebre': 150,
    'Temperatura': 150,
    'Tos': 150,
    'Carta de vacunación': 150,
    'Vacunación rubéola': 150,
    'Programa de vacunación Vitamina A': 150,
    'Vacunación Ácido fólico y Hierro': 150,
    'Amoxicilina': 150,
    'Otros tratamientos': 200,
    'Complicaciones (ES)': 200,
    'Complicaciones (EN)': 200,
    'Complicaciones (FR)': 200,
    'Observaciones': 150,
    'ID': 200,
    'Caso ID': 200,
    'Punto ID': 200,
    'Madre, padre o tutor ID': 200,
    'Niño/a ID': 200,
  };

  AsyncValue<List<VisitCombined>> visitsAsyncValue = AsyncValue.data(List.empty());
  List<String> pointsIds = List.empty();

  Widget getLocationWidget(String location) {
    return Row(
      children: <Widget>[
        Image.asset('images/location.png'),
        Text(
          ' ' + location,
        )
      ],
    );
  }

  _saveVisits(AsyncValue<List<VisitCombined>>? visits) {
    if (visits == null) {
      visitDataGridSource.setVisits(List.empty());
    } else {
      visitDataGridSource.setVisits(visits.value);
    }
  }

  Widget _buildView(AsyncValue<List<VisitCombined>> visits) {
    if (visits.value != null) {
      visitDataGridSource.buildDataGridRows();
      visitDataGridSource.updateDataSource();
      selectedLocale = model.locale.toString();
      return _buildLayoutBuilder();
    } else {
      return const Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: CircularProgressIndicator(),
          )
      );
    }
  }

  Widget _buildLayoutBuilder() {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraint) {
          if (visitDataGridSource.getVisits()!.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildHeaderButtons(),
                const Expanded(
                  child: Center(
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: Text("No hay datos que mostrar"),
                      )),
                ),
              ],
            );
          } else {
          return Column(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildHeaderButtons(),
                  SizedBox(
                    height: constraint.maxHeight - (dataPagerHeight * 2),
                    width: constraint.maxWidth,
                    child: SfDataGridTheme(
                        data: SfDataGridThemeData(headerColor: Colors.blueAccent),
                        child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: _buildDataGrid()
                        )
                    ),
                  ),
                ],
              ),
              Container(
                height: dataPagerHeight,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.12),
                    border: Border(
                        top: BorderSide(
                            width: .5,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.12)))),
                child: Align(child: _buildDataPager()),
              )
            ],
          );
        }});
  }

  Widget _buildHeaderButtons() {
    Future<void> exportDataGridToExcel() async {
      final Workbook workbook = _key.currentState!.exportToExcelWorkbook(
          cellExport: (DataGridCellExcelExportDetails details) {

          });
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();
      await helper.FileSaveHelper.saveAndLaunchFile(bytes, '$_visits.xlsx');
    }

    Future<void> exportDataGridToPdf() async {
      final ByteData data = await rootBundle.load('images/nut_logo.jpg');
      final PdfDocument document = _key.currentState!.exportToPdfDocument(
          excludeColumns: ['ID', 'Caso ID', 'Punto ID', 'Madre, padre o tutor ID', 'Niño/a ID'],
          fitAllColumnsInOnePage: true,
          cellExport: (DataGridCellPdfExportDetails details) {

          },
          headerFooterExport: (DataGridPdfHeaderFooterExportDetails details) {
            final double width = details.pdfPage.getClientSize().width;
            final PdfPageTemplateElement header =
            PdfPageTemplateElement(Rect.fromLTWH(0, 0, width, 65));

            header.graphics.drawImage(
                PdfBitmap(data.buffer
                    .asUint8List(data.offsetInBytes, data.lengthInBytes)),
                Rect.fromLTWH(width - 148, 0, 148, 60));

            header.graphics.drawString(
              _visits,
              PdfStandardFont(PdfFontFamily.helvetica, 13,
                  style: PdfFontStyle.bold),
              bounds: const Rect.fromLTWH(0, 25, 200, 60),
            );

            details.pdfDocumentTemplate.top = header;
          });
      final List<int> bytes = document.saveSync();
      await helper.FileSaveHelper.saveAndLaunchFile(bytes, '$_visits.pdf');
      document.dispose();
    }

    if (User.currentRole == 'super-admin') {
      return Row(
        children: <Widget>[
          _buildPDFExportingButton(_exportPDF, onPressed: exportDataGridToPdf),
          _buildExcelExportingButton(_exportXLS, onPressed: exportDataGridToExcel),
        ],
      );
    } else if (User.needValidation){
      return Row(
        children: <Widget>[
          _buildValidationButton(onPressed: () {
            showValidationDialog(
                context: context,
                selectedLocale: selectedLocale,
                onPressed: () {
                  if (User.currentRole == 'medico-jefe') {
                    chefValidation();
                  }

                  if (User.currentRole == 'direccion-regional-salud') {
                    regionalValidation();
                  }
                }
            );
          }),
          _buildPDFExportingButton(_exportPDF, onPressed: exportDataGridToPdf),
          _buildExcelExportingButton(_exportXLS, onPressed: exportDataGridToExcel),
        ],
      );
    } else {
      return Row(
        children: <Widget>[
          _buildPDFExportingButton(_exportPDF, onPressed: exportDataGridToPdf),
          _buildExcelExportingButton(_exportXLS, onPressed: exportDataGridToExcel),
        ],
      );
    }
  }

  Widget _buildValidationButton(
      {required VoidCallback onPressed}) {
    switch (selectedLocale) {
      case 'en_US':
        _validateData = 'VALIDATE DATA';
        break;
      case 'es_ES':
        _validateData = 'VALIDAR DATOS';
        break;
      case 'fr_FR':
        _validateData = 'VALIDER LES DONNÉES';
        break;
    }
    return Container(
        height: 60.0,
        padding: const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0),
        child: TextButton(
          onPressed: onPressed,
          child: Text(_validateData),)
    );
  }

  Future<void> chefValidation() async {
    final visits =  visitDataGridSource.getVisits()!.where((v) => !v.visit.chefValidation);
    for (var v in visits) {
      Visit newVisit = Visit(
          visitId: v.visit.visitId,
          pointId: v.visit.pointId,
          childId: v.visit.childId,
          tutorId: v.visit.tutorId,
          caseId: v.visit.caseId,
          createDate: v.visit.createDate,
          height: v.visit.height,
          weight: v.visit.weight,
          imc: v.visit.imc,
          armCircunference: v.visit.armCircunference,
          status: v.visit.status,
          edema: v.visit.edema,
          respiratonStatus: v.visit.respiratonStatus,
          appetiteTest: v.visit.appetiteTest,
          infection: v.visit.infection,
          eyesDeficiency: v.visit.eyesDeficiency,
          deshidratation: v.visit.deshidratation,
          vomiting: v.visit.vomiting,
          diarrhea: v.visit.diarrhea,
          fever: v.visit.fever,
          temperature: v.visit.temperature,
          cough: v.visit.cough,
          vaccinationCard: v.visit.vaccinationCard,
          rubeolaVaccinated: v.visit.rubeolaVaccinated,
          vitamineAVaccinated: v.visit.vitamineAVaccinated,
          acidfolicAndFerroVaccinated: v.visit.acidfolicAndFerroVaccinated,
          complications: v.visit.complications,
          observations: v.visit.observations,
          admission: v.visit.admission,
          amoxicilina: v.visit.amoxicilina,
          otherTratments: v.visit.otherTratments,
          chefValidation: true,
          regionalValidation: v.visit.regionalValidation
      );

      ref.read(visitsScreenControllerProvider.notifier).updateVisit(newVisit);
    }}

  Future<void> regionalValidation() async {
    final visitsWithChefValidation = visitDataGridSource.getVisits()!.where((v) => v.visit.chefValidation && !v.visit.regionalValidation);
    for (var v in visitsWithChefValidation) {
      ref.read(visitsScreenControllerProvider.notifier).updateVisit(
          Visit(
              visitId: v.visit.visitId,
              pointId: v.visit.pointId,
              childId: v.visit.childId,
              tutorId: v.visit.tutorId,
              caseId: v.visit.caseId,
              createDate: v.visit.createDate,
              height: v.visit.height,
              weight: v.visit.weight,
              imc: v.visit.imc,
              armCircunference: v.visit.armCircunference,
              status: v.visit.status,
              edema: v.visit.edema,
              respiratonStatus: v.visit.respiratonStatus,
              appetiteTest: v.visit.appetiteTest,
              infection: v.visit.infection,
              eyesDeficiency: v.visit.eyesDeficiency,
              deshidratation: v.visit.deshidratation,
              vomiting: v.visit.vomiting,
              diarrhea: v.visit.diarrhea,
              fever: v.visit.fever,
              temperature: v.visit.temperature,
              cough: v.visit.cough,
              vaccinationCard: v.visit.vaccinationCard,
              rubeolaVaccinated: v.visit.rubeolaVaccinated,
              vitamineAVaccinated: v.visit.vitamineAVaccinated,
              acidfolicAndFerroVaccinated: v.visit.acidfolicAndFerroVaccinated,
              complications: v.visit.complications,
              observations: v.visit.observations,
              admission: v.visit.admission,
              amoxicilina: v.visit.amoxicilina,
              otherTratments: v.visit.otherTratments,
              chefValidation: v.visit.chefValidation,
              regionalValidation: true
          )
      );
    }}

  Widget _buildExcelExportingButton(String buttonName,
      {required VoidCallback onPressed}) {
    return Container(
        height: 60.0,
        padding: const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0),
        child: IconButton(
          icon: const Icon(
              FontAwesomeIcons.fileExcel,
              color: Colors.blueAccent),
          onPressed: onPressed,)
    );
  }

  Widget _buildPDFExportingButton(String buttonName,
      {required VoidCallback onPressed}) {
    return Container(
        height: 60.0,
        padding: const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0),
        child: IconButton(
          icon: const Icon(
              FontAwesomeIcons.filePdf,
              color: Colors.blueAccent),
          onPressed: onPressed,)
    );
  }


  Widget _buildDataPager() {
    var rows = visitDataGridSource.rows;
    if (visitDataGridSource.effectiveRows.isNotEmpty ) {
      rows = visitDataGridSource.effectiveRows;
    }
    var addMorePage = 0;
    if ((rows.length / _rowsPerPage).remainder(1) != 0) {
      addMorePage  = 1;
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SfDataPager(
        delegate: visitDataGridSource,
        availableRowsPerPage: const <int>[15, 20, 25],
        pageCount: (rows.length / _rowsPerPage) + addMorePage,
        onRowsPerPageChanged: (int? rowsPerPage) {
          setState(() {
            _rowsPerPage = rowsPerPage!;
          });
        },
      ),
    );
  }

  List<GridTableSummaryRow> _getTableSummaryRows() {
    final Color color =
    model.themeData.colorScheme.brightness == Brightness.light
        ? const Color(0xFFEBEBEB)
        : const Color(0xFF3B3B3B);
    return <GridTableSummaryRow>[
      GridTableSummaryRow(
          showSummaryInRow: true,
          color: color,
          title: '$_total: {Count}',
          columns: <GridSummaryColumn>[
            const GridSummaryColumn(
                name: 'Count',
                columnName: 'Nombre',
                summaryType: GridSummaryType.count),
          ],
          position: GridTableSummaryRowPosition.bottom),
    ];
  }

  SfDataGrid _buildDataGrid() {
    final selectedLocale = model.locale.toString();
    switch (selectedLocale) {
      case 'en_US':
        _chefValidation = 'Chef validation';
        _regionalValidation = 'Regional validation';
        _point = 'Point';
        _tutor = 'Mother, father or tutor';
        _child = 'Child';
        _case = 'Case';
        _admission = 'Admission';
        _createDate = 'Register date';
        _height = 'Height (cm)';
        _weight = 'Weight (kg)';
        _imc = 'BMI';
        _armCirunference = 'Arm circumference (cm)';
        _status = 'Status';
        _edema = 'Edema';
        _respirationStatus = 'Respiration status';
        _appetiteTest = 'Appetite test';
        _infection = 'Infection';
        _eyesDeficiency = 'Eyes deficiency';
        _deshidratation = 'Deshidratation';
        _vomiting = 'Vomiting';
        _diarrhea = 'Diarrhea';
        _fever = 'Fever';
        _temperature = 'Temperature';
        _cough = 'Cough';
        _vaccinationCard = 'Vaccination card';
        _rubeolaVaccinated = 'Rubeola vaccinated';
        _vitamineAVaccinated = 'Vitamine A Vaccinated';
        _acidFolicAndFerroVaccinated = 'Acid Folic and Iron Vaccinated';
        _amoxicilina = 'Amoxicillin';
        _otherTratments = 'Other treatments';
        _complicationsES = 'Complications (ES)';
        _complicationsEN = 'Complications (EN)';
        _complicationsFR = 'Complications (FR)';
        _observations = 'Observations';
        _visitId = 'ID';
        _caseId = 'Case ID';
        _pointId = 'Point ID';
        _tutorId = 'Mother, father or tutor ID';
        _childId = 'Child ID:';

        _exportXLS = 'Export XLS';
        _exportPDF = 'Export PDF';
        _total = 'Total visits';
        _visits = 'Visits';
        break;
      case 'es_ES':
        _chefValidation = 'Validación Médico Jefe';
        _regionalValidation = 'Validación Dirección Regional';
        _point = 'Punto';
        _tutor = 'Madre, padre o tutor';
        _child = 'Niño/a';
        _case = 'Caso';
        _admission = 'Admisión';
        _createDate = 'Fecha de alta';
        _height = 'Altura (cm)';
        _weight = 'Peso (kg)';
        _imc = 'IMC';
        _armCirunference = 'Perímetro braquial (cm)';
        _status = 'Estado';
        _edema = 'Edema';
        _respirationStatus = 'Respiración';
        _appetiteTest = 'Apetito';
        _infection = 'Infección';
        _eyesDeficiency = 'Deficiencia ojos';
        _deshidratation = 'Deshidratación';
        _vomiting = 'Vómitos';
        _diarrhea = 'Diarrea';
        _fever = 'Fiebre';
        _temperature = 'Temperatura';
        _cough = 'Tos';
        _vaccinationCard = 'Carta de vacunación';
        _rubeolaVaccinated = 'Vacunación rubéola';
        _vitamineAVaccinated = 'Programa de vacunación Vitamina A';
        _acidFolicAndFerroVaccinated = 'Vacunación Ácido fólico y Hierro';
        _amoxicilina = 'Amoxicilina';
        _otherTratments = 'Otros tratamientos';
        _complicationsES = 'Complicaciones (ES)';
        _complicationsEN = 'Complicaciones (EN)';
        _complicationsFR = 'Complicaciones (FR)';
        _observations = 'Observaciones';
        _visitId = 'ID';
        _caseId = 'Caso ID';
        _pointId = 'Punto ID';
        _tutorId = 'Madre, padre o tutor ID';
        _childId = 'Niño/a ID';

        _exportXLS = 'Exportar XLS';
        _exportPDF = 'Exportar PDF';
        _total = 'Visitas totales';
        _visits = 'Visitas';
        break;
      case 'fr_FR':
        _chefValidation = 'Validation du médecin-chef';
        _regionalValidation = 'Validation direction régionale de la santé';
        _point = 'Place';
        _tutor = 'Mère, père ou tuteur';
        _child = 'Enfant';
        _case = 'Cas';
        _admission = 'Admission';
        _createDate = 'Date d\'enregistrement';
        _height = 'Taille (cm)';
        _weight = 'Poids (kg)';
        _imc = 'IMC';
        _armCirunference = 'Circonférence du bras (cm)';
        _status = 'État';
        _edema = 'Oedème';
        _respirationStatus = 'Respiration status';
        _appetiteTest = 'Appetite test';
        _infection = 'Infection';
        _eyesDeficiency = 'Déficience oculaire';
        _deshidratation = 'Déshydratation';
        _vomiting = 'Vomissement';
        _diarrhea = 'Diarrhée';
        _fever = 'Fièvre';
        _temperature = 'Température';
        _cough = 'Toux';
        _vaccinationCard = 'Carnet de vaccination';
        _rubeolaVaccinated = 'Vacciné contre la rubéole';
        _vitamineAVaccinated = 'Programme de vaccination à la vitamine A';
        _acidFolicAndFerroVaccinated = 'Vaccination acide folique et fer';
        _amoxicilina = 'Amoxicilline';
        _otherTratments = 'Autres traitements';
        _complicationsES = 'Complications (ES)';
        _complicationsEN = 'Complications (EN)';
        _complicationsFR = 'Complications (FR)';
        _observations = 'Observations';
        _visitId = 'ID';
        _caseId = 'Cas ID';
        _pointId = 'Place ID';
        _tutorId = 'Mère, père ou tuteur ID';
        _childId = 'Enfant ID:';

        _exportXLS = 'Exporter XLS';
        _exportPDF = 'Exporter PDF';
        _total = 'Total de visites';
        _visits = 'Visites';
        break;
    }

    return SfDataGrid(
      key: _key,
      source: visitDataGridSource,
      rowsPerPage: _rowsPerPage,
      tableSummaryRows: _getTableSummaryRows(),
      allowColumnsResizing: true,
      onColumnResizeUpdate: (ColumnResizeUpdateDetails details) {
        setState(() {
          columnWidths[details.column.columnName] = details.width;
        });
        return true;
      },
      allowFiltering: true,
      onFilterChanged: (DataGridFilterChangeDetails details) {
        setState(() {
          _buildLayoutBuilder();
        });
      },
      allowSorting: true,
      allowMultiColumnSorting: true,
      columns: <GridColumn>[
        GridColumn(
            columnName: 'Validación Médico Jefe',
            width: columnWidths['Validación Médico Jefe']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _chefValidation,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Validación Dirección Regional',
            width: columnWidths['Validación Dirección Regional']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _regionalValidation,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Punto',
            width: columnWidths['Punto']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _point,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Madre, padre o tutor',
            width: columnWidths['Madre, padre o tutor']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _tutor,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Niño/a',
            width: columnWidths['Niño/a']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _child,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Caso',
            width: columnWidths['Caso']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _case,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Admisión',
            width: columnWidths['Admisión']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _admission,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Fecha de alta',
            width: columnWidths['Fecha de alta']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _createDate,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Altura (cm)',
            width: columnWidths['Altura (cm)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _height,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Peso (kg)',
            width: columnWidths['Peso (kg)']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _weight,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'IMC',
            width: columnWidths['IMC']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _imc,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Perímetro braquial (cm)',
            width: columnWidths['Perímetro braquial (cm)']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _armCirunference,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Estado',
            width: columnWidths['Estado']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _status,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Edema',
            width: columnWidths['Edema']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _edema,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Respiración',
            width: columnWidths['Respiración']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _respirationStatus,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Apetito',
            width: columnWidths['Apetito']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _appetiteTest,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Infección',
            width: columnWidths['Infección']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _infection,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Deficiencia ojos',
            width: columnWidths['Deficiencia ojos']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _eyesDeficiency,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Deshidratación',
            width: columnWidths['Deshidratación']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _deshidratation,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Vómitos',
            width: columnWidths['Vómitos']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _vomiting,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Diarrea',
            width: columnWidths['Diarrea']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _diarrhea,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Fiebre',
            width: columnWidths['Fiebre']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _fever,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Temperatura',
            width: columnWidths['Temperatura']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _temperature,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Tos',
            width: columnWidths['Tos']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _cough,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),GridColumn(
            columnName: 'Carta de vacunación',
            width: columnWidths['Carta de vacunación']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _vaccinationCard,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Vacunación rubéola',
            width: columnWidths['Vacunación rubéola']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _rubeolaVaccinated,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Programa de vacunación Vitamina A',
            width: columnWidths['Programa de vacunación Vitamina A']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _vitamineAVaccinated,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Vacunación Ácido fólico y Hierro',
            width: columnWidths['Vacunación Ácido fólico y Hierro']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _acidFolicAndFerroVaccinated,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Amoxicilina',
            width: columnWidths['Amoxicilina']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _amoxicilina,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Otros tratamientos',
            width: columnWidths['Otros tratamientos']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _otherTratments,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Complicaciones (ES)',
            width: columnWidths['Complicaciones (ES)']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _complicationsES,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Complicaciones (EN)',
            width: columnWidths['Complicaciones (EN)']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _complicationsEN,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Complicaciones (FR)',
            width: columnWidths['Complicaciones (FR)']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _complicationsFR,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Observaciones',
            width: columnWidths['Observaciones']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _observations,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'ID',
            width: columnWidths['ID']!,
            visible: false,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _visitId,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Caso ID',
            width: columnWidths['Caso ID']!,
            visible: false,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _caseId,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Punto ID',
            width: columnWidths['Punto ID']!,
            visible: false,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _pointId,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Madre, padre o tutor ID',
            width: columnWidths['Madre, padre o tutor ID']!,
            visible: false,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _tutorId,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Niño/a ID',
            width: columnWidths['Niño/a ID']!,
            visible: false,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _childId,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    visitDataGridSource = VisitDataGridSource(List.empty());
    selectedLocale = model.locale.toString();

    _chefValidation = 'Validación Médico Jefe';
    _regionalValidation = 'Validación Dirección Regional';
    _point = 'Punto';
    _tutor = 'Madre, padre o tutor';
    _child = 'Niño/a';
    _case = 'Caso';
    _admission = 'Admisión';
    _createDate = 'Fecha de alta';
    _height = 'Altura (cm)';
    _weight = 'Peso (kg)';
    _imc = 'IMC';
    _armCirunference = 'Perímetro braquial (cm)';
    _status = 'Estado';
    _edema = 'Edema';
    _respirationStatus = 'Respiración';
    _appetiteTest = 'Apetito';
    _infection = 'Infección';
    _eyesDeficiency = 'Deficiencia ojos';
    _deshidratation = 'Deshidratación';
    _vomiting = 'Vómitos';
    _diarrhea = 'Diarrea';
    _fever = 'Fiebre';
    _temperature = 'Temperatura';
    _cough = 'Tos';
    _vaccinationCard = 'Carta de vacunación';
    _rubeolaVaccinated = 'Vacunación rubéola';
    _vitamineAVaccinated = 'Programa de vacunación Vitamina A';
    _acidFolicAndFerroVaccinated = 'Vacunación Ácido fólico y Hierro';
    _amoxicilina = 'Amoxicilina';
    _otherTratments = 'Otros tratamientos';
    _complicationsES = 'Complicaciones (ES)';
    _complicationsEN = 'Complicaciones (EN)';
    _complicationsFR = 'Complicaciones (FR)';
    _observations = 'Observaciones';
    _visitId = 'ID';
    _caseId = 'Caso ID';
    _pointId = 'Punto ID';
    _tutorId = 'Madre, padre o tutor ID';
    _childId = 'Niño/a ID';

    _exportXLS = 'Exportar XLS';
    _exportPDF = 'Exportar PDF';
    _total = 'Visitas totales';
    _visits = 'Visitas';
    _validateData = 'VALIDAR DATOS';
  }


  @override
  Widget buildSample(BuildContext context) {
    return Consumer(
        builder: (context, ref, child) {
          ref.listen<AsyncValue>(
            visitsScreenControllerProvider,
                (_, state) => {
            },
          );

          if (User.currentRole == 'medico-jefe') {
            final pointsAsyncValue = ref.watch(pointsByProvinceStreamProvider);
            if (pointsAsyncValue.value != null) {
              final points = pointsAsyncValue.value!;
              if (pointsIds.isEmpty) {
                pointsIds = points.map((e) => e.pointId).toList();
              }
              visitsAsyncValue = ref.watch(visitsByPointsStreamProvider(pointsIds));
            }
          } else if (User.currentRole == 'direccion-regional-salud') {
            final pointsAsyncValue = ref.watch(pointsByRegionStreamProvider);
            if (pointsAsyncValue.value != null) {
              final points = pointsAsyncValue.value!;
              if (pointsIds.isEmpty) {
                pointsIds = points.map((e) => e.pointId).toList();
              }
              visitsAsyncValue = ref.watch(visitsByPointsStreamProvider(pointsIds));
            }
          } else {
            visitsAsyncValue = ref.watch(visitsStreamProvider);
          }

          if (visitsAsyncValue.value != null) {
            _saveVisits(visitsAsyncValue);
          }
          return _buildView(visitsAsyncValue);
        });
  }

}



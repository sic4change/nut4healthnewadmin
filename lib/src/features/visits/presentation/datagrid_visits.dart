/// Package imports
/// import 'package:flutter/foundation.dart';

import 'package:adminnut4health/src/features/visits/domain/visitCombined.dart';
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

  late String currentUserEmail;
  var currentUserRole = "";

  /// Translate names
  late String _point, _tutor, _child, _case, _admission, _createDate,  _height, _weight, _imc,
      _armCirunference, _status, _edema, _respirationStatus, _appetiteTest,
      _infection, _eyesDeficiency, _deshidratation, _vomiting, _diarrhea, _fever,
      _cough, _vaccinationCard, _rubeolaVaccinated, _vitamineAVaccinated,
      _acidFolicAndFerroVaccinated, _complicationsES, _complicationsEN, _complicationsFR,
      _observations, _exportXLS, _exportPDF, _total, _visits;

  late Map<String, double> columnWidths = {
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
    'Tos': 150,
    'Carta de vacunación': 150,
    'Vacunación rubéola': 150,
    'Programa de vacunación Vitamina A': 150,
    'Vacunación Ácido fólico y Hierro': 150,
    'Complicaciones (ES)': 200,
    'Complicaciones (EN)': 200,
    'Complicaciones (FR)': 200,
    'Observaciones': 150,
  };

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
    if (visits.value != null && visits.value!.isNotEmpty) {
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
        });
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

    if (currentUserRole == 'super-admin') {
      return Row(
        children: <Widget>[
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
        _cough = 'Cough';
        _vaccinationCard = 'Vaccination card';
        _rubeolaVaccinated = 'Rubeola vaccinated';
        _vitamineAVaccinated = 'Vitamine A Vaccinated';
        _acidFolicAndFerroVaccinated = 'Acid Folic and Iron Vaccinated';
        _complicationsES = 'Complications (ES)';
        _complicationsEN = 'Complications (EN)';
        _complicationsFR = 'Complications (FR)';
        _observations = 'Observations';

        _exportXLS = 'Export XLS';
        _exportPDF = 'Export PDF';
        _total = 'Total visits';
        _visits = 'Visits';
        break;
      case 'es_ES':
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
        _cough = 'Tos';
        _vaccinationCard = 'Carta de vacunación';
        _rubeolaVaccinated = 'Vacunación rubéola';
        _vitamineAVaccinated = 'Programa de vacunación Vitamina A';
        _acidFolicAndFerroVaccinated = 'Vacunación Ácido fólico y Hierro';
        _complicationsES = 'Complicaciones (ES)';
        _complicationsEN = 'Complicaciones (EN)';
        _complicationsFR = 'Complicaciones (FR)';
        _observations = 'Observaciones';

        _exportXLS = 'Exportar XLS';
        _exportPDF = 'Exportar PDF';
        _total = 'Visitas totales';
        _visits = 'Visitas';
        break;
      case 'fr_FR':
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
        _cough = 'Toux';
        _vaccinationCard = 'Carnet de vaccination';
        _rubeolaVaccinated = 'Vacciné contre la rubéole';
        _vitamineAVaccinated = 'Programme de vaccination à la vitamine A';
        _acidFolicAndFerroVaccinated = 'Vaccination acide folique et fer';
        _complicationsES = 'Complications (ES)';
        _complicationsEN = 'Complications (EN)';
        _complicationsFR = 'Complications (FR)';
        _observations = 'Observations';

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
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    visitDataGridSource = VisitDataGridSource(List.empty());
    selectedLocale = model.locale.toString();

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
    _cough = 'Tos';
    _vaccinationCard = 'Carta de vacunación';
    _rubeolaVaccinated = 'Vacunación rubéola';
    _vitamineAVaccinated = 'Programa de vacunación Vitamina A';
    _acidFolicAndFerroVaccinated = 'Vacunación Ácido fólico y Hierro';
    _complicationsES = 'Complicaciones (ES)';
    _complicationsEN = 'Complicaciones (EN)';
    _complicationsFR = 'Complicaciones (FR)';
    _observations = 'Observaciones';

    _exportXLS = 'Exportar XLS';
    _exportPDF = 'Exportar PDF';
    _total = 'Visitas totales';
    _visits = 'Visitas';
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
          final user = ref.watch(authRepositoryProvider).currentUser;
          if (user != null && user.metadata != null && user.metadata!.lastSignInTime != null) {
            final claims = user.getIdTokenResult();
            claims.then((value) => {
              if (value.claims != null && value.claims!['donante'] == true && currentUserRole != "donante") {
                setState(() {
                  currentUserRole = 'donante';
                }),
              } else if (value.claims != null && value.claims!['super-admin'] == true && currentUserRole != "super-admin") {
                setState(() {
                  currentUserRole = 'super-admin';
                }),
              }
            });

            currentUserEmail = user.email??"";
          }
          final visitsAsyncValue = ref.watch(visitsStreamProvider);
          if (visitsAsyncValue.value != null) {
            _saveVisits(visitsAsyncValue);
          }
          return _buildView(visitsAsyncValue);
        });
  }

}



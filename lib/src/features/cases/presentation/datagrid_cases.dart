/// Package imports
/// import 'package:flutter/foundation.dart';

import 'package:adminnut4health/src/features/cases/domain/case.dart';
import 'package:adminnut4health/src/features/cases/domain/caseWithPointChildAndTutor.dart';
import 'package:adminnut4health/src/features/users/domain/user.dart';
import 'package:adminnut4health/src/utils/alert_dialogs.dart';
import 'package:adminnut4health/src/utils/functions.dart';
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

import 'cases_screen_controller.dart';
import 'case_datagridsource.dart';

import '../../../common_widgets/export/save_file_mobile.dart'
if (dart.library.html) '../../../common_widgets/export/save_file_web.dart' as helper;

import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Render child data grid
class CaseDataGrid extends LocalizationSampleView {
  /// Creates getting started data grid
  const CaseDataGrid({Key? key}) : super(key: key);

  @override
  _CaseDataGridState createState() => _CaseDataGridState();
}

// TODO: Message when validating
class _CaseDataGridState extends LocalizationSampleViewState {

  final GlobalKey<SfDataGridState> _key = GlobalKey<SfDataGridState>();

  /// DataGridSource required for SfDataGrid to obtain the row data.
  late CaseDataGridSource caseDataGridSource;

  static const double dataPagerHeight = 60;
  int _rowsPerPage = 15;

  /// Selected locale
  late String selectedLocale;

  /// Translate names
  late String _chefValidation, _regionalValidation, _point, _tutor, _fefa, _child, _name,
      _admissionType, _admissionTypeServer, _closedReason, _createDate, _lastDate, _visits,
      _observations, _status, _exportXLS, _exportPDF, _total, _cases, _validateData,
      _pointId, _caseId, _tutorId, _childId;

  late Map<String, double> columnWidths = {
    'FEFA': 150,
    'Validación Médico Jefe': 200,
    'Validación Dirección Regional': 200,
    'Punto': 150,
    'Madre, padre o tutor': 150,
    'Niño/a': 150,
    'Nombre': 150,
    'Tipo de admisión': 150,
    'Servidor tipo de admisión': 150,
    'Razón de cierre': 150,
    'Fecha de alta': 150,
    'Última visita': 150,
    'Nº visitas': 150,
    'Observaciones': 150,
    'Estado': 150,
    'Caso ID': 200,
    'Punto ID': 200,
    'Madre, padre o tutor ID': 200,
    'Niño/a ID': 200,
  };

  AsyncValue<List<CaseWithPointChildAndTutor>> casesAsyncValue = AsyncValue.data(List.empty());
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

  _saveCases(AsyncValue<List<CaseWithPointChildAndTutor>>? cases) {
    if (cases == null) {
      caseDataGridSource.setCases(List.empty());
    } else {
      caseDataGridSource.setCases(cases.value);
    }
  }

  Widget _buildView(AsyncValue<List<CaseWithPointChildAndTutor>> cases) {
    if (cases.value != null) {
      caseDataGridSource.buildDataGridRows();
      caseDataGridSource.updateDataSource();
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
          if (caseDataGridSource.getCases()!.isEmpty) {
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
          excludeColumns: ['Madre, padre o tutor', 'Niño/a'],
          cellExport: (DataGridCellExcelExportDetails details) {

          });
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();
      await helper.FileSaveHelper.saveAndLaunchFile(bytes, '$_cases.xlsx');
    }

    Future<void> exportDataGridToPdf() async {
      exportDataGridToPdfStandard(
        dataGridState: _key.currentState!,
        title: _cases,
        excludeColumns: ['Caso ID', 'Punto ID', 'Madre, padre o tutor ID', 'Niño/a ID', 'Madre, padre o tutor', 'Niño/a'],
      );
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

  Widget _buildValidationButton({required VoidCallback onPressed}) {
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
    final cases = caseDataGridSource.getCases()!.where((c) => !c.myCase.chefValidation);
    for (var c in cases) {
      ref.read(casesScreenControllerProvider.notifier).updateCase(
        Case(
            caseId: c.myCase.caseId,
            pointId: c.myCase.pointId,
            childId: c.myCase.childId,
            tutorId: c.myCase.tutorId,
            fefaId: c.myCase.fefaId,
            name: c.myCase.name,
            admissionType: c.myCase.admissionType,
            admissionTypeServer: c.myCase.admissionTypeServer,
            closedReason: c.myCase.closedReason,
            createDate: c.myCase.createDate,
            lastDate: c.myCase.lastDate,
            observations: c.myCase.observations,
            status: c.myCase.status,
            visits: c.myCase.visits,
            chefValidation: true,
            regionalValidation: c.myCase.regionalValidation)
      );
    }}

  Future<void> regionalValidation() async {
    final casesWithChefValidation = caseDataGridSource.getCases()!.where((c) => c.myCase.chefValidation && !c.myCase.regionalValidation);
    for (var c in casesWithChefValidation) {
      ref.read(casesScreenControllerProvider.notifier).updateCase(
        Case(
            caseId: c.myCase.caseId,
            pointId: c.myCase.pointId,
            childId: c.myCase.childId,
            tutorId: c.myCase.tutorId,
            fefaId: c.myCase.fefaId,
            name: c.myCase.name,
            admissionType: c.myCase.admissionType,
            admissionTypeServer: c.myCase.admissionTypeServer,
            closedReason: c.myCase.closedReason,
            createDate: c.myCase.createDate,
            lastDate: c.myCase.lastDate,
            observations: c.myCase.observations,
            status: c.myCase.status,
            visits: c.myCase.visits,
            chefValidation: c.myCase.chefValidation,
            regionalValidation: true)
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
    var rows = caseDataGridSource.rows;
    if (caseDataGridSource.effectiveRows.isNotEmpty ) {
      rows = caseDataGridSource.effectiveRows;
    }
    var addMorePage = 0;
    if ((rows.length / _rowsPerPage).remainder(1) != 0) {
      addMorePage  = 1;
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SfDataPager(
        delegate: caseDataGridSource,
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
        _fefa = 'FEFA';
        _child = 'Child';
        _name = 'Name';
        _admissionType = 'Admission type';
        _admissionTypeServer = 'Admission type server';
        _closedReason = 'Closed reason';
        _createDate = 'Register date';
        _lastDate = 'Last date';
        _visits = 'Visits number';
        _observations = 'Observations';
        _status = 'Status';
        _caseId = 'Case ID';
        _pointId = 'Point ID';
        _tutorId = 'Mother, father or tutor ID';
        _childId = 'Child ID';

        _exportXLS = 'Export XLS';
        _exportPDF = 'Export PDF';
        _total = 'Total cases';
        _cases = 'Cases';
        break;
      case 'es_ES':
        _chefValidation = 'Validación Médico Jefe';
        _regionalValidation = 'Validación Dirección Regional';
        _point = 'Punto';
        _name = 'Nombre';
        _admissionType = 'Tipo de admisión';
        _admissionTypeServer = 'Servidor tipo de admisión';
        _closedReason = 'Razón de cierre';
        _tutor = 'Madre, padre o tutor';
        _fefa = 'FEFA';
        _child = 'Niño/a';
        _createDate = 'Fecha de alta';
        _lastDate = 'Última visita';
        _visits = 'Nº visitas';
        _observations = 'Observaciones';
        _status = 'Estado';
        _caseId = 'Caso ID';
        _pointId = 'Punto ID';
        _tutorId = 'Madre, padre o tutor ID';
        _childId = 'Niño/a ID';

        _exportXLS = 'Exportar XLS';
        _exportPDF = 'Exportar PDF';
        _total = 'Casos totales';
        _cases = 'Casos';
        break;
      case 'fr_FR':
        _chefValidation = 'Validation du médecin-chef';
        _regionalValidation = 'Validation direction régionale de la santé';
        _point = 'Place';
        _name = 'Nom';
        _admissionType = 'Type d\'admission';
        _admissionTypeServer = 'Serveur type d\'admission';
        _closedReason = 'Motif fermé';
        _tutor = 'Mère, père ou tuteur';
        _fefa = 'FEFA';
        _child = 'Enfant';
        _createDate = 'Date d\'enregistrement';
        _lastDate = 'Derniere visite';
        _visits = 'Nombre de visites';
        _observations = 'Observations';
        _status = 'État';
        _caseId = 'Cas ID';
        _pointId = 'Place ID';
        _tutorId = 'Mère, père ou tuteur ID';
        _childId = 'Enfant ID';

        _exportXLS = 'Exporter XLS';
        _exportPDF = 'Exporter PDF';
        _total = 'Total de cas';
        _cases = 'Cas';
        break;
    }

    return SfDataGrid(
      key: _key,
      source: caseDataGridSource,
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
            columnName: 'FEFA',
            width: columnWidths['FEFA']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _fefa,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
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
            columnName: 'Nombre',
            width: columnWidths['Nombre']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _name,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Tipo de admisión',
            width: columnWidths['Tipo de admisión']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _admissionType,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Servidor tipo de admisión',
            width: columnWidths['Servidor tipo de admisión']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _admissionTypeServer,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Razón de cierre',
            width: columnWidths['Razón de cierre']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _closedReason,
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
            columnName: 'Última visita',
            width: columnWidths['Última visita']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _lastDate,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Nº visitas',
            width: columnWidths['Nº visitas']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _visits,
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
    caseDataGridSource = CaseDataGridSource(List.empty());
    selectedLocale = model.locale.toString();

    _chefValidation = 'Validación Médico Jefe';
    _regionalValidation = 'Validación Dirección Regional';
    _point = 'Punto';
    _name = 'Nombre';
    _admissionType = 'Tipo de admisión';
    _admissionTypeServer = 'Servidor tipo de admisión';
    _closedReason = 'Razón de cierre';
    _tutor = 'Madre, padre o tutor';
    _fefa = 'FEFA';
    _child = 'Niño/a';
    _createDate = 'Fecha de alta';
    _lastDate = 'Última visita';
    _visits = 'Nº visitas';
    _observations = 'Observaciones';
    _status = 'Estado';
    _caseId = 'Caso ID';
    _pointId = 'Punto ID';
    _tutorId = 'Madre, padre o tutor ID';
    _childId = 'Niño/a ID';

    _exportXLS = 'Exportar XLS';
    _exportPDF = 'Exportar PDF';
    _total = 'Casos totales';
    _cases = 'Casos';
    _validateData = 'VALIDAR DATOS';
  }


  @override
  Widget buildSample(BuildContext context) {
    return Consumer(
        builder: (context, ref, child) {
          ref.listen<AsyncValue>(
            casesScreenControllerProvider,
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
              casesAsyncValue = ref.watch(casesByPointsStreamProvider(pointsIds));
            }
          } else if (User.currentRole == 'direccion-regional-salud') {
            final pointsAsyncValue = ref.watch(pointsByRegionStreamProvider);
            if (pointsAsyncValue.value != null) {
              final points = pointsAsyncValue.value!;
              if (pointsIds.isEmpty) {
                pointsIds = points.map((e) => e.pointId).toList();
              }
              casesAsyncValue = ref.watch(casesByPointsStreamProvider(pointsIds));
            }
          } else {
            casesAsyncValue = ref.watch(casesStreamProvider);
          }

          if (casesAsyncValue.value != null) {
            _saveCases(casesAsyncValue);
          }
          return _buildView(casesAsyncValue);
        });
  }

}



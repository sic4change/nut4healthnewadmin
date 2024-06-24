/// Package imports
/// import 'package:flutter/foundation.dart';

import 'package:adminnut4health/src/features/users/domain/user.dart';
import 'package:adminnut4health/src/features/visitsWithoutDiagnosis/domain/visitWithoutDiagnosisCombined.dart';
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

import 'visits_without_diagnosis_screen_controller.dart';
import 'visit_without_diagnosis_datagridsource.dart';

import '../../../common_widgets/export/save_file_mobile.dart'
if (dart.library.html) '../../../common_widgets/export/save_file_web.dart' as helper;

import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Render child data grid
class VisitWithoutDiagnosisDataGrid extends LocalizationSampleView {
  /// Creates getting started data grid
  const VisitWithoutDiagnosisDataGrid({Key? key}) : super(key: key);

  @override
  _VisitWithoutDiagnosisDataGridState createState() => _VisitWithoutDiagnosisDataGridState();
}

class _VisitWithoutDiagnosisDataGridState extends LocalizationSampleViewState {

  final GlobalKey<SfDataGridState> _key = GlobalKey<SfDataGridState>();

  /// DataGridSource required for SfDataGrid to obtain the row data.
  late VisitWithoutDiagnosisDataGridSource visitDataGridSource;

  static const double dataPagerHeight = 60;
  int _rowsPerPage = 15;

  /// Selected locale
  late String selectedLocale;

  /// Translate names
  late String _point, _tutor, _fefa, _child, _createDate,  _height, _weight, _imc,
      _armCirunference, _observations, _exportXLS, _exportPDF,
      _total, _visits, _pointId, _visitId, _tutorId, _childId;

  late Map<String, double> columnWidths = {
    'FEFA': 150,
    'Punto': 150,
    'Madre, padre o tutor': 150,
    'Niño/a': 150,
    'Fecha de alta': 150,
    'Altura (cm)': 150,
    'Peso (kg)': 150,
    'IMC': 150,
    'Perímetro braquial (cm)': 150,
    'Observaciones': 150,
    'ID': 200,
    'Punto ID': 200,
    'Madre, padre o tutor ID': 200,
    'Niño/a ID': 200,
  };

  AsyncValue<List<VisitWithoutDiagnosisCombined>> visitsWithoutDiagnosisAsyncValue = AsyncValue.data(List.empty());
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

  _saveVisitsWithoutDiagnosis(AsyncValue<List<VisitWithoutDiagnosisCombined>>? visits) {
    if (visits == null) {
      visitDataGridSource.setVisitsWithoutDiagnosis(List.empty());
    } else {
      visitDataGridSource.setVisitsWithoutDiagnosis(visits.value);
    }
  }

  Widget _buildView(AsyncValue<List<VisitWithoutDiagnosisCombined>> visits) {
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
          if (visitDataGridSource.getVisitsWithoutDiagnosis()!.isEmpty) {
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
      exportDataGridToPdfStandard(
        dataGridState: _key.currentState!,
        title: _visits,
        excludeColumns: ['ID', 'Punto ID', 'Madre, padre o tutor ID', 'Niño/a ID'],
      );
    }

    return Row(
      children: <Widget>[
        _buildPDFExportingButton(_exportPDF, onPressed: exportDataGridToPdf),
        _buildExcelExportingButton(_exportXLS, onPressed: exportDataGridToExcel),
      ],
    );
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
        _fefa = 'FEFA';
        _child = 'Child';
        _createDate = 'Register date';
        _height = 'Height (cm)';
        _weight = 'Weight (kg)';
        _imc = 'BMI';
        _armCirunference = 'Arm circumference (cm)';
        _observations = 'Observations';
        _visitId = 'ID';
        _pointId = 'Point ID';
        _tutorId = 'Mother, father or tutor ID';
        _childId = 'Child ID:';

        _exportXLS = 'Export XLS';
        _exportPDF = 'Export PDF';
        _total = 'Total visits without case';
        _visits = 'Visits without case';
        break;
      case 'es_ES':
        _point = 'Punto';
        _tutor = 'Madre, padre o tutor';
        _fefa = 'FEFA';
        _child = 'Niño/a';
        _createDate = 'Fecha de alta';
        _height = 'Altura (cm)';
        _weight = 'Peso (kg)';
        _imc = 'IMC';
        _armCirunference = 'Perímetro braquial (cm)';
        _observations = 'Observaciones';
        _visitId = 'ID';
        _pointId = 'Punto ID';
        _tutorId = 'Madre, padre o tutor ID';
        _childId = 'Niño/a ID';

        _exportXLS = 'Exportar XLS';
        _exportPDF = 'Exportar PDF';
        _total = 'Visitas sin caso totales';
        _visits = 'Visitas sin caso';
        break;
      case 'fr_FR':
        _point = 'Place';
        _tutor = 'Mère, père ou tuteur';
        _fefa = 'FEFA';
        _child = 'Enfant';
        _createDate = 'Date d\'enregistrement';
        _height = 'Taille (cm)';
        _weight = 'Poids (kg)';
        _imc = 'IMC';
        _armCirunference = 'Circonférence du bras (cm)';
        _observations = 'Observations';
        _visitId = 'ID';
        _pointId = 'Place ID';
        _tutorId = 'Mère, père ou tuteur ID';
        _childId = 'Enfant ID:';

        _exportXLS = 'Exporter XLS';
        _exportPDF = 'Exporter PDF';
        _total = 'Total de visites sans cas';
        _visits = 'Visites sans cas';
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
    visitDataGridSource = VisitWithoutDiagnosisDataGridSource(List.empty());
    selectedLocale = model.locale.toString();

    _point = 'Punto';
    _tutor = 'Madre, padre o tutor';
    _fefa = 'FEFA';
    _child = 'Niño/a';
    _createDate = 'Fecha de alta';
    _height = 'Altura (cm)';
    _weight = 'Peso (kg)';
    _imc = 'IMC';
    _armCirunference = 'Perímetro braquial (cm)';
    _observations = 'Observaciones';
    _visitId = 'ID';
    _pointId = 'Punto ID';
    _tutorId = 'Madre, padre o tutor ID';
    _childId = 'Niño/a ID';

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
            visitsWithoutDiagnosisScreenControllerProvider,
                (_, state) => {
            },
          );

          /*if (User.currentRole == 'medico-jefe') {
            final pointsAsyncValue = ref.watch(pointsByProvinceStreamProvider);
            if (pointsAsyncValue.value != null) {
              final points = pointsAsyncValue.value!;
              if (pointsIds.isEmpty) {
                pointsIds = points.map((e) => e.pointId).toList();
              }
              visitsWithoutDiagnosisAsyncValue = ref.watch(visitsByPointsStreamProvider(pointsIds));
            }
          } else if (User.currentRole == 'direccion-regional-salud') {
            final pointsAsyncValue = ref.watch(pointsByRegionStreamProvider);
            if (pointsAsyncValue.value != null) {
              final points = pointsAsyncValue.value!;
              if (pointsIds.isEmpty) {
                pointsIds = points.map((e) => e.pointId).toList();
              }
              visitsWithoutDiagnosisAsyncValue = ref.watch(visitsByPointsStreamProvider(pointsIds));
            }
          } else {*/
          visitsWithoutDiagnosisAsyncValue = ref.watch(visitsWithoutDiagnosisStreamProvider);
          //}

          if (visitsWithoutDiagnosisAsyncValue.value != null) {
            _saveVisitsWithoutDiagnosis(visitsWithoutDiagnosisAsyncValue);
          }
          return _buildView(visitsWithoutDiagnosisAsyncValue);
        });
  }

}



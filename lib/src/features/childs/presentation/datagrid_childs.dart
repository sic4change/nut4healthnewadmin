/// Package imports
/// import 'package:flutter/foundation.dart';

import 'package:adminnut4health/src/features/childs/domain/child.dart';
import 'package:adminnut4health/src/features/childs/domain/childWithPointAndTutor.dart';
import 'package:adminnut4health/src/features/users/domain/user.dart';
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

import 'childs_screen_controller.dart';
import 'child_datagridsource.dart';

import '../../../common_widgets/export/save_file_mobile.dart'
if (dart.library.html) '../../../common_widgets/export/save_file_web.dart' as helper;

import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Render child data grid
class ChildDataGrid extends LocalizationSampleView {
  /// Creates getting started data grid
  const ChildDataGrid({Key? key}) : super(key: key);

  @override
  _ChildDataGridState createState() => _ChildDataGridState();
}

class _ChildDataGridState extends LocalizationSampleViewState {

  final GlobalKey<SfDataGridState> _key = GlobalKey<SfDataGridState>();

  /// DataGridSource required for SfDataGrid to obtain the row data.
  late ChildDataGridSource childDataGridSource;

  static const double dataPagerHeight = 60;
  int _rowsPerPage = 15;

  /// Selected locale
  late String selectedLocale;

  /// Translate names
  late String _chefValidation, _regionalValidation, _point, _name, _surnames, _birthdate, _code, _createDate, _lastDate,
      _ethnicity, _sex, _tutor, _observations, _exportXLS, _exportPDF, _total,
      _childs, _validateData;

  late Map<String, double> columnWidths = {
    'Validación Médico Jefe': 200,
    'Validación Dirección Regional': 200,
    'Punto': 150,
    'Nombre': 150,
    'Apellidos': 150,
    'Fecha de nacimiento': 150,
    'Código': 150,
    'Fecha de alta': 150,
    'Última visita': 150,
    'Idioma': 150,
    'Sexo': 150,
    'Madre, padre o tutor': 150,
    'Observaciones': 150,
  };

  AsyncValue<List<ChildWithPointAndTutor>> childrenAsyncValue = AsyncValue.data(List.empty());
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

  _saveChildren(AsyncValue<List<ChildWithPointAndTutor>>? childs) {
    if (childs == null) {
      childDataGridSource.setChilds(List.empty());
    } else {
      childDataGridSource.setChilds(childs.value);
    }
  }

  Widget _buildView(AsyncValue<List<ChildWithPointAndTutor>> childs) {
    if (childs.value != null) {
      childDataGridSource.buildDataGridRows();
      childDataGridSource.updateDataSource();
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
          if (childDataGridSource.getChilds()!.isEmpty) {
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
      await helper.FileSaveHelper.saveAndLaunchFile(bytes, '$_childs.xlsx');
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
              _childs,
              PdfStandardFont(PdfFontFamily.helvetica, 13,
                  style: PdfFontStyle.bold),
              bounds: const Rect.fromLTWH(0, 25, 200, 60),
            );

            details.pdfDocumentTemplate.top = header;
          });
      final List<int> bytes = document.saveSync();
      await helper.FileSaveHelper.saveAndLaunchFile(bytes, '$_childs.pdf');
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
    final children = childDataGridSource.getChilds()!.where((c) => !c.child.chefValidation);
    for (var c in children) {
      ref.read(childsScreenControllerProvider.notifier).updateChild(
          Child(
              childId: c.child.childId,
              tutorId: c.child.tutorId,
              pointId: c.child.pointId,
              name: c.child.name,
              surnames: c.child.surnames,
              birthdate: c.child.birthdate,
              code: c.child.code,
              createDate: c.child.createDate,
              lastDate: c.child.lastDate,
              ethnicity: c.child.ethnicity,
              sex: c.child.sex,
              observations: c.child.observations,
              chefValidation: true,
              regionalValidation: c.child.regionalValidation
          )
      );
    }}

  Future<void> regionalValidation() async {
    final childrenWithChefValidation = childDataGridSource.getChilds()!.where((c) => c.child.chefValidation && !c.child.regionalValidation);
    for (var c in childrenWithChefValidation) {
      ref.read(childsScreenControllerProvider.notifier).updateChild(
          Child(
              childId: c.child.childId,
              tutorId: c.child.tutorId,
              pointId: c.child.pointId,
              name: c.child.name,
              surnames: c.child.surnames,
              birthdate: c.child.birthdate,
              code: c.child.code,
              createDate: c.child.createDate,
              lastDate: c.child.lastDate,
              ethnicity: c.child.ethnicity,
              sex: c.child.sex,
              observations: c.child.observations,
              chefValidation: c.child.chefValidation,
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
    var rows = childDataGridSource.rows;
    if (childDataGridSource.effectiveRows.isNotEmpty ) {
      rows = childDataGridSource.effectiveRows;
    }
    var addMorePage = 0;
    if ((rows.length / _rowsPerPage).remainder(1) != 0) {
      addMorePage  = 1;
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SfDataPager(
        delegate: childDataGridSource,
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
        _name = 'Name';
        _surnames = 'Surnames';
        _birthdate = 'Birthdate';
        _code = 'Code';
        _createDate = 'Register date';
        _lastDate = 'Last date';
        _ethnicity = 'Ethnicity';
        _sex = 'Sex';
        _tutor = 'Mother, father or tutor';
        _observations = 'Observations';

        _exportXLS = 'Export XLS';
        _exportPDF = 'Export PDF';
        _total = 'Total Children';
        _childs = 'Children';
        break;
      case 'es_ES':
        _chefValidation = 'Validación Médico Jefe';
        _regionalValidation = 'Validación Dirección Regional';
        _point = 'Punto';
        _name = 'Nombre';
        _surnames = 'Apellidos';
        _birthdate = 'Fecha de nacimiento';
        _code = 'Código';
        _createDate = 'Fecha de alta';
        _lastDate = 'Última visita';
        _ethnicity = 'Idioma';
        _sex = 'Sexo';
        _tutor = 'Madre, padre o tutor';
        _observations = 'Observaciones';

        _exportXLS = 'Exportar XLS';
        _exportPDF = 'Exportar PDF';
        _total = 'Niños/as totales';
        _childs = 'Niños/as';
        break;
      case 'fr_FR':
        _chefValidation = 'Validation du médecin-chef';
        _regionalValidation = 'Validation direction régionale de la santé';
        _point = 'Place';
        _name = 'Nom';
        _surnames = 'Noms de famille';
        _birthdate = 'Date de naissance';
        _code = 'Code';
        _createDate = 'Date d\'enregistrement';
        _lastDate = 'Derniere visite';
        _ethnicity = 'Langue';
        _sex = 'Sexe';
        _tutor = 'Mère, père ou tuteur';
        _observations = 'Observations';

        _exportXLS = 'Exporter XLS';
        _exportPDF = 'Exporter PDF';
        _total = 'Total des enfants';
        _childs = 'Enfants';
        break;
    }

    return SfDataGrid(
      key: _key,
      source: childDataGridSource,
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
            columnName: 'Apellidos',
            width: columnWidths['Apellidos']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _surnames,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Fecha de nacimiento',
            width: columnWidths['Fecha de nacimiento']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _birthdate,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Código',
            width: columnWidths['Código']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _code,
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
            columnName: 'Idioma',
            width: columnWidths['Idioma']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _ethnicity,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Sexo',
            width: columnWidths['Sexo']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _sex,
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
    childDataGridSource = ChildDataGridSource(List.empty());
    selectedLocale = model.locale.toString();

    _chefValidation = 'Validación Médico Jefe';
    _regionalValidation = 'Validación Dirección Regional';
    _point = 'Punto';
    _name = 'Nombre';
    _surnames = 'Apellidos';
    _birthdate = 'Fecha de nacimiento';
    _code = 'Código';
    _createDate = 'Fecha de alta';
    _lastDate = 'Última visita';
    _ethnicity = 'Idioma';
    _sex = 'Sexo';
    _tutor = 'Madre, padre o tutor';
    _observations = 'Observaciones';

    _exportXLS = 'Exportar XLS';
    _exportPDF = 'Exportar PDF';
    _total = 'Niños/as totales';
    _childs = 'Niños/as';
    _validateData = 'VALIDAR DATOS';
  }


  @override
  Widget buildSample(BuildContext context) {
    return Consumer(
        builder: (context, ref, child) {
          ref.listen<AsyncValue>(
            childsScreenControllerProvider,
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
              childrenAsyncValue = ref.watch(childrenByPointsStreamProvider(pointsIds));
            }
          } else if (User.currentRole == 'direccion-regional-salud') {
            final pointsAsyncValue = ref.watch(pointsByRegionStreamProvider);
            if (pointsAsyncValue.value != null) {
              final points = pointsAsyncValue.value!;
              if (pointsIds.isEmpty) {
                pointsIds = points.map((e) => e.pointId).toList();
              }
              childrenAsyncValue = ref.watch(childrenByPointsStreamProvider(pointsIds));
            }
          } else {
            childrenAsyncValue = ref.watch(childsStreamProvider);
          }

          if (childrenAsyncValue.value != null) {
            _saveChildren(childrenAsyncValue);
          }
          return _buildView(childrenAsyncValue);
        });
  }

}



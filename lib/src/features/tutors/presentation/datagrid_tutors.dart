/// Package imports
/// import 'package:flutter/foundation.dart';

import 'package:adminnut4health/src/features/tutors/domain/tutor.dart';
import 'package:adminnut4health/src/features/tutors/domain/tutorWithPoint.dart';
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

import 'tutors_screen_controller.dart';
import 'tutor_datagridsource.dart';

import '../../../common_widgets/export/save_file_mobile.dart'
if (dart.library.html) '../../../common_widgets/export/save_file_web.dart' as helper;

import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Render tutor data grid
class TutorDataGrid extends LocalizationSampleView {
  /// Creates getting started data grid
  const TutorDataGrid({Key? key}) : super(key: key);

  @override
  _TutorDataGridState createState() => _TutorDataGridState();
}

class _TutorDataGridState extends LocalizationSampleViewState {

  final GlobalKey<SfDataGridState> _key = GlobalKey<SfDataGridState>();

  /// DataGridSource required for SfDataGrid to obtain the row data.
  late TutorDataGridSource tutorDataGridSource;

  static const double dataPagerHeight = 60;
  int _rowsPerPage = 15;

  /// Selected locale
  late String selectedLocale;

  /// Translate names
  late String _chefValidation, _regionalValidation, _point, _name, _surnames, _address, _phone, _birthdate, _createDate,
      _ethnicity, _sex, _maleRelation, _womanStatus, _babyAge, _weeks,
      _childMinor, _observations, _active, _exportXLS, _exportPDF, _total, _tutors,
      _validateData;

  late Map<String, double> columnWidths = {
    'Validación Médico Jefe': 200,
    'Validación Dirección Regional': 200,
    'Punto': 150,
    'Nombre': 150,
    'Apellidos': 150,
    'Vecindario': 150,
    'Teléfono': 150,
    'Fecha de nacimiento': 150,
    'Fecha de alta': 150,
    'Idioma': 150,
    'Sexo': 150,
    'Vínculo': 150,
    'Estado de la mujer': 150,
    'Edad del bebé': 150,
    'Semanas': 150,
    'Hijos/as menores a 6 meses': 150,
    'Observaciones': 150,
    'Activo': 150,
  };

  AsyncValue<List<TutorWithPoint>> tutorsAsyncValue = AsyncValue.data(List.empty());
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

  _saveTutors(AsyncValue<List<TutorWithPoint>>? tutors) {
    if (tutors == null) {
      tutorDataGridSource.setTutors(List.empty());
    } else {
      tutorDataGridSource.setTutors(tutors.value);
    }
  }

  Widget _buildView(AsyncValue<List<TutorWithPoint>> tutors) {
    if (tutors.value != null) {
      tutorDataGridSource.buildDataGridRows();
      tutorDataGridSource.updateDataSource();
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
          if (tutorDataGridSource.getTutors()!.isEmpty) {
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
          excludeColumns: <String>['Nombre', 'Apellidos', 'Vecindario', 'Teléfono', 'Fecha de nacimiento'],
          cellExport: (DataGridCellExcelExportDetails details) {

          });
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();
      await helper.FileSaveHelper.saveAndLaunchFile(bytes, '$_tutors.xlsx');
    }

    Future<void> exportDataGridToPdf() async {
      final ByteData data = await rootBundle.load('images/nut_logo.jpg');
      final PdfDocument document = _key.currentState!.exportToPdfDocument(
          fitAllColumnsInOnePage: true,
          cellExport: (DataGridCellPdfExportDetails details) {

          },
          excludeColumns: <String>['Nombre', 'Apellidos', 'Vecindario', 'Teléfono', 'Fecha de nacimiento'],
          headerFooterExport: (DataGridPdfHeaderFooterExportDetails details) {
            final double width = details.pdfPage.getClientSize().width;
            final PdfPageTemplateElement header =
            PdfPageTemplateElement(Rect.fromLTWH(0, 0, width, 65));

            header.graphics.drawImage(
                PdfBitmap(data.buffer
                    .asUint8List(data.offsetInBytes, data.lengthInBytes)),
                Rect.fromLTWH(width - 148, 0, 148, 60));

            header.graphics.drawString(
              _tutors,
              PdfStandardFont(PdfFontFamily.helvetica, 13,
                  style: PdfFontStyle.bold),
              bounds: const Rect.fromLTWH(0, 25, 200, 60),
            );

            details.pdfDocumentTemplate.top = header;
          });
      final List<int> bytes = document.saveSync();
      await helper.FileSaveHelper.saveAndLaunchFile(bytes, '$_tutors.pdf');
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
    final tutors = tutorDataGridSource.getTutors()!.where((t) => !t.tutor.chefValidation);
    for (var t in tutors) {
      ref.read(tutorsScreenControllerProvider.notifier).updateTutor(
          Tutor(
              tutorId: t.tutor.tutorId,
              pointId: t.tutor.pointId,
              name: t.tutor.name,
              surnames: t.tutor.surnames,
              address: t.tutor.address,
              phone: t.tutor.phone,
              birthdate: t.tutor.birthdate,
              createDate: t.tutor.createDate,
              ethnicity: t.tutor.ethnicity,
              sex: t.tutor.sex,
              maleRelation: t.tutor.maleRelation,
              womanStatus: t.tutor.womanStatus,
              armCircunference: t.tutor.armCircunference,
              status: t.tutor.status,
              babyAge: t.tutor.babyAge,
              weeks: t.tutor.weeks,
              childMinor: t.tutor.childMinor,
              observations: t.tutor.observations,
              active: t.tutor.active,
              chefValidation: true,
              regionalValidation: t.tutor.regionalValidation
          )
      );
    }}

  Future<void> regionalValidation() async {
    final tutorsWithChefValidation = tutorDataGridSource.getTutors()!.where((t) => t.tutor.chefValidation && !t.tutor.regionalValidation);
    for (var t in tutorsWithChefValidation) {
      ref.read(tutorsScreenControllerProvider.notifier).updateTutor(
          Tutor(
              tutorId: t.tutor.tutorId,
              pointId: t.tutor.pointId,
              name: t.tutor.name,
              surnames: t.tutor.surnames,
              address: t.tutor.address,
              phone: t.tutor.phone,
              birthdate: t.tutor.birthdate,
              createDate: t.tutor.createDate,
              ethnicity: t.tutor.ethnicity,
              sex: t.tutor.sex,
              maleRelation: t.tutor.maleRelation,
              womanStatus: t.tutor.womanStatus,
              armCircunference: t.tutor.armCircunference,
              status: t.tutor.status,
              babyAge: t.tutor.babyAge,
              weeks: t.tutor.weeks,
              childMinor: t.tutor.childMinor,
              observations: t.tutor.observations,
              active: t.tutor.active,
              chefValidation: t.tutor.chefValidation,
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
    var rows = tutorDataGridSource.rows;
    if (tutorDataGridSource.effectiveRows.isNotEmpty ) {
      rows = tutorDataGridSource.effectiveRows;
    }
    var addMorePage = 0;
    if ((rows.length / _rowsPerPage).remainder(1) != 0) {
      addMorePage  = 1;
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SfDataPager(
        delegate: tutorDataGridSource,
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
        _address = 'Address';
        _phone = 'Phone';
        _birthdate = 'Birthdate';
        _createDate = 'Register date';
        _ethnicity = 'Ethnicity';
        _sex = 'Sex';
        _maleRelation = 'Bond';
        _womanStatus = 'Womamn status';
        _babyAge = 'Baby age';
        _weeks = 'Weeks';
        _childMinor = 'Children under 6 months';
        _observations = 'Observations';
        _active = 'Active';

        _exportXLS = 'Export XLS';
        _exportPDF = 'Export PDF';
        _total = 'Total Tutors';
        _tutors = 'Tutors';
        break;
      case 'es_ES':
        _chefValidation = 'Validación Médico Jefe';
        _regionalValidation = 'Validación Dirección Regional';
        _point = 'Punto';
        _name = 'Nombre';
        _surnames = 'Apellidos';
        _address = 'Vecindario';
        _phone = 'Teléfono';
        _birthdate = 'Fecha de nacimiento';
        _createDate = 'Fecha de alta';
        _ethnicity = 'Idioma';
        _sex = 'Sexo';
        _maleRelation = 'Vínculo';
        _womanStatus = 'Estado de la mujer';
        _babyAge = 'Edad del bebé';
        _weeks = 'Semanas';
        _childMinor = 'Hijos/as menores a 6 meses';
        _observations = 'Observaciones';
        _active = 'Activo';

        _exportXLS = 'Exportar XLS';
        _exportPDF = 'Exportar PDF';
        _total = 'Tutores totales';
        _tutors = 'Tutores';
        break;
      case 'fr_FR':
        _chefValidation = 'Validation du médecin-chef';
        _regionalValidation = 'Validation direction régionale de la santé';
        _point = 'Place';
        _name = 'Nom';
        _surnames = 'Noms de famille';
        _address = 'Quartier';
        _phone = 'Téléphone';
        _birthdate = 'Date de naissance';
        _createDate = 'Date d\'enregistrement';
        _ethnicity = 'Langue';
        _sex = 'Sexe';
        _maleRelation = 'Lier';
        _womanStatus = 'État de femme';
        _babyAge = 'Âge du bébé';
        _weeks = 'Semaines';
        _childMinor = 'Enfants de moins de 6 mois';
        _observations = 'Observations';
        _active = 'Actif';

        _exportXLS = 'Exporter XLS';
        _exportPDF = 'Exporter PDF';
        _total = 'Total des tuteurs';
        _tutors = 'Tuteurs';
        break;
    }

    return SfDataGrid(
      key: _key,
      source: tutorDataGridSource,
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
            visible: false,
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
            visible: false,
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
            columnName: 'Vecindario',
            width: columnWidths['Vecindario']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _address,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            visible: false,
            columnName: 'Teléfono',
            width: columnWidths['Teléfono']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _phone,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            visible: false,
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
            columnName: 'Vínculo',
            width: columnWidths['Vínculo']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _maleRelation,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Estado de la mujer',
            width: columnWidths['Estado de la mujer']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _womanStatus,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Edad del bebé',
            width: columnWidths['Edad del bebé']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _babyAge,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Semanas',
            width: columnWidths['Semanas']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _weeks,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Hijos/as menores a 6 meses',
            width: columnWidths['Hijos/as menores a 6 meses']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _childMinor,
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
            columnName: 'Activo',
            width: columnWidths['Activo']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _active,
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
    tutorDataGridSource = TutorDataGridSource(List.empty());
    selectedLocale = model.locale.toString();

    _chefValidation = 'Validación Médico Jefe';
    _regionalValidation = 'Validación Dirección Regional';
    _point = 'Punto';
    _name = 'Nombre';
    _surnames = 'Apellidos';
    _address = 'Vecindario';
    _phone = 'Teléfono';
    _birthdate = 'Fecha de nacimiento';
    _createDate = 'Fecha de alta';
    _ethnicity = 'Idioma';
    _sex = 'Sexo';
    _maleRelation = 'Vínculo';
    _womanStatus = 'Estado de la mujer';
    _babyAge = 'Edad del bebé';
    _weeks = 'Semanas';
    _childMinor = 'Hijos/as menores a 6 meses';
    _observations = 'Observaciones';
    _active = 'Activo';
    _exportXLS = 'Exportar XLS';
    _exportPDF = 'Exportar PDF';
    _total = 'Usuarios totales';
    _tutors = 'Tutores';
    _validateData = 'VALIDAR DATOS';
  }


  @override
  Widget buildSample(BuildContext context) {
    return Consumer(
        builder: (context, ref, child) {
          ref.listen<AsyncValue>(
            tutorsScreenControllerProvider,
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
              tutorsAsyncValue = ref.watch(tutorsByPointsStreamProvider(pointsIds));
            }
          } else if (User.currentRole == 'direccion-regional-salud') {
            final pointsAsyncValue = ref.watch(pointsByRegionStreamProvider);
            if (pointsAsyncValue.value != null) {
              final points = pointsAsyncValue.value!;
              if (pointsIds.isEmpty) {
                pointsIds = points.map((e) => e.pointId).toList();
              }
              tutorsAsyncValue = ref.watch(tutorsByPointsStreamProvider(pointsIds));
            }
          } else {
            tutorsAsyncValue = ref.watch(tutorsStreamProvider);
          }

          if (tutorsAsyncValue.value != null) {
            _saveTutors(tutorsAsyncValue);
          }
          return _buildView(tutorsAsyncValue);
        });
  }

}



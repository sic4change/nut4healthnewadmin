/// Package imports
/// import 'package:flutter/foundation.dart';

import 'package:adminnut4health/src/features/complications/domain/complication.dart';
import 'package:adminnut4health/src/features/complications/presentation/complication_datagridsource.dart';
import 'package:adminnut4health/src/features/complications/presentation/complications_screen_controller.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:typed_data';
import 'dart:html' show Blob, AnchorElement, Url;

/// Barcode import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../../sample/model/sample_view.dart';
import '../../authentication/data/firebase_auth_repository.dart';

/// Local import
import '../data/firestore_repository.dart';

import 'package:file_picker/file_picker.dart';
import 'dart:html' show FileReader;

import '../../../common_widgets/export/save_file_mobile.dart'
    if (dart.library.html) '../../../common_widgets/export/save_file_web.dart'
    as helper;

import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Render complications data grid
class ComplicationDataGrid extends LocalizationSampleView {
  /// Creates getting started data grid
  const ComplicationDataGrid({Key? key}) : super(key: key);

  @override
  _ComplicationDataGridState createState() => _ComplicationDataGridState();
}

class _ComplicationDataGridState extends LocalizationSampleViewState {
  final GlobalKey<SfDataGridState> _key = GlobalKey<SfDataGridState>();

  /// DataGridSource required for SfDataGrid to obtain the row data.
  late ComplicationDataGridSource complicationDataGridSource;

  var currentUserRole = "";

  static const double dataPagerHeight = 60;
  int _rowsPerPage = 15;

  /// Selected locale
  late String selectedLocale;

  /// Translate names
  late String _name,
      _nameEn,
      _nameFr,
      _newComplication,
      _importCSV,
      _exportXLS,
      _exportPDF,
      _total,
      _editComplication,
      _removeComplication,
      _save,
      _cancel,
      _complications,
      _removedComplication;

  late Map<String, double> columnWidths = {
    'Complicación (ES)': 150,
    'Complicación (EN)': 150,
    'Complicación (FR)': 150,
  };

  /// Editing controller for forms to perform update the values.
  TextEditingController? nameController, nameEnController, nameFrController;

  /// Used to validate the forms
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

  _saveComplications(AsyncValue<List<Complication>>? complications) {
    if (complications == null) {
      complicationDataGridSource.setComplications(List.empty());
    } else {
      complicationDataGridSource.setComplications(complications.value);
    }
  }

  Widget _buildView(AsyncValue<List<Complication>> complications) {
    if (complications.value != null) {
      complicationDataGridSource.buildDataGridRows();
      complicationDataGridSource.updateDataSource();
      selectedLocale = model.locale.toString();
      return _buildLayoutBuilder();
    } else {
      return const Center(
          child: SizedBox(
        width: 200,
        height: 200,
        child: CircularProgressIndicator(),
      ));
    }
  }

  Widget _buildLayoutBuilder() {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraint) {
      if (complicationDataGridSource.getComplications()!.isEmpty) {
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
                          child: _buildDataGrid())),
                ),
              ],
            ),
            Container(
              height: dataPagerHeight,
              decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.surface.withOpacity(0.12),
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
      }
    });
  }

  void _importComplications() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final myUint8List = new Uint8List.fromList(result.files.single.bytes!);
      final blob = Blob([myUint8List], 'text/plain');
      readBlob(blob).then((it) {
        List<List<dynamic>> rowsAsListOfValues =
            const CsvToListConverter().convert(it);
        for (final row in rowsAsListOfValues) {
          if (row.isNotEmpty) {
            final complicationId = row[0].toString();
            try {
              final complicationToUpdate = complicationDataGridSource
                  .getComplications()!
                  .firstWhere(
                      (element) => element.complicationId == complicationId);
              ref
                  .read(complicationsScreenControllerProvider.notifier)
                  .updateComplication(Complication(
                    complicationId: complicationToUpdate.complicationId,
                    name: row[1].toString(),
                    nameEn: row[2].toString(),
                    nameFr: row[3].toString(),
                  ));
            } catch (e) {
              if (e is Error && e.toString().contains('No element')) {
                ref
                    .read(complicationsScreenControllerProvider.notifier)
                    .addComplication(Complication(
                      complicationId: "",
                      name: row[1].toString(),
                      nameEn: row[2].toString(),
                      nameFr: row[3].toString(),
                    ));
              } else {
                print("another error import");
              }
            }
          }
        }
      });
    } else {
      // Complication canceled the picker
    }
  }

  Future<String> readBlob(Blob blob) async {
    final reader = FileReader();
    reader.readAsText(blob);
    await reader.onLoad.first;
    return reader.result as String;
  }

  void _createComplication() {
    _createTextFieldContext();
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        scrollable: true,
        titleTextStyle: TextStyle(
            color: model.textColor, fontWeight: FontWeight.bold, fontSize: 16),
        title: Text(_newComplication),
        actions: _buildActionCreateButtons(context),
        content: Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Form(
              key: _formKey,
              child: _buildAlertDialogCreateContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderButtons() {
    Future<void> exportDataGridToExcel() async {
      final Workbook workbook = _key.currentState!.exportToExcelWorkbook(
          excludeColumns: ['Foto'],
          cellExport: (DataGridCellExcelExportDetails details) {});
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();
      await helper.FileSaveHelper.saveAndLaunchFile(
          bytes, '$_complications.xlsx');
    }

    Future<void> exportDataGridToPdf() async {
      final ByteData data = await rootBundle.load('images/nut_logo.jpg');
      final PdfDocument document = _key.currentState!.exportToPdfDocument(
          fitAllColumnsInOnePage: true,
          excludeColumns: ['Foto'],
          cellExport: (DataGridCellPdfExportDetails details) {},
          headerFooterExport: (DataGridPdfHeaderFooterExportDetails details) {
            final double width = details.pdfPage.getClientSize().width;
            final PdfPageTemplateElement header =
                PdfPageTemplateElement(Rect.fromLTWH(0, 0, width, 65));

            header.graphics.drawImage(
                PdfBitmap(data.buffer
                    .asUint8List(data.offsetInBytes, data.lengthInBytes)),
                Rect.fromLTWH(width - 148, 0, 148, 60));

            header.graphics.drawString(
              _complications,
              PdfStandardFont(PdfFontFamily.helvetica, 13,
                  style: PdfFontStyle.bold),
              bounds: const Rect.fromLTWH(0, 25, 200, 60),
            );

            details.pdfDocumentTemplate.top = header;
          });
      final List<int> bytes = document.saveSync();
      await helper.FileSaveHelper.saveAndLaunchFile(
          bytes, '$_complications.pdf');
      document.dispose();
    }

    if (currentUserRole == 'super-admin') {
      return Row(
        children: <Widget>[
          _buildPDFExportingButton(_exportPDF, onPressed: exportDataGridToPdf),
          _buildExcelExportingButton(_exportXLS,
              onPressed: exportDataGridToExcel),
          _buildImportButton(_importCSV),
          _buildCreatingButton(_newComplication),
        ],
      );
    } else {
      return Row(
        children: <Widget>[
          _buildPDFExportingButton(_exportPDF, onPressed: exportDataGridToPdf),
          _buildExcelExportingButton(_exportXLS,
              onPressed: exportDataGridToExcel),
        ],
      );
    }
  }

  Widget _buildImportButton(String buttonName) {
    return Container(
        height: 60.0,
        padding: const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0),
        child: IconButton(
          icon: const Icon(
            FontAwesomeIcons.fileCsv,
            color: Colors.blueAccent,
          ),
          onPressed: _importComplications,
        ));
  }

  Widget _buildCreatingButton(String buttonName) {
    return Container(
        height: 60.0,
        padding: const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0),
        child: IconButton(
          icon: const Icon(
            FontAwesomeIcons.plus,
            color: Colors.blueAccent,
          ),
          onPressed: _createComplication,
        ));
  }

  Widget _buildExcelExportingButton(String buttonName,
      {required VoidCallback onPressed}) {
    return Container(
        height: 60.0,
        padding: const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0),
        child: IconButton(
          icon:
              const Icon(FontAwesomeIcons.fileExcel, color: Colors.blueAccent),
          onPressed: onPressed,
        ));
  }

  Widget _buildPDFExportingButton(String buttonName,
      {required VoidCallback onPressed}) {
    return Container(
        height: 60.0,
        padding: const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0),
        child: IconButton(
          icon: const Icon(FontAwesomeIcons.filePdf, color: Colors.blueAccent),
          onPressed: onPressed,
        ));
  }

  Widget _buildDataPager() {
    var rows = complicationDataGridSource.rows;
    if (complicationDataGridSource.effectiveRows.isNotEmpty) {
      rows = complicationDataGridSource.effectiveRows;
    }
    var addMorePage = 0;
    if ((rows.length / _rowsPerPage).remainder(1) != 0) {
      addMorePage = 1;
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SfDataPager(
        delegate: complicationDataGridSource,
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
                columnName: 'Username',
                summaryType: GridSummaryType.count),
          ],
          position: GridTableSummaryRowPosition.bottom),
    ];
  }

  RegExp _getRegExp(TextInputType keyboardType, String columnName) {
    if (keyboardType == TextInputType.number) {
      return RegExp('[0-9]');
    } else if (keyboardType == TextInputType.text) {
      return RegExp('.');
    } else if (keyboardType == TextInputType.phone) {
      return RegExp(r"^[\d+]+$");
    } else if (keyboardType == TextInputType.emailAddress) {
      return RegExp(r"[a-zA-Z0-9@.]+");
    } else {
      return RegExp('.');
    }
  }

  /// Building the each field with label and TextFormField
  Widget _buildRow(
      {required TextEditingController controller,
      required String columnName,
      required String text}) {
    TextInputType keyboardType = TextInputType.text;
    if (<String>['Puntos'].contains(columnName)) {
      keyboardType = TextInputType.number;
    } else if (<String>['Email'].contains(columnName)) {
      keyboardType = TextInputType.emailAddress;
    } else if (<String>['Teléfono'].contains(columnName)) {
      keyboardType = TextInputType.phone;
    } else {
      keyboardType = TextInputType.text;
    }
    // Holds the regular expression pattern based on the column type.
    final RegExp regExp = _getRegExp(keyboardType, columnName);

    return Row(
      children: <Widget>[
        Container(
            width: 150,
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Text(text)),
        SizedBox(
          width: 150,
          child: TextFormField(
            validator: (String? value) {
              if (value!.isEmpty) {
                return 'El campo no puede estar vacío';
              }
              return null;
            },
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(regExp)
            ],
          ),
        )
      ],
    );
  }

  /// Building the forms to edit the data
  Widget _buildAlertDialogContent() {
    return Column(
      children: <Widget>[
        _buildRow(
            controller: nameController!,
            columnName: 'Complicación (ES)',
            text: _name),
        _buildRow(
            controller: nameEnController!,
            columnName: 'Complicación (EN)',
            text: _nameEn),
        _buildRow(
            controller: nameFrController!,
            columnName: 'Complicación (FR)',
            text: _nameFr),
      ],
    );
  }

  /// Building the forms to create the data
  Widget _buildAlertDialogCreateContent() {
    return Column(
      children: <Widget>[
        _buildRow(
            controller: nameController!,
            columnName: 'Complicación (ES)',
            text: _name),
        _buildRow(
            controller: nameEnController!,
            columnName: 'Complicación (EN)',
            text: _nameEn),
        _buildRow(
            controller: nameFrController!,
            columnName: 'Complicación (FR)',
            text: _nameFr),
      ],
    );
  }

  void _createTextFieldContext() {
    nameController!.text = '';
    nameEnController!.text = '';
    nameFrController!.text = '';
  }

  // Updating the data to the TextEditingController
  void _updateTextFieldContext(DataGridRow row) {
    final String? name = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'Complicación (ES)')
        ?.value
        .toString();
    nameController!.text = name ?? '';

    final String? nameEn = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'Complicación (EN)')
        ?.value
        .toString();
    nameEnController!.text = nameEn ?? '';

    final String? nameFr = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'Complicación (FR)')
        ?.value
        .toString();
    nameFrController!.text = nameFr ?? '';
  }

  /// Editing the DataGridRow
  void _handleEditWidgetTap(DataGridRow row) {
    _updateTextFieldContext(row);
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        scrollable: true,
        titleTextStyle: TextStyle(
            color: model.textColor, fontWeight: FontWeight.bold, fontSize: 16),
        title: Text(_editComplication),
        actions: _buildActionButtons(row, context),
        content: Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Form(
              key: _formKey,
              child: _buildAlertDialogContent(),
            ),
          ),
        ),
      ),
    );
  }

  void _processCellCreate(BuildContext buildContext) async {
    if (_formKey.currentState!.validate()) {
      ref
          .read(complicationsScreenControllerProvider.notifier)
          .addComplication(Complication(
            complicationId: "",
            name: nameController!.text,
            nameEn: nameEnController!.text,
            nameFr: nameFrController!.text,
          ));
      Navigator.pop(buildContext);
    }
  }

  /// Updating the DataGridRows after changing the value and notify the DataGrid
  /// to refresh the view
  void _processCellUpdate(DataGridRow row, BuildContext buildContext) {
    final String? id = complicationDataGridSource
        .getComplications()
        ?.firstWhere(
            (element) => element.complicationId == row.getCells()[0].value)
        .complicationId;
    if (_formKey.currentState!.validate()) {
      ref
          .read(complicationsScreenControllerProvider.notifier)
          .updateComplication(Complication(
            complicationId: id!,
            name: nameController!.text,
            nameEn: nameEnController!.text,
            nameFr: nameFrController!.text,
          ));
      Navigator.pop(buildContext);
    }
  }

  List<Widget> _buildActionCreateButtons(BuildContext buildContext) {
    return <Widget>[
      TextButton(
        onPressed: () => _processCellCreate(buildContext),
        child: Text(
          _save,
          style: TextStyle(color: model.backgroundColor),
        ),
      ),
      TextButton(
        onPressed: () => Navigator.pop(buildContext),
        child: Text(
          _cancel,
          style: TextStyle(color: model.backgroundColor),
        ),
      ),
    ];
  }

  /// Building the option button on the bottom of the alert popup
  List<Widget> _buildActionButtons(DataGridRow row, BuildContext buildContext) {
    return <Widget>[
      TextButton(
        onPressed: () => _processCellUpdate(row, buildContext),
        child: Text(
          _save,
          style: TextStyle(color: model.backgroundColor),
        ),
      ),
      TextButton(
        onPressed: () => Navigator.pop(buildContext),
        child: Text(
          _cancel,
          style: TextStyle(color: model.backgroundColor),
        ),
      ),
    ];
  }

  /// Deleting the DataGridRow
  void _handleDeleteWidgetTap(DataGridRow row) {
    final complication = complicationDataGridSource
        .getComplications()
        ?.firstWhere(
            (element) => element.complicationId == row.getCells()[0].value);
    if (complication != null) {
      ref
          .read(complicationsScreenControllerProvider.notifier)
          .deleteComplication(complication);
      _showDialogDeleteConfirmation();
    }
  }

  _showDialogDeleteConfirmation() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(color: model.backgroundColor),
            ),
          ),
        ],
        content: Text(_removedComplication),
      ),
    );
  }

  /// Callback for left swiping
  Widget _buildStartSwipeWidget(
      BuildContext context, DataGridRow row, int rowIndex) {
    return GestureDetector(
      onTap: () => _handleEditWidgetTap(row),
      child: Container(
        color: Colors.blueAccent,
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.edit, color: Colors.white, size: 16),
            SizedBox(width: 8.0),
            Text(
              _editComplication,
              style: TextStyle(color: Colors.white, fontSize: 12),
            )
          ],
        ),
      ),
    );
  }

  /// Callback for right swiping
  Widget _buildEndSwipeWidget(
      BuildContext context, DataGridRow row, int rowIndex) {
    return GestureDetector(
      onTap: () => _handleDeleteWidgetTap(row),
      child: Container(
        color: Colors.redAccent,
        padding: EdgeInsets.only(left: 8.0, right: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.delete, color: Colors.white, size: 16),
            const SizedBox(width: 8.0),
            Text(
              _removeComplication,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  SfDataGrid _buildDataGrid() {
    final selectedLocale = model.locale.toString();
    switch (selectedLocale) {
      case 'en_US':
        _name = 'Complication (SP)';
        _nameEn = 'Complication (EN)';
        _nameFr = 'Complication (FR)';
        _newComplication = 'Create Complication';
        _importCSV = 'Import CSV';
        _exportXLS = 'Export XLS';
        _exportPDF = 'Export PDF';
        _total = 'Total Complications';
        _editComplication = 'Edit';
        _removeComplication = 'Remove';
        _cancel = 'Cancel';
        _save = 'Save';
        _complications = 'Complications';
        _removedComplication = 'Complication deleted successfully.';
        break;
      case 'es_ES':
        _name = 'Complicación (ES)';
        _nameEn = 'Complicación (EN)';
        _nameFr = 'Complicación (FR)';
        _newComplication = 'Crear complicación';
        _importCSV = 'Importar CSV';
        _exportXLS = 'Exportar XLS';
        _exportPDF = 'Exportar PDF';
        _total = 'Complicaciones totales';
        _editComplication = 'Editar';
        _removeComplication = 'Eliminar';
        _cancel = 'Cancelar';
        _save = 'Guardar';
        _complications = 'Complicaciones';
        _removedComplication = 'Complicación eliminada correctamente';
        break;
      case 'fr_FR':
        _name = 'Complication (ES)';
        _nameEn = 'Complication (EN)';
        _nameFr = 'Complication (FR)';
        _newComplication = 'Créer complication';
        _importCSV = 'Importer CSV';
        _exportXLS = 'Exporter XLS';
        _exportPDF = 'Exporter PDF';
        _total = 'Total des complications';
        _editComplication = 'Modifier';
        _removeComplication = 'Supprimer';
        _cancel = 'Annuler';
        _save = 'Enregistrer';
        _complications = 'Complications';
        _removedComplication = 'Complication supprimé avec succès.';
        break;
    }
    return SfDataGrid(
      key: _key,
      source: complicationDataGridSource,
      rowsPerPage: _rowsPerPage,
      tableSummaryRows: _getTableSummaryRows(),
      allowSwiping: currentUserRole == 'super-admin' ? true : false,
      allowColumnsResizing: true,
      onColumnResizeUpdate: (ColumnResizeUpdateDetails details) {
        setState(() {
          columnWidths[details.column.columnName] = details.width;
        });
        return true;
      },
      swipeMaxOffset: 100.0,
      endSwipeActionsBuilder: _buildEndSwipeWidget,
      startSwipeActionsBuilder: _buildStartSwipeWidget,
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
            columnName: 'Complicación (ES)',
            width: columnWidths['Complicación (ES)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _name,
                overflow: TextOverflow.ellipsis,
              ),
            )),
        GridColumn(
            columnName: 'Complicación (EN)',
            width: columnWidths['Complicación (EN)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _nameEn,
                overflow: TextOverflow.ellipsis,
              ),
            )),
        GridColumn(
            columnName: 'Complicación (FR)',
            width: columnWidths['Complicación (FR)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _nameFr,
                overflow: TextOverflow.ellipsis,
              ),
            )),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    complicationDataGridSource = ComplicationDataGridSource(List.empty());
    nameController = TextEditingController();
    nameEnController = TextEditingController();
    nameFrController = TextEditingController();
    selectedLocale = model.locale.toString();

    _name = 'Complicación (ES)';
    _nameEn = 'Complicación (EN)';
    _nameFr = 'Complicación (FR)';
    _newComplication = 'Crear complicación';
    _importCSV = 'Importar CSV';
    _exportXLS = 'Exportar XLS';
    _exportPDF = 'Exportar PDF';
    _total = 'Complicaciones totales';
    _editComplication = 'Editar';
    _removeComplication = 'Eliminar';
    _cancel = 'Cancelar';
    _save = 'Guardar';
    _complications = 'Complicaciones';
    _removedComplication = '';
  }

  @override
  Widget buildSample(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      ref.listen<AsyncValue>(
        complicationsScreenControllerProvider,
        (_, state) => {},
      );
      final user = ref.watch(authRepositoryProvider).currentUser;
      if (user != null &&
          user.metadata != null &&
          user.metadata!.lastSignInTime != null) {
        final claims = user.getIdTokenResult();
        claims.then((value) => {
              if (value.claims != null &&
                  value.claims!['donante'] == true &&
                  currentUserRole != "donante")
                {
                  setState(() {
                    currentUserRole = 'donante';
                  }),
                }
              else if (value.claims != null &&
                  value.claims!['super-admin'] == true &&
                  currentUserRole != "super-admin")
                {
                  setState(() {
                    currentUserRole = 'super-admin';
                  }),
                }
            });
      }
      final complicationsAsyncValue = ref.watch(complicationsStreamProvider);
      if (complicationsAsyncValue.value != null) {
        _saveComplications(complicationsAsyncValue);
      }
      return _buildView(complicationsAsyncValue);
    });
  }
}
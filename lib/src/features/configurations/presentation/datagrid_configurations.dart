/// Package imports
/// import 'package:flutter/foundation.dart';


import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../data/firestore_repository.dart';
/// Local import
import '../domain/configuration.dart';
import 'configurations_screen_controller.dart';
import 'configuration_datagridsource.dart';

import 'package:file_picker/file_picker.dart';
import 'dart:html' show FileReader;

import '../../../common_widgets/export/save_file_mobile.dart'
if (dart.library.html) '../../../common_widgets/export/save_file_web.dart' as helper;

import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Render configuration data grid
class ConfigurationDataGrid extends LocalizationSampleView {
  /// Creates getting started data grid
  const ConfigurationDataGrid({Key? key}) : super(key: key);

  @override
  _ConfigurationDataGridState createState() => _ConfigurationDataGridState();
}

class _ConfigurationDataGridState extends LocalizationSampleViewState {

  final GlobalKey<SfDataGridState> _key = GlobalKey<SfDataGridState>();

  /// DataGridSource required for SfDataGrid to obtain the row data.
  late ConfigurationDataGridSource configurationDataGridSource;

  static const double dataPagerHeight = 60;
  int _rowsPerPage = 15;

  /// Selected locale
  late String selectedLocale;

  var currentUserRole = "";

  /// Translate names
  late String _id, _name, _money, _newConfiguration, _payByConfirmation, _payByDiagnosis,
      _pointByConfirmation, _pointsByDiagnosis, _monthlyPayment, _blockChainConfiguration,
      _hash, _importCSV, _exportXLS, _exportPDF, _total, _editConfiguration,
      _removeConfiguration, _save, _cancel, _configurations, _removedConfiguration;

  late Map<String, double> columnWidths = {
    'ID': 200,
    'Nombre': 200,
    'Moneda': 200,
    'Pago Confirmación': 200,
    'Pago Diagnóstico': 200,
    'Punto Confirmación': 200,
    'Punto Diagnóstico': 200,
    'Pago Mensual': 200,
    'Configuración Blockchain': 200,
    'Hash': 200,
  };

  /// Editing controller for forms to perform update the values.
  TextEditingController?
      idController,
      nameController,
      moneyController,
      payConfirmationController,
      payDiagnosisController,
      pointConfirmationController,
      pointDiagnosisController,
      payMonthlyController;

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

  _saveConfigurations(AsyncValue<List<Configuration>>? configurations) {
    if (configurations == null) {
      configurationDataGridSource.setConfigurations(List.empty());
    } else {
      configurationDataGridSource.setConfigurations(configurations.value);
    }
  }

  Widget _buildView(AsyncValue<List<Configuration>> configurations) {
    if (configurations.value != null && configurations.value!.isNotEmpty) {
      configurationDataGridSource.buildDataGridRows();
      configurationDataGridSource.updateDataSource();
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

  void _importCountries() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final myUint8List = Uint8List.fromList(result.files.single.bytes!);
      final blob = Blob([myUint8List], 'text/plain');
      readBlob(blob).then((it) {
        List<List<dynamic>> rowsAsListOfValues =
        const CsvToListConverter().convert(it);
        for (final row in rowsAsListOfValues) {
          if (row.isNotEmpty) {
            ref.read(configurationsScreenControllerProvider.notifier).addConfiguration(
                Configuration(
                  id: "",
                  name: row[0].toString(),
                  money: row[1].toString(),
                  payByConfirmation: row[2].toInt(),
                  payByDiagnosis: row[3].toInt(),
                  pointByConfirmation: row[4].toInt(),
                  pointsByDiagnosis: row[5].toInt(),
                  monthlyPayment: row[6].toInt(),
                  blockChainConfiguration: 0,
                  hash: "",
                )
            );
          }
        }
      });
    } else {
      // User canceled the picker
    }
  }

  Future<String> readBlob(Blob blob) async {
    final reader = FileReader();
    reader.readAsText(blob);
    await reader.onLoad.first;
    return reader.result as String;
  }

  void _createCountry() {
    _createTextFieldContext();
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        scrollable: true,
        titleTextStyle: TextStyle(
            color: model.textColor, fontWeight: FontWeight.bold, fontSize: 16),
        title: Text(_newConfiguration),
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
          cellExport: (DataGridCellExcelExportDetails details) {

          });
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();
      await helper.FileSaveHelper.saveAndLaunchFile(bytes, '$_configurations.xlsx');
    }

    Future<void> exportDataGridToPdf() async {
      final ByteData data = await rootBundle.load('images/nut_logo.jpg');
      final PdfDocument document = _key.currentState!.exportToPdfDocument(
          fitAllColumnsInOnePage: true,
          excludeColumns: ['ID'],
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
              _configurations,
              PdfStandardFont(PdfFontFamily.helvetica, 13,
                  style: PdfFontStyle.bold),
              bounds: const Rect.fromLTWH(0, 25, 200, 60),
            );

            details.pdfDocumentTemplate.top = header;
          });
      final List<int> bytes = document.saveSync();
      await helper.FileSaveHelper.saveAndLaunchFile(bytes, '$_configurations.pdf');
      document.dispose();
    }

    if (currentUserRole == 'super-admin') {
      return Row(
        children: <Widget>[
          _buildPDFExportingButton(_exportPDF, onPressed: exportDataGridToPdf),
          _buildExcelExportingButton(_exportXLS, onPressed: exportDataGridToExcel),
          _buildImportButton(_importCSV),
          _buildCreatingButton(_newConfiguration),
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

  Widget _buildImportButton(String buttonName) {
    return Container(
        height: 60.0,
        padding: const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0),
        child: IconButton(
          icon: const Icon(
            FontAwesomeIcons.fileCsv,
            color: Colors.blueAccent,
          ),
          onPressed: _importCountries,)
    );
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
          onPressed: _createCountry,)
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
    var rows = configurationDataGridSource.rows;
    if (configurationDataGridSource.effectiveRows.isNotEmpty ) {
      rows = configurationDataGridSource.effectiveRows;
    }
    var addMorePage = 0;
    if ((rows.length / _rowsPerPage).remainder(1) != 0) {
      addMorePage  = 1;
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SfDataPager(
        delegate: configurationDataGridSource,
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
      {required TextEditingController controller, required String columnName, required String text}) {
    TextInputType keyboardType = TextInputType.text;
    if (<String>['Pago Confirmación'].contains(columnName)) {
      keyboardType =  TextInputType.number;
    } else if (<String>['Pago Diagnóstico'].contains(columnName)) {
      keyboardType =  TextInputType.number;
    } else if (<String>['Punto Confirmación'].contains(columnName)) {
      keyboardType =  TextInputType.number;
    } else if (<String>['Punto Diagnóstico'].contains(columnName)) {
      keyboardType =  TextInputType.number;
    } else {
      keyboardType =  TextInputType.text;
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
        _buildRow(controller: nameController!, columnName: 'Nombre', text: _name),
        _buildRow(controller: moneyController!, columnName: 'Moneda', text: _money),
        _buildRow(controller: payConfirmationController!, columnName: 'Pago Confirmación', text: _payByConfirmation),
        _buildRow(controller: payDiagnosisController!, columnName: 'Pago Diagnóstico', text: _payByDiagnosis),
        _buildRow(controller: pointConfirmationController!, columnName: 'Punto Confirmación', text: _pointByConfirmation),
        _buildRow(controller: pointDiagnosisController!, columnName: 'Punto Diagnóstico', text: _pointsByDiagnosis),
        _buildRow(controller: payMonthlyController!, columnName: 'Pago Mensual', text: _monthlyPayment),
      ],
    );
  }

  /// Building the forms to create the data
  Widget _buildAlertDialogCreateContent() {
    return Column(
      children: <Widget>[
        _buildRow(controller: nameController!, columnName: 'Nombre', text: _name),
        _buildRow(controller: moneyController!, columnName: 'Moneda', text: _money),
        _buildRow(controller: payConfirmationController!, columnName: 'Pago Confirmación', text: _payByConfirmation),
        _buildRow(controller: payDiagnosisController!, columnName: 'Pago Diagnóstico', text: _payByDiagnosis),
        _buildRow(controller: pointConfirmationController!, columnName: 'Punto Confirmación', text: _pointByConfirmation),
        _buildRow(controller: pointDiagnosisController!, columnName: 'Punto Diagnóstico', text: _pointsByDiagnosis),
        _buildRow(controller: payMonthlyController!, columnName: 'Pago Mensual', text: _monthlyPayment),
      ],
    );
  }

  void _createTextFieldContext() {
    idController!.text = '';
    nameController!.text = '';
    moneyController!.text = '';
    payConfirmationController!.text = '';
    payDiagnosisController!.text = '';
    pointConfirmationController!.text = '';
    pointDiagnosisController!.text = '';
    payMonthlyController!.text = '';
  }

  // Updating the data to the TextEditingController
  void _updateTextFieldContext(DataGridRow row) {

    final String? id = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'ID')
        ?.value
        .toString();

    idController!.text = id ?? '';

    final String? name = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'Nombre')
        ?.value
        .toString();

    nameController!.text = name ?? '';

    final String? money = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'Moneda')
        ?.value
        .toString();

    moneyController!.text = money ?? '';


    final String? payConfirmation = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'Pago Confirmación')
        ?.value
        .toString();

    payConfirmationController!.text = payConfirmation ?? '';

    final String? payDiagnosis = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'Pago Diagnóstico')
        ?.value
        .toString();

    payDiagnosisController!.text = payDiagnosis ?? '';

    final String? pointConfirmation = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'Punto Confirmación')
        ?.value
        .toString();

    pointConfirmationController!.text = pointConfirmation ?? '';

    final String? pointDiagnosis = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'Punto Diagnóstico')
        ?.value
        .toString();

    pointDiagnosisController!.text = pointDiagnosis ?? '';

    final String? payMonthly = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'Pago Mensual')
        ?.value
        .toString();

    payMonthlyController!.text = payMonthly ?? '';

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
        title: Text(_editConfiguration),
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
      ref.read(configurationsScreenControllerProvider.notifier).addConfiguration(
          Configuration(
              id: "",
              name: nameController!.text,
              money: moneyController!.text,
              payByConfirmation: int.parse(payConfirmationController!.text),
              payByDiagnosis: int.parse(payDiagnosisController!.text),
              pointByConfirmation: int.parse(pointConfirmationController!.text),
              pointsByDiagnosis: int.parse(pointDiagnosisController!.text),
              monthlyPayment: int.parse(payMonthlyController!.text),
              blockChainConfiguration: 0,
              hash: "",
          )
      );
      Navigator.pop(buildContext);
    }
  }

  /// Updating the DataGridRows after changing the value and notify the DataGrid
  /// to refresh the view
  void _processCellUpdate(DataGridRow row, BuildContext buildContext) {
    final Configuration configuration = configurationDataGridSource.getConfigurations()!.firstWhere((element) => element.id == row.getCells()[0].value);
    if (_formKey.currentState!.validate()) {
      ref.read(configurationsScreenControllerProvider.notifier).updateConfiguration(
          Configuration(
              id: configuration.id,
              name: nameController!.text,
              money: moneyController!.text,
              payByConfirmation: int.parse(payConfirmationController!.text),
              payByDiagnosis: int.parse(payDiagnosisController!.text),
              pointByConfirmation: int.parse(pointConfirmationController!.text),
              pointsByDiagnosis: int.parse(pointDiagnosisController!.text),
              monthlyPayment: int.parse(payMonthlyController!.text),
              blockChainConfiguration: configuration.blockChainConfiguration,
              hash: configuration.hash,
          )
      );
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
    final configuration = configurationDataGridSource.getConfigurations()?.firstWhere((element) => element.id == row.getCells()[0].value);
    if (configuration != null) {
      ref.read(configurationsScreenControllerProvider.notifier).deleteConfiguration(configuration);
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
        content: Text(_removedConfiguration),
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
              _editConfiguration,
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
              _removeConfiguration,
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
        _id = 'ID';
        _name = 'Name';
        _money = 'Money';
        _payByConfirmation = 'Confirmation Pay';
        _payByDiagnosis = 'Diagnosis Pay';
        _pointByConfirmation = 'Confirmation Point';
        _pointsByDiagnosis = 'Diagnosis Point';
        _monthlyPayment = 'Montly Pay';
        _blockChainConfiguration = 'Blockchain Configuration';
        _hash = 'Hash';
        _newConfiguration = 'Create Configuration';
        _importCSV = 'Import CSV';
        _exportXLS = 'Export XLS';
        _exportPDF = 'Export PDF';
        _total = 'Total Configurations';
        _editConfiguration = 'Edit';
        _removeConfiguration= 'Remove';
        _cancel = 'Cancel';
        _save = 'Save';
        _configurations = 'Configurations';
        _removedConfiguration = 'Configuration deleted successfully.';
        break;
      case 'es_ES':
        _id = 'ID';
        _name = 'Nombre';
        _money = 'Moneda';
        _payByConfirmation = 'Pago Confirmación';
        _payByDiagnosis = 'Pago Diagnóstico';
        _pointByConfirmation = 'Punto Confirmación';
        _pointsByDiagnosis = 'Punto Diagnóstico';
        _monthlyPayment = 'Pago Mensual';
        _blockChainConfiguration = 'Configuración Blockchain';
        _hash = 'Hash';
        _newConfiguration = 'Crear Configuración';
        _importCSV = 'Importar CSV';
        _exportXLS = 'Exportar XLS';
        _exportPDF = 'Exportar PDF';
        _total = 'Configuraciones totales';
        _editConfiguration = 'Editar';
        _removeConfiguration = 'Eliminar';
        _cancel = 'Cancelar';
        _save = 'Guardar';
        _configurations = 'Configuraciones';
        _removedConfiguration = 'Configuración eliminada correctamente';
        break;
      case 'fr_FR':
        _id = 'ID';
        _name = 'Nom';
        _money = 'Monnaie';
        _payByConfirmation = 'Paiement de confirmation';
        _payByDiagnosis = 'Paiement de diagnostic';
        _pointByConfirmation = 'Point de confirmation';
        _pointsByDiagnosis = 'Point de diagnostic';
        _monthlyPayment = 'Paiement mensuel';
        _blockChainConfiguration = 'Configuration de la Blockchain';
        _hash = 'Hacher';
        _newConfiguration = 'Créer un configuration';
        _importCSV = 'Importer CSV';
        _exportXLS = 'Exporter XLS';
        _exportPDF = 'Exporter PDF';
        _total = 'Total des configurations';
        _editConfiguration = 'Modifier';
        _removeConfiguration = 'Supprimer';
        _cancel = 'Annuler';
        _save = 'Enregistrer';
        _configurations = 'Les configurations';
        _removedConfiguration= 'Configurations supprimé avec succès.';
        break;
    }
    return SfDataGrid(
      key: _key,
      source: configurationDataGridSource,
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
          columnName: 'Moneda',
          width: columnWidths['Moneda']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _money,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
          columnName: 'Pago Confirmación',
          width: columnWidths['Pago Confirmación']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _payByConfirmation,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
          columnName: 'Pago Diagnóstico',
          width: columnWidths['Pago Diagnóstico']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _payByDiagnosis,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
          columnName: 'Punto Confirmación',
          width: columnWidths['Punto Confirmación']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _pointByConfirmation,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
          columnName: 'Punto Diagnóstico',
          width: columnWidths['Punto Diagnóstico']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _pointsByDiagnosis,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
          columnName: 'Pago Mensual',
          width: columnWidths['Pago Mensual']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _monthlyPayment,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
          columnName: 'Configuración Blockchain',
          width: columnWidths['Configuración Blockchain']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _blockChainConfiguration,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
          columnName: 'Hash',
          width: columnWidths['Hash']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _hash,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
            columnName: 'ID',
            width: columnWidths['ID']!,
            visible: false,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _id,
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
    configurationDataGridSource = ConfigurationDataGridSource(List.empty());
    idController = TextEditingController();
    nameController = TextEditingController();
    moneyController = TextEditingController();
    payConfirmationController = TextEditingController();
    payDiagnosisController = TextEditingController();
    pointConfirmationController = TextEditingController();
    pointDiagnosisController = TextEditingController();
    payMonthlyController = TextEditingController();
    selectedLocale = model.locale.toString();

    _id = 'ID';
    _name = 'Nombre';
    _money = 'Moneda';
    _blockChainConfiguration = 'Configuración Blockchain';
    _hash = 'Hash';
    _newConfiguration = 'Crear Configuración';
    _importCSV = 'Importar CSV';
    _exportXLS = 'Exportar XLS';
    _exportPDF = 'Exportar PDF';
    _total = 'Países totales';
    _editConfiguration = 'Editar';
    _removeConfiguration = 'Eliminar';
    _cancel = 'Cancelar';
    _save = 'Guardar';
    _configurations = 'Configuraciones';
    _removedConfiguration = 'Configuración eliminada correctamente';
  }


  @override
  Widget buildSample(BuildContext context) {
    return Consumer(
        builder: (context, ref, child) {
          ref.listen<AsyncValue>(
            configurationsScreenControllerProvider,
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
          }
          final countriesAsyncValue = ref.watch(configurationsStreamProvider);
          if (countriesAsyncValue.value != null) {
            _saveConfigurations(countriesAsyncValue);
          }
          return _buildView(countriesAsyncValue);
        });
  }

}



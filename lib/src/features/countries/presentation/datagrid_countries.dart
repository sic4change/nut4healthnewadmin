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
import '../domain/country.dart';
import 'countries_screen_controller.dart';
import 'country_datagridsource.dart';

import 'package:file_picker/file_picker.dart';
import 'dart:html' show FileReader;

import '../../../common_widgets/export/save_file_mobile.dart'
if (dart.library.html) '../../../common_widgets/export/save_file_web.dart' as helper;

import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Render country data grid
class CountryDataGrid extends LocalizationSampleView {
  /// Creates getting started data grid
  const CountryDataGrid({Key? key}) : super(key: key);

  @override
  _CountryDataGridState createState() => _CountryDataGridState();
}

class _CountryDataGridState extends LocalizationSampleViewState {

  final GlobalKey<SfDataGridState> _key = GlobalKey<SfDataGridState>();

  /// DataGridSource required for SfDataGrid to obtain the row data.
  late CountryDataGridSource countryDataGridSource;

  static const double dataPagerHeight = 60;
  int _rowsPerPage = 15;

  /// Selected locale
  late String selectedLocale;

  var currentUserRole = "";

  /// Translate names
  late String _id, _name, _code, _active, _cases, _casesNormopeso, _casesModerada,
      _casesSevera, _newCountry, _importCSV, _exportXLS, _exportPDF, _total,
      _editCountry, _removeCountry, _save, _cancel, _countries, _removedCountry;

  late Map<String, double> columnWidths = {
    'Id': 150,
    'Nombre': 150,
    'Código': 150,
    'Activo': 150,
    'Casos': 150,
    'Casos Normopeso': 150,
    'Casos Moderada': 150,
    'Casos Severa': 150,
  };

  /// Editing controller for forms to perform update the values.
  TextEditingController?
      idController,
      nameController,
      codeController,
      activeController,
      casesController,
      casesNormopesoController,
      casesModeradaController,
      casesSeveraController;

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

  _saveCountries(AsyncValue<List<Country>>? countries) {
    if (countries == null) {
      countryDataGridSource.setCountries(List.empty());
    } else {
      countryDataGridSource.setCountries(countries.value);
    }
  }

  Widget _buildView(AsyncValue<List<Country>> countries) {
    if (countries.value != null && countries.value!.isNotEmpty) {
      countryDataGridSource.buildDataGridRows();
      countryDataGridSource.updateDataSource();
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
            ref.read(countriesScreenControllerProvider.notifier).addCountry(
                Country(
                  countryId: "",
                  name: row[0].toString(),
                  code: row[1].toString(),
                  active: row[2].toString() == 'true' ? true : false,
                  cases: int.parse(row[3].toString()),
                  casesnormopeso: int.parse(row[4].toString()),
                  casesmoderada: int.parse(row[5].toString()),
                  casessevera: int.parse(row[6].toString())
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
        title: Text(_newCountry),
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
      await helper.FileSaveHelper.saveAndLaunchFile(bytes, '$_countries.xlsx');
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
              _countries,
              PdfStandardFont(PdfFontFamily.helvetica, 13,
                  style: PdfFontStyle.bold),
              bounds: const Rect.fromLTWH(0, 25, 200, 60),
            );

            details.pdfDocumentTemplate.top = header;
          });
      final List<int> bytes = document.saveSync();
      await helper.FileSaveHelper.saveAndLaunchFile(bytes, '$_countries.pdf');
      document.dispose();
    }

    if (currentUserRole == 'super-admin') {
      return Row(
        children: <Widget>[
          _buildPDFExportingButton(_exportPDF, onPressed: exportDataGridToPdf),
          _buildExcelExportingButton(_exportXLS, onPressed: exportDataGridToExcel),
          _buildImportButton(_importCSV),
          _buildCreatingButton(_newCountry),
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
    var addMorePage = 0;
    if ((countryDataGridSource.rows.length / _rowsPerPage).remainder(1) != 0) {
      addMorePage  = 1;
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SfDataPager(
        delegate: countryDataGridSource,
        availableRowsPerPage: const <int>[15, 20, 25],
        pageCount: (countryDataGridSource.rows.length / _rowsPerPage) + addMorePage,
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

  Widget _buildRowComboSelection({required TextEditingController controller,
    required String columnName, required List<String> dropDownMenuItems,
    required String text}) {
    String value = controller.text;
    if (value.isEmpty) {
      value = dropDownMenuItems[0];
    }
    return Row(
      children: <Widget>[
        Container(
            width: 150,
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Text(text)),
        SizedBox(
          width: 150,
          child: DropdownButtonFormField<String>(
              value: value,
              autofocus: true,
              focusColor: Colors.transparent,
              icon: const Icon(Icons.arrow_drop_down_sharp),
              isExpanded: false,
              onChanged: (newValue) {
                setState(() {
                  value = newValue!;
                  controller.text = newValue!;
                });
              },
              items: dropDownMenuItems.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option.length > 12 ? option.substring(0, 12) + '...' : option),
                );
              }).toList()),
        ),
      ],
    );
  }

  /// Building the each field with label and TextFormField
  Widget _buildRow(
      {required TextEditingController controller, required String columnName, required String text}) {
    TextInputType keyboardType = TextInputType.text;
    if (<String>['Puntos'].contains(columnName)) {
      keyboardType =  TextInputType.number;
    } else if (<String>['Email'].contains(columnName)) {
      keyboardType =  TextInputType.emailAddress;
    } else if (<String>['Teléfono'].contains(columnName)) {
      keyboardType =  TextInputType.phone;
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
    final activeOptions = ["✔", "✘"];
    return Column(
      children: <Widget>[
        _buildRow(controller: nameController!, columnName: 'Nombre', text: _name),
        _buildRow(controller: codeController!, columnName: 'Código', text: _code),
        _buildRowComboSelection(controller: activeController!, columnName: 'Activo',
            dropDownMenuItems: activeOptions, text: _active),
      ],
    );
  }

  /// Building the forms to create the data
  Widget _buildAlertDialogCreateContent() {
    final activeOptions = ["✔", "✘"];
    return Column(
      children: <Widget>[
        _buildRow(controller: nameController!, columnName: 'Nombre', text: _name),
        _buildRow(controller: codeController!, columnName: 'Código', text: _code),
        _buildRowComboSelection(controller: activeController!, columnName: 'Activo',
            dropDownMenuItems: activeOptions, text: _active),
      ],
    );
  }

  void _createTextFieldContext() {
    idController!.text = '';
    nameController!.text = '';
    codeController!.text = '';
    activeController!.text = '';
  }

  // Updating the data to the TextEditingController
  void _updateTextFieldContext(DataGridRow row) {

    final String? id = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'Id')
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

    final String? code = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'Código')
        ?.value
        .toString();

    codeController!.text = code ?? '';


    final String? active = row
        .getCells()
        .firstWhere(
          (DataGridCell element) => element.columnName == 'Activo',
    )
        ?.value
        .toString();

    activeController!.text = active != "false" ? '✔' : '✘';

    final String? cases = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'Casos')
        ?.value
        .toString();

    casesController!.text = cases ?? '';

    final String? casesNormopeso = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'Casos Normopeso')
        ?.value
        .toString();

    casesNormopesoController!.text = casesNormopeso ?? '';

    final String? casesModerada = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'Casos Moderada')
        ?.value
        .toString();

    casesModeradaController!.text = casesModerada ?? '';

    final String? casesSevera = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'Casos Severa')
        ?.value
        .toString();

    casesSeveraController!.text = casesSevera ?? '';

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
        title: Text(_editCountry),
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
      ref.read(countriesScreenControllerProvider.notifier).addCountry(
          Country(
              countryId: "",
              name: nameController!.text,
              code: codeController!.text,
              active: activeController!.text == '✔' ? true : false,
              cases: 0,
              casesnormopeso: 0,
              casesmoderada: 0,
              casessevera: 0
          )
      );
      Navigator.pop(buildContext);
    }
  }

  /// Updating the DataGridRows after changing the value and notify the DataGrid
  /// to refresh the view
  void _processCellUpdate(DataGridRow row, BuildContext buildContext) {
    final String? id = countryDataGridSource.getCountries()?.firstWhere((element) => element.countryId == row.getCells()[0].value).countryId;
    if (_formKey.currentState!.validate()) {
      ref.read(countriesScreenControllerProvider.notifier).updateCountry(
          Country(countryId: id!,
              name: nameController!.text,
              code: codeController!.text,
              active: activeController!.text == '✔' ? true : false,
              cases: int.parse(casesController!.text),
              casesnormopeso: int.parse(casesNormopesoController!.text),
              casesmoderada: int.parse(casesModeradaController!.text),
              casessevera: int.parse(casesSeveraController!.text)
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
    final country = countryDataGridSource.getCountries()?.firstWhere((element) => element.countryId == row.getCells()[0].value);
    if (country != null) {
      ref.read(countriesScreenControllerProvider.notifier).deleteCountry(country);
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
        content: Text(_removedCountry),
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
              _editCountry,
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
              _removeCountry,
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
        _id = 'Id';
        _name = 'Name';
        _code = 'Code';
        _active = 'Active';
        _cases = 'Cases';
        _casesNormopeso = 'Normal weight cases';
        _casesModerada = 'Moderate cases';
        _casesSevera = 'Severe cases';
        _importCSV = 'Import CSV';
        _exportXLS = 'Export XLS';
        _exportPDF = 'Export PDF';
        _total = 'Total Countries';
        _editCountry = 'Edit';
        _removeCountry = 'Remove';
        _cancel = 'Cancel';
        _save = 'Save';
        _countries = 'Countries';
        _removedCountry = 'Country deleted successfully.';
        break;
      case 'es_ES':
        _id = 'Id';
        _name = 'Nombre';
        _code = 'Código';
        _active = 'Activo';
        _cases = 'Casos';
        _casesNormopeso = 'Casos Normopeso';
        _casesModerada = 'Casos Moderada';
        _casesSevera = 'Casos Severa';
        _newCountry = 'Crear País';
        _importCSV = 'Importar CSV';
        _exportXLS = 'Exportar XLS';
        _exportPDF = 'Exportar PDF';
        _total = 'Países totales';
        _editCountry = 'Editar';
        _removeCountry = 'Eliminar';
        _cancel = 'Cancelar';
        _save = 'Guardar';
        _countries = 'Países';
        _removedCountry = 'País eliminado correctamente';
        break;
      case 'fr_FR':
        _id = 'Id';
        _name = 'Nom';
        _code = 'Code';
        _active = 'Actif';
        _cases = 'Cas';
        _casesNormopeso = 'Cas poids normal';
        _casesModerada = 'Cas modérés';
        _casesSevera = 'Cas sévères';
        _newCountry = 'Créer un pays';
        _importCSV = 'Importer CSV';
        _exportXLS = 'Exporter XLS';
        _exportPDF = 'Exporter PDF';
        _total = 'Total des pays';
        _editCountry = 'Modifier';
        _removeCountry = 'Supprimer';
        _cancel = 'Annuler';
        _save = 'Enregistrer';
        _countries = 'Les pays';
        _removedCountry = 'Pays supprimé avec succès.';
        break;
    }
    return SfDataGrid(
      key: _key,
      source: countryDataGridSource,
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
      allowSorting: true,
      allowMultiColumnSorting: true,
      columns: <GridColumn>[
        GridColumn(
            columnName: 'Id',
            visible: false,
            width: columnWidths['Id']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _id,
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
          columnName: 'Código',
          width: columnWidths['Código']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _code,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
          columnName: 'Activo',
          width: columnWidths['Activo']!,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(
                _active,
                overflow: TextOverflow.ellipsis,
              )),
        ),
        GridColumn(
          columnName: 'Casos',
          width: columnWidths['Casos']!,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(
                _cases,
                overflow: TextOverflow.ellipsis,
              )),
        ),
        GridColumn(
          columnName: 'Casos Normopeso',
          width: columnWidths['Casos Normopeso']!,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(
                _casesNormopeso,
                overflow: TextOverflow.ellipsis,
              )),
        ),
        GridColumn(
          columnName: 'Casos Moderada',
          width: columnWidths['Casos Moderada']!,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(
                _casesModerada,
                overflow: TextOverflow.ellipsis,
              )),
        ),
        GridColumn(
          columnName: 'Casos Severa',
          width: columnWidths['Casos Severa']!,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(
                _casesSevera,
                overflow: TextOverflow.ellipsis,
              )),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    countryDataGridSource = CountryDataGridSource(List.empty());
    idController = TextEditingController();
    nameController = TextEditingController();
    codeController = TextEditingController();
    activeController = TextEditingController();
    casesController = TextEditingController();
    casesNormopesoController = TextEditingController();
    casesModeradaController = TextEditingController();
    casesSeveraController = TextEditingController();
    selectedLocale = model.locale.toString();

    _id = 'Id';
    _name = 'Nombre';
    _code = 'Código';
    _active = 'Activo';
    _cases = 'Casos';
    _casesNormopeso = 'Casos Normopeso';
    _casesModerada = 'Casos Moderada';
    _casesSevera = 'Casos Severa';
    _newCountry = 'Crear País';
    _importCSV = 'Importar CSV';
    _exportXLS = 'Exportar XLS';
    _exportPDF = 'Exportar PDF';
    _total = 'Usuarios totales';
    _editCountry = 'Editar';
    _removeCountry = 'Eliminar';
    _cancel = 'Cancelar';
    _save = 'Guardar';
    _countries = 'Países';
    _removedCountry = '';
  }


  @override
  Widget buildSample(BuildContext context) {
    return Consumer(
        builder: (context, ref, child) {
          ref.listen<AsyncValue>(
            countriesScreenControllerProvider,
                (_, state) => {
            },
          );
          final user = ref.watch(authRepositoryProvider).currentUser;
          if (user != null && user.metadata != null && user.metadata!.lastSignInTime != null) {
            final claims = user.getIdTokenResult();
            claims.then((value) => {
              if (value.claims != null && value.claims!['donante'] == true) {
                currentUserRole = 'donante',
              } else if (value.claims != null && value.claims!['super-admin'] == true) {
                currentUserRole = 'super-admin',
              }
            });
          }
          final countriesAsyncValue = ref.watch(countriesStreamProvider);
          if (countriesAsyncValue.value != null) {
            _saveCountries(countriesAsyncValue);
          }
          return _buildView(countriesAsyncValue);
        });
  }

}



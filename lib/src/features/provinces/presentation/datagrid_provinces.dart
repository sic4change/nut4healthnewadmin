/// Package imports
/// import 'package:flutter/foundation.dart';


import 'package:adminnut4health/src/features/provinces/domain/province.dart';
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
import '../../countries/domain/country.dart';
import '../data/firestore_repository.dart';
import '../domain/ProvinceWithCountry.dart';
/// Local import
import 'provinces_screen_controller.dart';
import 'province_datagridsource.dart';

import 'package:file_picker/file_picker.dart';
import 'dart:html' show FileReader;

import '../../../common_widgets/export/save_file_mobile.dart'
if (dart.library.html) '../../../common_widgets/export/save_file_web.dart' as helper;

import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Render province data grid
class ProvinceDataGrid extends LocalizationSampleView {
  /// Creates getting started data grid
  const ProvinceDataGrid({Key? key}) : super(key: key);

  @override
  _ProvinceDataGridState createState() => _ProvinceDataGridState();
}

class _ProvinceDataGridState extends LocalizationSampleViewState {

  final GlobalKey<SfDataGridState> _key = GlobalKey<SfDataGridState>();

  /// DataGridSource required for SfDataGrid to obtain the row data.
  late ProvinceDataGridSource provinceDataGridSource;

  static const double dataPagerHeight = 60;
  int _rowsPerPage = 15;

  /// Selected locale
  late String selectedLocale;

  /// Translate names
  late String _id, _name, _country, _active,  _newProvince, _importCSV, _exportXLS,
      _exportPDF, _total, _editProvince, _removeProvince, _save, _cancel,
      _provinces, _removedProvince;

  late Map<String, double> columnWidths = {
    'Id': 150,
    'Nombre': 150,
    'País': 150,
    'Activo': 150,
  };

  /// Editing controller for forms to perform update the values.
  TextEditingController?
      idController,
      nameController,
      countryController,
      activeController;

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
      provinceDataGridSource.setCountries(List.empty());
    } else {
      provinceDataGridSource.setCountries(countries.value!);
    }
  }

  _saveProvinces(AsyncValue<List<ProvinceWithCountry>>? provinces) {
    if (provinces == null) {
      provinceDataGridSource.setProvinces(List.empty());
    } else {
      provinceDataGridSource.setProvinces(provinces.value);
    }
  }

  Widget _buildView(AsyncValue<List<ProvinceWithCountry>> provinces) {
    if (provinces.value != null && provinces.value!.isNotEmpty) {
      provinceDataGridSource.buildDataGridRows();
      provinceDataGridSource.updateDataSource();
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

  void _importProvinces() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final myUint8List = Uint8List.fromList(result.files.single.bytes!);
      final blob = Blob([myUint8List], 'text/plain');
      readBlob(blob).then((it) {
        List<List<dynamic>> rowsAsListOfValues =
        const CsvToListConverter().convert(it);
        for (final row in rowsAsListOfValues) {
          if (row.isNotEmpty) {
            ref.read(provincesScreenControllerProvider.notifier).addProvince(
                Province(
                  provinceId: "",
                  name: row[0].toString(),
                  country: provinceDataGridSource
                      .getCountries()
                      .firstWhere(
                          (element) => element.name == row[1].toString())
                      .countryId,
                  active: row[2].toString() == 'true' ? true : false,
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

  void _createProvince() {
    _createTextFieldContext();
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        scrollable: true,
        titleTextStyle: TextStyle(
            color: model.textColor, fontWeight: FontWeight.bold, fontSize: 16),
        title: Text(_newProvince),
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
      await helper.FileSaveHelper.saveAndLaunchFile(bytes, '$_provinces..xlsx');
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
              _provinces,
              PdfStandardFont(PdfFontFamily.helvetica, 13,
                  style: PdfFontStyle.bold),
              bounds: const Rect.fromLTWH(0, 25, 200, 60),
            );

            details.pdfDocumentTemplate.top = header;
          });
      final List<int> bytes = document.saveSync();
      await helper.FileSaveHelper.saveAndLaunchFile(bytes, '$_provinces.pdf');
      document.dispose();
    }

    return Row(
      children: <Widget>[
        _buildPDFExportingButton(_exportPDF, onPressed: exportDataGridToPdf),
        _buildExcelExportingButton(_exportXLS, onPressed: exportDataGridToExcel),
        _buildImportButton(_importCSV),
        _buildCreatingButton(_newProvince),
      ],
    );
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
          onPressed: _importProvinces,)
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
          onPressed: _createProvince,)
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
    if ((provinceDataGridSource.rows.length / _rowsPerPage).remainder(1) != 0) {
      addMorePage  = 1;
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SfDataPager(
        delegate: provinceDataGridSource,
        availableRowsPerPage: const <int>[15, 20, 25],
        pageCount: (provinceDataGridSource.rows.length / _rowsPerPage) + addMorePage,
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
        _buildRow(controller: countryController!, columnName: 'País', text: _country),
        _buildRowComboSelection(controller: activeController!, columnName: 'Activo',
            dropDownMenuItems: activeOptions, text: _active),
      ],
    );
  }

  /// Building the forms to create the data
  Widget _buildAlertDialogCreateContent() {
    final activeOptions = ["✔", "✘"];
    final countryOptions = provinceDataGridSource.getCountries().map((e) => e.name).toList();
    countryOptions.insert(0, "");
    return Column(
      children: <Widget>[
        _buildRow(controller: nameController!, columnName: 'Nombre', text: _name),
        _buildRowComboSelection(controller: countryController!, columnName: 'País',
            dropDownMenuItems: countryOptions, text: _country),
        _buildRowComboSelection(controller: activeController!, columnName: 'Activo',
            dropDownMenuItems: activeOptions, text: _active),
      ],
    );
  }

  void _createTextFieldContext() {
    idController!.text = '';
    nameController!.text = '';
    countryController!.text = '';
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
            (DataGridCell element) => element.columnName == 'País')
        ?.value
        .toString();

    countryController!.text = code ?? '';


    final String? active = row
        .getCells()
        .firstWhere(
          (DataGridCell element) => element.columnName == 'Activo',
    )
        ?.value
        .toString();

    activeController!.text = active != "false" ? '✔' : '✘';

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
        title: Text(_editProvince),
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
      ref.read(provincesScreenControllerProvider.notifier).addProvince(
          Province(
              provinceId: "",
              name: nameController!.text,
              country: provinceDataGridSource.getCountries().firstWhere((element) => element.name == countryController!.text).countryId,
              active: activeController!.text == '✔' ? true : false)
      );
      Navigator.pop(buildContext);
    }
  }

  /// Updating the DataGridRows after changing the value and notify the DataGrid
  /// to refresh the view
  void _processCellUpdate(DataGridRow row, BuildContext buildContext) {
    final String? id = provinceDataGridSource.getProvinces()?.firstWhere((element) => element.province.provinceId == row.getCells()[0].value).province.provinceId;
    if (_formKey.currentState!.validate()) {
      ref.read(provincesScreenControllerProvider.notifier).updateProvince(
          Province(provinceId: id!,
              name: nameController!.text,
              country: provinceDataGridSource.getCountries().firstWhere((element) => element.name == countryController!.text).countryId,
              active: activeController!.text == '✔' ? true : false
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
    final province = provinceDataGridSource.getProvinces()?.
      firstWhere((element) => element.province.provinceId == row.getCells()[0].value).province;
    if (province != null) {
      ref.read(provincesScreenControllerProvider.notifier).deleteProvince(province);
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
        content: Text(_removedProvince),
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
              _editProvince,
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
              _removeProvince,
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
        _country = 'Country';
        _active = 'Active';
        _newProvince = 'New Municipality';
        _importCSV = 'Import CSV';
        _exportXLS = 'Export XLS';
        _exportPDF = 'Export PDF';
        _total = 'Total Municipalities';
        _editProvince = 'Edit';
        _removeProvince = 'Remove';
        _cancel = 'Cancel';
        _save = 'Save';
        _provinces = 'Municipalities';
        _removedProvince = 'Municipality deleted successfully.';
        break;
      case 'es_ES':
        _id = 'Id';
        _name = 'Nombre';
        _country = 'País';
        _active = 'Activo';
        _newProvince = 'Crear Municipio';
        _importCSV = 'Importar CSV';
        _exportXLS = 'Exportar XLS';
        _exportPDF = 'Exportar PDF';
        _total = 'Municipios totales';
        _editProvince = 'Editar';
        _removeProvince = 'Eliminar';
        _cancel = 'Cancelar';
        _save = 'Guardar';
        _provinces = 'Municipios';
        _removedProvince = 'Municipio eliminado correctamente';
        break;
      case 'fr_FR':
        _id = 'Id';
        _name = 'Nom';
        _country = 'Code';
        _active = 'Actif';
        _newProvince = 'Créer un Municipalité';
        _importCSV = 'Importer CSV';
        _exportXLS = 'Exporter XLS';
        _exportPDF = 'Exporter PDF';
        _total = 'Total des municipalités';
        _editProvince = 'Modifier';
        _removeProvince = 'Supprimer';
        _cancel = 'Annuler';
        _save = 'Enregistrer';
        _provinces = 'Les municipalités';
        _removedProvince = 'Municipalité supprimé avec succès.';
        break;
    }
    return SfDataGrid(
      key: _key,
      source: provinceDataGridSource,
      rowsPerPage: _rowsPerPage,
      tableSummaryRows: _getTableSummaryRows(),
      allowSwiping: true,
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
          columnName: 'País',
          width: columnWidths['País']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _country,
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
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    provinceDataGridSource = ProvinceDataGridSource(List.empty(), List.empty());
    idController = TextEditingController();
    nameController = TextEditingController();
    countryController = TextEditingController();
    activeController = TextEditingController();
    selectedLocale = model.locale.toString();

    _id = 'Id';
    _name = 'Nombre';
    _country = 'País';
    _active = 'Activo';
    _newProvince = 'Crear Municipio';
    _importCSV = 'Importar CSV';
    _exportXLS = 'Exportar XLS';
    _exportPDF = 'Exportar PDF';
    _total = 'Usuarios totales';
    _editProvince = 'Editar';
    _removeProvince = 'Eliminar';
    _cancel = 'Cancelar';
    _save = 'Guardar';
    _provinces = 'Provincias';
    _removedProvince = '';
  }


  @override
  Widget buildSample(BuildContext context) {
    return Consumer(
        builder: (context, ref, child) {
          ref.listen<AsyncValue>(
            provincesScreenControllerProvider,
                (_, state) => {
            },
          );
          final countriesAsyncValue = ref.watch(countriesStreamProvider);
          final provinciesAsyncValue = ref.watch(provincesStreamProvider);
          if (countriesAsyncValue.value != null) {
            _saveCountries(countriesAsyncValue);
          }
          if (provinciesAsyncValue.value != null) {
            _saveProvinces(provinciesAsyncValue);
          }
          return _buildView(provinciesAsyncValue);
        });
  }

}


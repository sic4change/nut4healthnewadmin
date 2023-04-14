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
import '../../authentication/data/firebase_auth_repository.dart';
import '../../countries/domain/country.dart';
import '../data/firestore_repository.dart';
import '../domain/point.dart';

/// Local import
import 'points_screen_controller.dart';
import 'point_datagridsource.dart';
import '../domain/pointWithProvinceAndCountry.dart';

import 'package:file_picker/file_picker.dart';
import 'dart:html' show FileReader;

import '../../../common_widgets/export/save_file_mobile.dart'
    if (dart.library.html) '../../../common_widgets/export/save_file_web.dart'
    as helper;

import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;

import 'package:font_awesome_flutter/font_awesome_flutter.dart';


/// Render point data grid
class PointDataGrid extends LocalizationSampleView {
  /// Creates getting started data grid
  const PointDataGrid({Key? key}) : super(key: key);

  @override
  _PointDataGridState createState() => _PointDataGridState();
}

class _PointDataGridState extends LocalizationSampleViewState {

  final GlobalKey<SfDataGridState> _key = GlobalKey<SfDataGridState>();

  /// DataGridSource required for SfDataGrid to obtain the row data.
  late PointDataGridSource pointDataGridSource;

  static const double dataPagerHeight = 60;
  int _rowsPerPage = 15;

  /// Selected locale
  late String selectedLocale;

  var currentUserRole = "";

  /// Translate names
  late String _id,
      _name,
      _code,
      _country,
      _province,
      _active,
      _latitude,
      _longitude,
      _cases,
      _casesnormopeso,
      _casesmoderada,
      _casessevera,
      _newPoint,
      _importCSV,
      _exportXLS,
      _exportPDF,
      _total,
      _editPoint,
      _removePoint,
      _save,
      _cancel,
      _points,
      _removedPoint;

  late Map<String, double> columnWidths = {
    'Id': 150,
    'Nombre': 150,
    'Código': 150,
    'País': 150,
    'Municipio': 150,
    'Activo': 150,
    'Latitud': 200,
    'Longitud': 200,
    'Casos': 150,
    'Casos Normopeso': 150,
    'Casos Moderada': 150,
    'Casos Severa': 150,
  };

  /// Editing controller for forms to perform update the values.
  TextEditingController? idController,
      nameController,
      codeController,
      activeController,
      latitudeController,
      longitudeController,
      casesController,
      casesnormopesoController,
      casesmoderadaController,
      casesseveraController;


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
      pointDataGridSource.setCountries(List.empty());
    } else {
      pointDataGridSource.setCountries(countries.value!);
    }
  }

  _saveProvinces(AsyncValue<List<Province>>? provinces) {
    if (provinces == null) {
      pointDataGridSource.setProvinces(List.empty());
    } else {
      pointDataGridSource.setProvinces(provinces.value!);
    }
  }

  _savePoints(AsyncValue<List<PointWithProvinceAndCountry>>? points) {
    if (points == null) {
      pointDataGridSource.setPoints(List.empty());
    } else {
      pointDataGridSource.setPoints(points.value);
    }
  }

  Widget _buildView(AsyncValue<List<PointWithProvinceAndCountry>> points) {
    if (points.value != null && points.value!.isNotEmpty) {
      pointDataGridSource.buildDataGridRows();
      pointDataGridSource.updateDataSource();
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

  void _importPoints() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final myUint8List = Uint8List.fromList(result.files.single.bytes!);
      final blob = Blob([myUint8List], 'text/plain');
      readBlob(blob).then((it) {
        List<List<dynamic>> rowsAsListOfValues =
            const CsvToListConverter().convert(it);
        for (final row in rowsAsListOfValues) {
          if (row.isNotEmpty) {
            ref.read(pointsScreenControllerProvider.notifier).addPoint(Point(
                  pointId: "",
                  name: row[0].toString(),
                  fullName: "",
                  phoneCode: row[1].toString(),
                  province: pointDataGridSource
                      .getProvinces()!
                      .firstWhere(
                          (element) => element.name == row[2].toString())
                      .provinceId,
                  country: pointDataGridSource
                      .getCountries()!
                      .firstWhere(
                          (element) => element.name == row[3].toString())
                      .countryId,
                  active: row[4].toString() == 'true' ? true : false,
                  latitude: row[5] as double,
                  longitude: row[6] as double,
                  cases: row[7] as int,
                  casesnormopeso: row[8] as int,
                  casesmoderada: row[9] as int,
                  casessevera: row[10] as int,
                ));
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

  void _createPoint({bool resetFields = true}) {
    if (resetFields) {
      _createTextFieldContext();
    }
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        scrollable: true,
        titleTextStyle: TextStyle(
            color: model.textColor, fontWeight: FontWeight.bold, fontSize: 16),
        title: Text(_newPoint),
        actions: _buildActionCreateButtons(context),
        content: Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Form(
              key: _formKey,
              child: _buildAlertDialogCreateContent(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderButtons() {
    Future<void> exportDataGridToExcel() async {
      final Workbook workbook = _key.currentState!.exportToExcelWorkbook(
          cellExport: (DataGridCellExcelExportDetails details) {});
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();
      await helper.FileSaveHelper.saveAndLaunchFile(bytes, '$_points.xlsx');
    }

    Future<void> exportDataGridToPdf() async {
      final ByteData data = await rootBundle.load('images/nut_logo.jpg');
      final PdfDocument document = _key.currentState!.exportToPdfDocument(
          fitAllColumnsInOnePage: true,
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
              _points,
              PdfStandardFont(PdfFontFamily.helvetica, 13,
                  style: PdfFontStyle.bold),
              bounds: const Rect.fromLTWH(0, 25, 200, 60),
            );

            details.pdfDocumentTemplate.top = header;
          });
      final List<int> bytes = document.saveSync();
      await helper.FileSaveHelper.saveAndLaunchFile(bytes, '$_points.pdf');
      document.dispose();
    }

    if (currentUserRole == 'super-admin') {
      return Row(
        children: <Widget>[
          _buildPDFExportingButton(_exportPDF, onPressed: exportDataGridToPdf),
          _buildExcelExportingButton(_exportXLS, onPressed: exportDataGridToExcel),
          _buildImportButton(_importCSV),
          _buildCreatingButton(_newPoint),
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
          onPressed: _importPoints,
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
          onPressed: _createPoint,
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
    var rows = pointDataGridSource.rows;
    if (pointDataGridSource.effectiveRows.isNotEmpty ) {
      rows = pointDataGridSource.effectiveRows;
    }
    var addMorePage = 0;
    if ((rows.length / _rowsPerPage).remainder(1) != 0) {
      addMorePage = 1;
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SfDataPager(
        delegate: pointDataGridSource,
        availableRowsPerPage: const <int>[15, 20, 25],
        pageCount:
            (rows.length / _rowsPerPage) + addMorePage,
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
    } else if (keyboardType == const TextInputType.numberWithOptions(decimal: true, signed: true)) {
      return RegExp(r'(^\-?\d*\.?\d*)');
    } else {
      return RegExp('.');
    }
  }

  Widget _buildRowComboSelection(
      {required BuildContext context,
        required String optionSelected,
      required String columnName,
      required List<String> dropDownMenuItems,
      required String text}) {
    String value = optionSelected;
    if (optionSelected.isEmpty) {
      if (dropDownMenuItems.isNotEmpty) {
        value = dropDownMenuItems[0];
      } else {
        value = "";
      }
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
                  optionSelected = newValue!;
                  if (columnName == 'País') {
                    Country countrySelected = pointDataGridSource.getCountries()!.firstWhere((element) => element.name == newValue);
                    ref.watch(pointsScreenControllerProvider.notifier).setCountrySelected(countrySelected);
                    ref.watch(pointsScreenControllerProvider.notifier).
                      setProvinceOptions(pointDataGridSource.getProvinces().where((element) => element.country == countrySelected.countryId).toList());
                    try {
                      ref.watch(pointsScreenControllerProvider.notifier).
                        setProvinceSelected(ref.watch(pointsScreenControllerProvider.notifier).getProvinceOptions()[0]);
                    } catch(e) {
                      ref.watch(pointsScreenControllerProvider.notifier).
                      setProvinceSelected(const Province(provinceId: '', country: "", name: "", active: false));
                    }
                    Navigator.pop(context);
                    _createPoint(resetFields: false);
                  } else if (columnName == 'Municipio') {
                    Province provinceSelected = pointDataGridSource.getProvinces()!.firstWhere((element) => element.name == newValue);
                    ref.watch(pointsScreenControllerProvider.notifier).setProvinceSelected(provinceSelected);
                  } else {
                    activeController!.text = value;
                  }

                });
              },
              items: dropDownMenuItems.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option.length > 12
                      ? option.substring(0, 12) + '...'
                      : option),
                );
              }).toList()),
        ),
      ],
    );
  }

  /// Building the each field with label and TextFormField
  Widget _buildRow(
      {required TextEditingController controller,
      required String columnName,
      required String text}) {
    TextInputType keyboardType = TextInputType.text;
    if (<String>['Latitud'].contains(columnName)) {
      keyboardType =  const TextInputType.numberWithOptions(decimal: true, signed: true);
    } else if (<String>['Longitud'].contains(columnName)) {
      keyboardType =  const TextInputType.numberWithOptions(decimal: true, signed: true);
    } else if (<String>['Código'].contains(columnName)) {
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
  Widget _buildAlertDialogContent(BuildContext context) {
    final activeOptions = ["✔", "✘"];
    return Column(
      children: <Widget>[
        _buildRow(controller: nameController!, columnName: 'Nombre', text: _name),
        _buildRow(controller: codeController!, columnName: 'Código', text: _code),
        _buildRowComboSelection(
            context: context,
            optionSelected: ref.watch(pointsScreenControllerProvider.notifier).getCountrySelected().name,
            columnName: 'País',
            dropDownMenuItems: pointDataGridSource.getCountries()!.map((e) => e.name).toList(),
            text: _country),
        const SizedBox(height: 20),
        _buildRowComboSelection(
            context: context,
            optionSelected: ref.watch(pointsScreenControllerProvider.notifier).getProvinceSelected().name,
            columnName: 'Municipio',
            dropDownMenuItems: ref.watch(pointsScreenControllerProvider.notifier)
                .getProvinceOptions().map((e) => e.name).toList(),
            text: _province),
        _buildRowComboSelection(
            context: context,
            optionSelected: activeController!.text,
            columnName: 'Activo',
            dropDownMenuItems: activeOptions,
            text: _active),
        _buildRow(controller: latitudeController!, columnName: 'Latitud', text: _latitude),
        _buildRow(controller: longitudeController!, columnName: 'Longitud', text: _longitude),
      ],
    );
  }

  /// Building the forms to create the data
  Widget _buildAlertDialogCreateContent(BuildContext context) {
    final activeOptions = ["✔", "✘"];

    return Column(
      children: <Widget>[
        _buildRow(controller: nameController!, columnName: 'Nombre', text: _name),
        _buildRow(controller: codeController!, columnName: 'Código', text: _code),
        _buildRowComboSelection(
            context: context,
            optionSelected: ref.watch(pointsScreenControllerProvider.notifier).getCountrySelected().name,
            columnName: 'País',
            dropDownMenuItems: pointDataGridSource.getCountries()!.map((e) => e.name).toList(),
            text: _country),
        const SizedBox(height: 20),
        _buildRowComboSelection(
            context: context,
            optionSelected: ref.watch(pointsScreenControllerProvider.notifier).getProvinceSelected().name,
            columnName: 'Municipio',
            dropDownMenuItems: ref.watch(pointsScreenControllerProvider.notifier)
                .getProvinceOptions().map((e) => e.name).toList(),
            text: _province),
        const SizedBox(height: 20),
        _buildRowComboSelection(
            context: context,
            optionSelected: activeController!.text,
            columnName: 'Activo',
            dropDownMenuItems: activeOptions,
            text: _active),
        _buildRow(controller: latitudeController!, columnName: 'Latitud', text: _latitude),
        _buildRow(controller: longitudeController!, columnName: 'Longitud', text: _longitude),
      ],
    );
  }

  void _createTextFieldContext() {
    idController!.text = '';
    nameController!.text = '';
    codeController!.text = '';
    activeController!.text = '✔';
    latitudeController!.text = '';
    longitudeController!.text = '';
  }

  // Updating the data to the TextEditingController
  void _updateTextFieldContext(DataGridRow row) {
    final String? id = row
        .getCells()
        .firstWhere((DataGridCell element) => element.columnName == 'Id')
        ?.value
        .toString();

    idController!.text = id ?? '';

    final String? name = row
        .getCells()
        .firstWhere((DataGridCell element) => element.columnName == 'Nombre')
        ?.value
        .toString();

    nameController!.text = name ?? '';

    final String? code = row
        .getCells()
        .firstWhere((DataGridCell element) => element.columnName == 'Código')
        ?.value
        .toString();

    codeController!.text = code ?? '';

    final String? countryString = row
        .getCells()
        .firstWhere((DataGridCell element) => element.columnName == 'País')
        ?.value
        .toString();
    final country = pointDataGridSource.getCountries()!.firstWhere((element) => element.name == countryString);
    ref.watch(pointsScreenControllerProvider.notifier).setCountrySelected(country);

    final String? provinceString = row
        .getCells()
        .firstWhere((DataGridCell element) => element.columnName == 'Municipio')
        ?.value
        .toString();

    final province = pointDataGridSource.getProvinces()!.firstWhere((element) => element.name == provinceString);
    ref.watch(pointsScreenControllerProvider.notifier).setProvinceSelected(province);
    ref.watch(pointsScreenControllerProvider.notifier).
      setProvinceOptions(pointDataGridSource.getProvinces()
        .where((element) => element.country == ref.watch(pointsScreenControllerProvider.notifier).getCountrySelected().countryId).toList());

    final String? active = row
        .getCells()
        .firstWhere(
          (DataGridCell element) => element.columnName == 'Activo',
        )
        ?.value
        .toString();

    activeController!.text = active != "false" ? '✔' : '✘';

    final String? latitude = row
        .getCells()
        .firstWhere((DataGridCell element) => element.columnName == 'Latitud')
        ?.value
        .toString();

    latitudeController!.text = latitude ?? '';

    final String? longitude = row
        .getCells()
        .firstWhere((DataGridCell element) => element.columnName == 'Longitud')
        ?.value
        .toString();

    longitudeController!.text = longitude ?? '';

    final String? cases = row
        .getCells()
        .firstWhere((DataGridCell element) => element.columnName == 'Casos')
        ?.value
        .toString();

    casesController!.text = cases ?? '';

    final String? casesNormopeso = row
        .getCells()
        .firstWhere((DataGridCell element) => element.columnName == 'Casos Normopeso')
        ?.value
        .toString();

    casesnormopesoController!.text = casesNormopeso ?? '';

    final String? casesModerada = row
        .getCells()
        .firstWhere((DataGridCell element) => element.columnName == 'Casos Moderada')
        ?.value
        .toString();

    casesmoderadaController!.text= casesModerada ?? '';

    final String? casesSevera = row
        .getCells()
        .firstWhere((DataGridCell element) => element.columnName == 'Casos Severa')
        ?.value
        .toString();

    casesseveraController!.text= casesSevera ?? '';
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
        title: Text(_editPoint),
        actions: _buildActionButtons(row, context),
        content: Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Form(
              key: _formKey,
              child: _buildAlertDialogContent(context),
            ),
          ),
        ),
      ),
    );
  }

  void _processCellCreate(BuildContext buildContext) async {
    if (_formKey.currentState!.validate()) {
      ref.read(pointsScreenControllerProvider.notifier).addPoint(
        Point(
                pointId: "",
                fullName: "",
                phoneCode: codeController!.text,
                name: nameController!.text,
                province: ref
                    .watch(pointsScreenControllerProvider.notifier)
                    .getProvinceSelected()
                    .provinceId,
                country: ref
                    .watch(pointsScreenControllerProvider.notifier)
                    .getCountrySelected()
                    .countryId,
                active: activeController!.text == '✔' ? true : false,
                latitude: double.parse(latitudeController!.text),
                longitude: double.parse(longitudeController!.text),
                cases: 0,
                casesnormopeso: 0,
                casesmoderada: 0,
                casessevera: 0),
      );
      Navigator.pop(buildContext);
    }
  }

  /// Updating the DataGridRows after changing the value and notify the DataGrid
  /// to refresh the view
  void _processCellUpdate(DataGridRow row, BuildContext buildContext) {
    final String? id = pointDataGridSource
        .getPoints()
        ?.firstWhere(
            (element) => element.point.pointId == row.getCells()[0].value)
        .point
        .pointId;
    if (_formKey.currentState!.validate()) {
      ref.read(pointsScreenControllerProvider.notifier).updatePoint(
          Point(
          pointId: id!,
          name: nameController!.text,
          fullName: "",
          phoneCode: codeController!.text,
          country: ref
              .watch(pointsScreenControllerProvider.notifier)
              .getCountrySelected()
              .countryId,
          province: ref
              .watch(pointsScreenControllerProvider.notifier)
              .getProvinceSelected()
              .provinceId,
          active: activeController!.text == '✔' ? true : false,
          latitude: double.parse(latitudeController!.text),
          longitude: double.parse(longitudeController!.text),
          cases: int.parse(casesController!.text),
          casesnormopeso: int.parse(casesnormopesoController!.text),
          casesmoderada: int.parse(casesmoderadaController!.text),
          casessevera: int.parse(casesseveraController!.text)));
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
    final point = pointDataGridSource
        .getPoints()
        ?.firstWhere(
            (element) => element.point.pointId == row.getCells()[0].value)
        .point;
    if (point != null) {
      ref.read(pointsScreenControllerProvider.notifier).deletePoint(point);
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
        content: Text(_removedPoint),
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
              _editPoint,
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
              _removePoint,
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
        _country = 'Country';
        _province = 'Municipality';
        _active = 'Active';
        _newPoint = 'New Point';
        _importCSV = 'Import CSV';
        _exportXLS = 'Export XLS';
        _exportPDF = 'Export PDF';
        _total = 'Total Points';
        _editPoint = 'Edit';
        _removePoint = 'Remove';
        _cancel = 'Cancel';
        _save = 'Save';
        _points = 'Points';
        _removedPoint = 'Point deleted successfully.';
        _latitude = 'Latitude';
        _longitude = 'Longitude';
        _cases = 'Cases';
        _casesnormopeso = 'Normal weight cases';
        _casesmoderada = 'Moderate cases';
        _casessevera = 'Severe cases';
        break;
      case 'es_ES':
        _id = 'Id';
        _name = 'Nombre';
        _code = 'Código';
        _country = 'País';
        _province = 'Municipio';
        _active = 'Activo';
        _newPoint = 'Crear Punto';
        _importCSV = 'Importar CSV';
        _exportXLS = 'Exportar XLS';
        _exportPDF = 'Exportar PDF';
        _total = 'Puntos totales';
        _editPoint = 'Editar';
        _removePoint = 'Eliminar';
        _cancel = 'Cancelar';
        _save = 'Guardar';
        _points = 'Puntos';
        _removedPoint = 'Punto eliminado correctamente';
        _latitude = 'Latitud';
        _longitude = 'Longitud';
        _cases = 'Casos';
        _casesnormopeso = 'Casos Normopeso';
        _casesmoderada = 'Casos Moderada';
        _casessevera = 'Casos Severa';
        break;
      case 'fr_FR':
        _id = 'Id';
        _name = 'Nom';
        _code = 'Code';
        _province = 'Municipalité';
        _country = 'Pays';
        _active = 'Actif';
        _newPoint = 'Créer un Point';
        _importCSV = 'Importer CSV';
        _exportXLS = 'Exporter XLS';
        _exportPDF = 'Exporter PDF';
        _total = 'Total des Points';
        _editPoint = 'Modifier';
        _removePoint = 'Supprimer';
        _cancel = 'Annuler';
        _save = 'Enregistrer';
        _points = 'Les Points';
        _removedPoint = 'Point supprimé avec succès.';
        _latitude = 'Latitude';
        _longitude = 'Longitude';
        _cases = 'Cas';
        _casesnormopeso = 'Cas poids normal';
        _casesmoderada = 'Cas modérés';
        _casessevera = 'Cas sévères';
        break;
    }
    return SfDataGrid(
      key: _key,
      source: pointDataGridSource,
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
            )),
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
            )),
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
            )),
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
          columnName: 'Municipio',
          width: columnWidths['Municipio']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _province,
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
            columnName: 'Latitud',
            width: columnWidths['Latitud']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _latitude,
                overflow: TextOverflow.ellipsis,
              ),
            )),
        GridColumn(
            columnName: 'Longitud',
            width: columnWidths['Longitud']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _longitude,
                overflow: TextOverflow.ellipsis,
              ),
            )),
        GridColumn(
            columnName: 'Casos',
            width: columnWidths['Casos']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _cases,
                overflow: TextOverflow.ellipsis,
              ),
            )),
        GridColumn(
            columnName: 'Casos Normopeso',
            width: columnWidths['Casos Normopeso']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _casesnormopeso,
                overflow: TextOverflow.ellipsis,
              ),
            )),
        GridColumn(
            columnName: 'Casos Moderada',
            width: columnWidths['Casos Moderada']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _casesmoderada,
                overflow: TextOverflow.ellipsis,
              ),
            )),
        GridColumn(
            columnName: 'Casos Severa',
            width: columnWidths['Casos Severa']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _casessevera,
                overflow: TextOverflow.ellipsis,
              ),
            )),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    pointDataGridSource = PointDataGridSource(List.empty(), List.empty(), List.empty());
    idController = TextEditingController();
    nameController = TextEditingController();
    codeController = TextEditingController();
    activeController = TextEditingController();
    latitudeController = TextEditingController();
    longitudeController = TextEditingController();
    casesController = TextEditingController();
    casesnormopesoController = TextEditingController();
    casesmoderadaController = TextEditingController();
    casesseveraController = TextEditingController();
    selectedLocale = model.locale.toString();

    _id = 'Id';
    _name = 'Nombre';
    _code = 'Código';
    _country = 'País';
    _province = 'Municipio';
    _active = 'Activo';
    _latitude = 'Latitud';
    _longitude = 'Longitud';
    _cases = 'Casos';
    _casesnormopeso = 'Casos Normopeso';
    _casesmoderada = 'Casos Moderada';
    _casessevera = 'Casos Severa';
    _newPoint = 'Crear Punto';
    _importCSV = 'Importar CSV';
    _exportXLS = 'Exportar XLS';
    _exportPDF = 'Exportar PDF';
    _total = 'Puntos totales';
    _editPoint = 'Editar';
    _removePoint = 'Eliminar';
    _cancel = 'Cancelar';
    _save = 'Guardar';
    _points = 'Puntos';
    _removedPoint = '';
  }

  @override
  Widget buildSample(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      ref.listen<AsyncValue>(
        pointsScreenControllerProvider,
        (_, state) => {},
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
      final countriesAsyncValue = ref.watch(countriesStreamProvider);
      final provinciesAsyncValue = ref.watch(provincesStreamProvider);
      final pointsAsyncValue = ref.watch(pointsStreamProvider);

      if (countriesAsyncValue.value != null) {
        _saveCountries(countriesAsyncValue);
        if (ref.watch(pointsScreenControllerProvider.notifier).getCountrySelected().name.isEmpty) {
          ref.watch(pointsScreenControllerProvider.notifier).setCountrySelected(
              pointDataGridSource.getCountries()!.first);
        }
      }

      if (provinciesAsyncValue.value != null) {
        _saveProvinces(provinciesAsyncValue);
      }
      if (pointsAsyncValue.value != null) {
        _savePoints(pointsAsyncValue);
      }

      return _buildView(pointsAsyncValue);
    });
  }
}

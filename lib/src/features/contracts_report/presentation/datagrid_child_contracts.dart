/// Package imports
/// import 'package:flutter/foundation.dart';

import 'package:adminnut4health/src/features/contracts_report/domain/child_inform.dart';
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
import 'package:tuple/tuple.dart';

import '../../../sample/model/sample_view.dart';
/// Local import
import '../data/firestore_repository.dart';
import 'contract_child_datagridsource.dart';
import 'dart:html' show FileReader;

import '../../../common_widgets/export/save_file_mobile.dart'
  if (dart.library.html) '../../../common_widgets/export/save_file_web.dart' as helper;

import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'contracts_child_screen_controller.dart';

/// Render contract data grid
class Mauritane2024DailyContractChildDataGrid extends LocalizationSampleView {
  /// Creates getting started data grid
  const Mauritane2024DailyContractChildDataGrid({Key? key}) : super(key: key);

  @override
  _Mauritane2024DailyContractChildDataGridState createState() => _Mauritane2024DailyContractChildDataGridState();
}

class _Mauritane2024DailyContractChildDataGridState extends LocalizationSampleViewState {

  final GlobalKey<SfDataGridState> _key = GlobalKey<SfDataGridState>();

  /// DataGridSource required for SfDataGrid to obtain the row data.
  late ChildInformDataGridSource childInformDataGridSource;

  static const double dataPagerHeight = 60;
  int _rowsPerPage = 15;

  /// Selected locale
  late String selectedLocale;

  /// Translate names
  late String _place, _records, _ageGroup,
      _male, _malemas, _malemam, _malepn,
      _female,
      _day, _month, _year,
      _exportXLS, _exportPDF, _total, _contracts;

  late Map<String, double> columnWidths = {
    'Localidad': 200,
    'Edad': 200,
    'Registros': 200,
    'M': 150,
    'M MAS': 150,
    'M MAM': 150,
    'M PN': 150,
    'F': 150,
  };

  late TextEditingController yearController, monthController, dayController;

  AsyncValue<List<ChildInform>> childInformsAsyncValue = AsyncValue.data(List.empty());

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

  _saveChildInforms(AsyncValue<List<ChildInform>>? childInforms) {
    if (childInforms == null) {
      childInformDataGridSource.setChildInforms(List.empty());
    } else {
      childInformDataGridSource.setChildInforms(childInforms.value);
    }
  }

  Widget _buildView(AsyncValue<List<ChildInform>> childInforms) {
    if (childInforms.value != null) {
      childInformDataGridSource.buildDataGridRows();
      childInformDataGridSource.updateDataSource();
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
          if (childInformDataGridSource.getChildInforms()!.isEmpty) {
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

  Future<String> readBlob(Blob blob) async {
    final reader = FileReader();
    reader.readAsText(blob);
    await reader.onLoad.first;
    return reader.result as String;
  }

  Widget _buildHeaderButtons() {
    Future<void> exportDataGridToExcel() async {
      final Workbook workbook = _key.currentState!.exportToExcelWorkbook(
          cellExport: (DataGridCellExcelExportDetails details) {});
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();
      await helper.FileSaveHelper.saveAndLaunchFile(bytes, '$_contracts.xlsx');
    }

    Future<void> exportDataGridToPdf() async {
      final ByteData data = await rootBundle.load('images/nut_logo.jpg');
      final PdfDocument document = _key.currentState!.exportToPdfDocumentLandscape(
          cellExport: (DataGridCellPdfExportDetails details) {},
          headerFooterExport: (DataGridPdfHeaderFooterExportDetails details) {
            final double width = details.pdfPage.getClientSize().width;
            final PdfPageTemplateElement header =
            PdfPageTemplateElement(Rect.fromLTWH(0, 0, width, 65));

            header.graphics.drawImage(
                PdfBitmap(data.buffer
                    .asUint8List(data.offsetInBytes, data.lengthInBytes)),
                Rect.fromLTWH(width - 148, 0, 148, 60));

            header.graphics.drawString(_contracts,
              PdfStandardFont(PdfFontFamily.helvetica, 13,
                  style: PdfFontStyle.bold),
              bounds: const Rect.fromLTWH(0, 25, 200, 60),
            );

            details.pdfDocumentTemplate.top = header;
          });
      final List<int> bytes = document.saveSync();
      await helper.FileSaveHelper.saveAndLaunchFile(bytes, '$_contracts.pdf');
      document.dispose();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _buildPDFExportingButton(_exportPDF, onPressed: exportDataGridToPdf),
        _buildExcelExportingButton(_exportXLS, onPressed: exportDataGridToExcel),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFilterRow(),
            ],
          ),
        ),
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
    var rows = childInformDataGridSource.rows;
    if (childInformDataGridSource.effectiveRows.isNotEmpty ) {
      rows = childInformDataGridSource.effectiveRows;
    }
    var addMorePage = 0;
    if ((rows.length / _rowsPerPage).remainder(1) != 0) {
      addMorePage  = 1;
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SfDataPager(
          delegate: childInformDataGridSource,
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
                columnName: 'Localidad',
                summaryType: GridSummaryType.count),
          ],
          position: GridTableSummaryRowPosition.bottom),
    ];
  }

  SfDataGrid _buildDataGrid() {
    final selectedLocale = model.locale.toString();
    switch (selectedLocale) {
      case 'en_US':
        _place = 'Location';
        _ageGroup = 'Age';
        _records = 'Records';
        _male = 'M';
        _malemas = 'M MAS';
        _malemam = 'M MAM';
        _malepn = 'M PN';
        _female = 'F';
        _exportXLS = 'Export XLS';
        _exportPDF = 'Export PDF';
        _total = 'Total Diagnosis';
        _contracts = 'Diagnosis';
        _day = 'Day';
        _month = 'Month';
        _year = 'Year';
        break;
      case 'es_ES':
        _place = 'Localidad';
        _ageGroup = 'Edad';
        _records = 'Registros';
        _male = 'M';
        _malemas = 'M MAS';
        _malemam = 'M MAM';
        _malepn = 'M PN';
        _female = 'F';
        _exportXLS = 'Exportar XLS';
        _exportPDF = 'Exportar PDF';
        _total = 'Diagnósticos totales';
        _contracts = 'Diagnósticos';
        _day = 'Día';
        _month = 'Mes';
        _year = 'Año';
        break;
      case 'fr_FR':
        _place = 'Localité';
        _ageGroup = 'Âge';
        _records = 'Registres';
        _male = 'M';
        _malemas = 'M MAS';
        _malemam = 'M MAM';
        _malepn = 'M PN';
        _female = 'F';
        _exportXLS = 'Exporter XLS';
        _exportPDF = 'Exporter PDF';
        _total = 'Total des diagnostics';
        _contracts = 'Diagnostics';
        _day = 'Jour';
        _month = 'Mois';
        _year = 'Année';
        break;
    }
    return SfDataGrid(
      key: _key,
      source: childInformDataGridSource,
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
            width: columnWidths['Localidad']!,
            columnName: 'Localidad',
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _place,
                overflow: TextOverflow.ellipsis,
              ),
            )),
        GridColumn(
            width: columnWidths['Edad']!,
            columnName: 'Edad',
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _ageGroup,
                overflow: TextOverflow.ellipsis,
              ),
            )),
        GridColumn(
          columnName: 'Registros',
            width: columnWidths['Registros']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _records,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ),
        GridColumn(
            columnName: 'M',
            width: columnWidths['M']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _male,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'M MAS',
            width: columnWidths['M MAS']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _malemas,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'M MAM',
            width: columnWidths['M MAM']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _malemam,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'M PN',
            width: columnWidths['M PN']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _malepn,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'F',
            width: columnWidths['F']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _female,
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
    childInformDataGridSource = ChildInformDataGridSource(List.empty());

    selectedLocale = model.locale.toString();

    _place = 'Localidad';
    _ageGroup = 'Edad';
    _records = 'Registros';
    _male = 'M';
    _malemas = 'M MAS';
    _malemam = 'M MAM';
    _malepn = 'M PN';
    _female = 'F';
    _exportXLS = 'Exportar XLS';
    _exportPDF = 'Exportar PDF';
    _total = 'Diagnósticos totales';
    _contracts = 'Diagnósticos';
    _day = 'Día';
    _month = 'Mes';
    _year = 'Año';
    yearController = TextEditingController();
    monthController = TextEditingController();
    dayController = TextEditingController();

    yearController.text = DateTime.now().year.toString();
    monthController.text = DateTime.now().month.toString();
    dayController.text = DateTime.now().day.toString();

  }


  @override
  Widget buildSample(BuildContext context) {
    int day = 0;
    int month = 0;
    int year = 0;

    if (dayController.text.isNotEmpty && monthController.text.isNotEmpty && yearController.text.isNotEmpty) {
      day = int.parse(dayController.text);
      month = int.parse(monthController.text);
      year = int.parse(yearController.text);
    }
    return Consumer(
        builder: (context, ref, child) {
          ref.listen<AsyncValue>(
            contractschildScreenControllerProvider,
                (_, state) => {
            },
          );

          Tuple3<int, int, int> tuple3 = Tuple3(day, month, year);

          childInformsAsyncValue = ref.watch(childInformMauritane2024StreamProvider(tuple3));

          if (childInformsAsyncValue.value != null) {
            _saveChildInforms(childInformsAsyncValue);
          }

          return _buildView(childInformsAsyncValue);
        });

  }

  Widget _buildFilterRow() {
    final selectedLocale = model.locale.toString();
    switch (selectedLocale) {
      case 'en_US':
        _day = 'Day';
        _month = 'Month';
        _year = 'Year';
        break;
      case 'es_ES':
        _day = 'Día';
        _month = 'Mes';
        _year = 'Año';
        break;
      case 'fr_FR':
        _day = 'Jour';
        _month = 'Mois';
        _year = 'Année';
        break;
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 150,
            child: TextField(
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              controller: yearController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: _year,
              ),
              onChanged: (it) {
                setState(() {
                  buildSample(context);
                });
              },
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: 150,
            child: TextField(
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              controller: monthController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: _month,
              ),
              onChanged: (it) {
                setState(() {
                  buildSample(context);
                });
              },
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: 150,
            child: TextField(
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              controller: dayController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: _day,
              ),
              onChanged: (it) {
                setState(() {
                  buildSample(context);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

}



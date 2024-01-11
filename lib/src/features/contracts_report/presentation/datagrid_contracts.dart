/// Package imports
/// import 'package:flutter/foundation.dart';

import 'package:adminnut4health/src/features/contracts_report/domain/main_inform.dart';
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
/// Local import
import '../data/firestore_repository.dart';
import 'contract_datagridsource.dart';
import 'dart:html' show FileReader;

import '../../../common_widgets/export/save_file_mobile.dart'
  if (dart.library.html) '../../../common_widgets/export/save_file_web.dart' as helper;

import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'contracts_screen_controller.dart';

/// Render contract data grid
class Mauritane2024DailyContractDataGrid extends LocalizationSampleView {
  /// Creates getting started data grid
  const Mauritane2024DailyContractDataGrid({Key? key}) : super(key: key);

  @override
  _Mauritane2024DailyContractDataGridState createState() => _Mauritane2024DailyContractDataGridState();
}

class _Mauritane2024DailyContractDataGridState extends LocalizationSampleViewState {

  final GlobalKey<SfDataGridState> _key = GlobalKey<SfDataGridState>();

  /// DataGridSource required for SfDataGrid to obtain the row data.
  late MainInformDataGridSource mainInformDataGridSource;

  static const double dataPagerHeight = 60;
  int _rowsPerPage = 15;

  /// Selected locale
  late String selectedLocale;

  /// Translate names
  late String _place, _records, _childs, _childsSAM, _childsMAM, _childsPN,
      _fefas,
      _exportXLS, _exportPDF, _total, _contracts;

  late Map<String, double> columnWidths = {
    'Localidad': 200,
    'Registros': 200,
    'Niños/as': 200,
    'Niños/as SAM': 200,
    'Niños/as MAM': 200,
    'Niños/as PN': 200,
    'FEFAS': 200,
  };

  AsyncValue<List<MainInform>> mainInformsAsyncValue = AsyncValue.data(List.empty());

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

  _saveMainInforms(AsyncValue<List<MainInform>>? mainInforms) {
    if (mainInforms == null) {
      mainInformDataGridSource.setMainInforms(List.empty());
    } else {
      mainInformDataGridSource.setMainInforms(mainInforms.value);
    }
  }

  Widget _buildView(AsyncValue<List<MainInform>> mainInforms) {
    if (mainInforms.value != null) {
      mainInformDataGridSource.buildDataGridRows();
      mainInformDataGridSource.updateDataSource();
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
          if (mainInformDataGridSource.getMainInforms()!.isEmpty) {
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
      final PdfDocument document = _key.currentState!.exportToPdfDocument(
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
    var rows = mainInformDataGridSource.rows;
    if (mainInformDataGridSource.effectiveRows.isNotEmpty ) {
      rows = mainInformDataGridSource.effectiveRows;
    }
    var addMorePage = 0;
    if ((rows.length / _rowsPerPage).remainder(1) != 0) {
      addMorePage  = 1;
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SfDataPager(
          delegate: mainInformDataGridSource,
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
        _records = 'Records';
        _childs = 'Childs';
        _childsSAM = 'Childs SAM';
        _childsMAM = 'Childs MAM';
        _childsPN = 'Childs PN';
        _fefas = 'FEFAS';
        _exportXLS = 'Export XLS';
        _exportPDF = 'Export PDF';
        _total = 'Total Diagnosis';
        _contracts = 'Diagnosis';
        break;
      case 'es_ES':
        _place = 'Localidad';
        _records = 'Registros';
        _childs = 'Niños/as';
        _childsSAM = 'Niños/as SAM';
        _childsMAM = 'Niños/as MAM';
        _childsPN = 'Niños/as PN';
        _fefas = 'FEFAS';
        _exportXLS = 'Exportar XLS';
        _exportPDF = 'Exportar PDF';
        _total = 'Diagnósticos totales';
        _contracts = 'Diagnósticos';
        break;
      case 'fr_FR':
        _place = 'Localité';
        _records = 'Registres';
        _childs = 'Enfants';
        _childsSAM = 'Enfants SAM';
        _childsMAM = 'Enfants MAM';
        _childsPN = 'Enfants PN';
        _fefas = 'FEFAS';
        _exportXLS = 'Exporter XLS';
        _exportPDF = 'Exporter PDF';
        _total = 'Total des diagnostics';
        _contracts = 'Diagnostics';
        break;
    }
    return SfDataGrid(
      key: _key,
      source: mainInformDataGridSource,
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
            columnName: 'Niños/as',
            width: columnWidths['Niños/as']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _childs,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Niños/as SAM',
            width: columnWidths['Niños/as SAM']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _childsSAM,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Niños/as MAM',
            width: columnWidths['Niños/as MAM']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _childsMAM,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Niños/as PN',
            width: columnWidths['Niños/as PN']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _childsPN,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'FEFAS',
            width: columnWidths['FEFAS']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _fefas,
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
    mainInformDataGridSource = MainInformDataGridSource(List.empty());

    selectedLocale = model.locale.toString();

    _place = 'Localidad';
    _records = 'Registros';
    _childs = 'Niños/as';
    _childsSAM = 'Niños/as SAM';
    _childsMAM = 'Niños/as MAM';
    _childsPN = 'Niños/as PN';
    _fefas = 'FEFAS';
    _exportXLS = 'Exportar XLS';
    _exportPDF = 'Exportar PDF';
    _total = 'Diagnósticos totales';
    _contracts = 'Diagnósticos';

  }


  @override
  Widget buildSample(BuildContext context) {
    return Consumer(
        builder: (context, ref, child) {
          ref.listen<AsyncValue>(
            contractsScreenControllerProvider,
                (_, state) => {
            },
          );

          mainInformsAsyncValue = ref.watch(mainInformMauritane2024StreamProvider);

          if (mainInformsAsyncValue.value != null) {
            _saveMainInforms(mainInformsAsyncValue);
          }

          return _buildView(mainInformsAsyncValue);
        });
  }

}



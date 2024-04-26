/// Package imports
/// import 'package:flutter/foundation.dart';

import 'package:adminnut4health/src/features/contracts_report/domain/child_inform.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:typed_data';
import 'dart:html' show Blob, AnchorElement, Url;

/// Barcode import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

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

  int start = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).millisecondsSinceEpoch;

  int end = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59).millisecondsSinceEpoch;

  /// Selected locale
  late String selectedLocale;

  /// Translate names
  late String _place, _records, _ageGroup,
      _male, _malemas, _malemam, _malepn,
      _female, _femalemas, _femalemam, _femalepn,
      _start, _end,
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
    'F MAS': 150,
    'F MAM': 150,
    'F PN': 150,
  };

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
                _buildHeaderButtons(),
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: SfDataGridTheme(
                        data: SfDataGridThemeData(headerColor: Colors.blueAccent),
                        child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: _buildDataGrid()
                        )
                    ),
                  ),
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
        //exportTableSummaries: false,
          cellExport: (DataGridCellExcelExportDetails details) {

          });
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
        _femalemas = 'F MAS';
        _femalemam = 'F MAM';
        _femalepn = 'F PN';
        _exportXLS = 'Export XLS';
        _exportPDF = 'Export PDF';
        _total = 'Total Locations';
        _contracts = 'Diagnosis';
        _start = 'Start';
        _end = 'End';
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
        _femalemas = 'F MAS';
        _femalemam = 'F MAM';
        _femalepn = 'F PN';
        _exportXLS = 'Exportar XLS';
        _exportPDF = 'Exportar PDF';
        _total = 'Localidades totales';
        _contracts = 'Diagnósticos';
        _start = 'Inicio';
        _end = 'Fin';
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
        _femalemas = 'F MAS';
        _femalemam = 'F MAM';
        _femalepn = 'F PN';
        _exportXLS = 'Exporter XLS';
        _exportPDF = 'Exporter PDF';
        _total = 'Total des localités';
        _contracts = 'Diagnostics';
        _start = 'Début';
        _end = 'Fin';
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
        GridColumn(
            columnName: 'F MAS',
            width: columnWidths['F MAS']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _femalemas,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'F MAM',
            width: columnWidths['F MAM']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _femalemam,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'F PN',
            width: columnWidths['F PN']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _femalepn,
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
    _femalemas = 'F MAS';
    _femalemam = 'F MAM';
    _femalepn = 'F PN';
    _exportXLS = 'Exportar XLS';
    _exportPDF = 'Exportar PDF';
    _total = 'Diagnósticos totales';
    _contracts = 'Diagnósticos';
    _start = 'Inicio';
    _end = 'Fin';

  }


  @override
  Widget buildSample(BuildContext context) {

    return Consumer(
        builder: (context, ref, child) {
          ref.listen<AsyncValue>(
            contractschildScreenControllerProvider,
                (_, state) => {
            },
          );

          Tuple2<int, int> tuple2 = Tuple2(start, end);

          childInformsAsyncValue = ref.watch(childInformMauritane2024StreamProvider(tuple2));

          if (childInformsAsyncValue.value != null) {
            _saveChildInforms(childInformsAsyncValue);
          }

          return _buildView(childInformsAsyncValue);
        });

  }

  Widget _buildFilterRow() {
    return Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 400,
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: SfDateRangePicker(
                    initialSelectedRange: PickerDateRange(
                      DateTime.fromMillisecondsSinceEpoch(start),
                      DateTime.fromMillisecondsSinceEpoch(end),),
                    onSelectionChanged: _onSelectionChanged,
                    selectionMode: DateRangePickerSelectionMode.range,
                  ),
                ),
              ),
            ],
          ),
        ],
    );
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (args.value is PickerDateRange) {
      final PickerDateRange range = args.value;
      final DateTime? startDate = range.startDate;
      final DateTime? endDate = range.endDate?.copyWith(hour: 23, minute: 59, second: 59);

      start = startDate!.millisecondsSinceEpoch;
      if (endDate != null && endDate.millisecondsSinceEpoch > startDate.millisecondsSinceEpoch){
        end = endDate.millisecondsSinceEpoch;
        setState(() {
          _buildLayoutBuilder();
        });
      }
    }
  }

}



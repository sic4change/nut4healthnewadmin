/// Package imports
/// import 'package:flutter/foundation.dart';

import 'package:adminnut4health/src/features/countries/domain/country.dart';
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
import 'package:tuple/tuple.dart';

import '../../../sample/model/sample_view.dart';
import '../../regions/domain/region.dart';
/// Local import
import '../data/firestore_repository.dart';
import '../domain/PointWithVisitAndChild.dart';
import 'dart:html' show FileReader;

import '../../../common_widgets/export/save_file_mobile.dart'
  if (dart.library.html) '../../../common_widgets/export/save_file_web.dart' as helper;

import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'contracts_screen_controller.dart';
import 'diagnosis_communitary_crenam_by_region_and_date_datagridsource.dart';

/// Render contract data grid
class DiagnosisCommunitaryCrenamByRegionAndDateDataGrid extends LocalizationSampleView {
  /// Creates getting started data grid
  const DiagnosisCommunitaryCrenamByRegionAndDateDataGrid({Key? key}) : super(key: key);

  @override
  _DiagnosisCommunitaryCrenamByRegionAndDateDataGridState createState() => _DiagnosisCommunitaryCrenamByRegionAndDateDataGridState();
}

class _DiagnosisCommunitaryCrenamByRegionAndDateDataGridState extends LocalizationSampleViewState {

  final GlobalKey<SfDataGridState> _key = GlobalKey<SfDataGridState>();

  /// DataGridSource required for SfDataGrid to obtain the row data.
  late DiagnosisCommunitaryCrenamByRegionAndDateInformDataGridSource mainInformDataGridSource;

  static const double dataPagerHeight = 60;
  int _rowsPerPage = 15;

  /// Selected locale
  late String selectedLocale;


  int start = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).millisecondsSinceEpoch;

  int end = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59).millisecondsSinceEpoch;


  /// Translate names
  late String _category, _red, _yellow, _green, _oedema,
      _start, _end, _exportXLS, _exportPDF, _total, _contracts, _selectCountry,
      _selectRegion;

  late Map<String, double> columnWidths = {
    'Categoría': 200,
    'Rojo (<115mm)': 200,
    'Amarillo (115-125mm)': 200,
    'Verde (>= 125mm)': 200,
    'Oedema': 200,
  };


  AsyncValue<List<VisitWithChildAndPoint>> mainInformsAsyncValue = AsyncValue.data(List.empty());

  List<Country> countries = <Country>[];
  Country? countrySelected;

  List<Region> regions = <Region>[];
  Region? regionSelected;

  Widget getLocationWidget(String location) {
    return Row(
      children: <Widget>[
        Image.asset('images/location.png'),
        Text(' $location',)
      ],
    );
  }

  _saveCountries(AsyncValue<List<Country>>? countries) {
    if (countries == null) {
      return;
    } else {
      this.countries.clear();
      this.countries.add(const Country(countryId: "", name: "TODOS", code: "",
          active: false, needValidation: false, cases: 0, casesnormopeso: 0,
          casesmoderada: 0, casessevera: 0));
      this.countries.addAll(countries.value!);
    }
  }

  _saveRegions(AsyncValue<List<Region>>? regions) {
    if (regions == null) {
      return;
    } else {
      this.regions.clear();
      this.regions.add(const Region(regionId: '', name: 'TODAS', countryId: '', active: false));
      this.regions.addAll(regions.value!);
    }
  }

  _saveMainInforms(AsyncValue<List<VisitWithChildAndPoint>>? mainInforms) {
    if (mainInforms == null) {
      mainInformDataGridSource.setMainInforms(List.empty(), selectedLocale);
    } else {
      mainInformDataGridSource.setMainInforms(mainInforms.value, selectedLocale);
    }
  }

  Widget _buildView(AsyncValue<List<VisitWithChildAndPoint>> mainInforms) {
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
                const SizedBox(height: 20.0,),
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
                const SizedBox(height: 20.0,),
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
      //CustomDataGridToExcelConverter excelConverter = CustomDataGridToExcelConverter();
      //final Workbook workbook = _key.currentState!.exportToExcelWorkbook(converter: excelConverter);
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

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(child: _buildFilterRow(),),
          _buildExcelExportingButton(_exportXLS, onPressed: exportDataGridToExcel),
          _buildPDFExportingButton(_exportPDF, onPressed: exportDataGridToPdf),
        ],
      ),
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
                columnName: 'Categoría',
                summaryType: GridSummaryType.count),
          ],
          position: GridTableSummaryRowPosition.bottom),
    ];
  }

  SfDataGrid _buildDataGrid() {
    final selectedLocale = model.locale.toString();
    switch (selectedLocale) {
      case 'en_US':
        _category = 'Category';
        _red = 'Red (<115mm)';
        _yellow = 'Yellow (115-125mm)';
        _green = 'Green (>= 125mm)';
        _oedema = 'Oedema';
        _exportXLS = 'Export XLS';
        _exportPDF = 'Export PDF';
        _total = 'Total Locations';
        _contracts = 'Diagnosis';
        _start = 'Start';
        _end = 'End';
        break;
      case 'es_ES':
        _category = 'Categoría';
        _red = 'Rojo (<115mm)';
        _yellow = 'Amarillo (115-125mm)';
        _green = 'Verde (>= 125mm)';
        _oedema = 'Oedema';
        _exportXLS = 'Exportar XLS';
        _exportPDF = 'Exportar PDF';
        _total = 'Totales';
        _contracts = 'Diagnósticos';
        _start = 'Inicio';
        _end = 'Fin';
        break;
      case 'fr_FR':
        _category = 'Catégorie';
        _red = 'Rouge (<115mm)';
        _yellow = 'Jaune (115-125mm)';
        _green = 'Vert (>= 125mm)';
        _oedema = 'Oedème';
        _exportXLS = 'Exporter XLS';
        _exportPDF = 'Exporter PDF';
        _total = 'Total';
        _contracts = 'Diagnostics';
        _start = 'Début';
        _end = 'Fin';
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
            width: columnWidths['Categoría']!,
            columnName: 'Categoría',
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _category,
                overflow: TextOverflow.ellipsis,
              ),
            )),
        GridColumn(
          columnName: 'Rojo (<115mm)',
            width: columnWidths['Rojo (<115mm)']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _red,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ),
        GridColumn(
            columnName: 'Amarillo (115-125mm)',
            width: columnWidths['Amarillo (115-125mm)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _yellow,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Verde (>= 125mm)',
            width: columnWidths['Verde (>= 125mm)']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _green,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Oedema',
            width: columnWidths['Oedema']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _oedema,
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
    mainInformDataGridSource = DiagnosisCommunitaryCrenamByRegionAndDateInformDataGridSource(List.empty());

    selectedLocale = model.locale.toString();

    _category = 'Categoría';
    _red = 'Rojo (<115mm)';
    _yellow = 'Amarillo (115-125mm)';
    _green = 'Verde (>= 125mm)';
    _oedema = 'Oedema';
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
            contractsScreenControllerProvider,
                (_, state) => {
            },
          );

          final countriesAsyncValue = ref.watch(countriesStreamProvider);
          if (countriesAsyncValue.value != null) {
            _saveCountries(countriesAsyncValue);
          }

          final regionsAsyncValue = ref.watch(regionsByCountryStreamProvider(countrySelected?.countryId??""));
          if (regionsAsyncValue.value != null) {
            _saveRegions(regionsAsyncValue);
          }

          Tuple4<int, int, String, String> filters = Tuple4(start, end, countrySelected?.countryId??"", regionSelected?.regionId??"");
          mainInformsAsyncValue = ref.watch(visitWithChildAndCommunityCrenamPoinStreamProvider(filters));
          if (mainInformsAsyncValue != null && mainInformsAsyncValue.value != null) {
            _saveMainInforms(mainInformsAsyncValue);
          }

          return _buildView(mainInformsAsyncValue);
        });

  }

  Widget _buildFilterRow() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.start,
      runSpacing: 20.0,
      spacing: 20.0,
      children: [
        _buildCountryPicker(),
        _buildRegionPicker(),
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

  Widget _buildCountryPicker() {
    switch (model.locale.toString()) {
      case 'es_ES':
        _selectCountry = 'Selecciona un país';
        break;
      case 'fr_FR':
        _selectCountry = 'Sélectionnez un pays';
        break;
      default:
        _selectCountry = 'Select country';
        break;
    }

    return Column(children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(5.0),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.0),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
            child: SizedBox(
              height: 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  DropdownButton<String>(
                      focusColor: Colors.transparent,
                      underline:
                      Container(color: const Color(0xFFBDBDBD), height: 1),
                      value: countrySelected?.name,
                      hint: Text(_selectCountry),
                      items: countries.map((Country c) {
                        return DropdownMenuItem<String>(
                            value: c.name,
                            child: Text(c.name,
                                style: TextStyle(color: model.textColor)));
                      }).toList(),
                      onChanged: (dynamic value) {
                        setState(() {
                          countrySelected = countries.firstWhere((c) => c.name == value);
                          regionSelected = null;
                        });
                      }),
                ],
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _buildRegionPicker() {
    switch (model.locale.toString()) {
      case 'es_ES':
        _selectRegion = 'Selecciona una región';
        break;
      case 'fr_FR':
        _selectRegion = 'Sélectionnez une région';
        break;
      default:
        _selectRegion = 'Select region';
        break;
    }

    return Column(children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(5.0),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.0),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
            child: SizedBox(
              height: 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  DropdownButton<String>(
                      focusColor: Colors.transparent,
                      underline:
                      Container(color: const Color(0xFFBDBDBD), height: 1),
                      value: regionSelected?.name,
                      hint: Text(_selectRegion),
                      items: regions.map((Region r) {
                        return DropdownMenuItem<String>(
                            value: r.name,
                            child: Text(r.name,
                                style: TextStyle(color: model.textColor)));
                      }).toList(),
                      onChanged: (dynamic value) {
                        setState(() {
                          regionSelected = regions.firstWhere((r) => r.name == value);
                        });
                      }),
                ],
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}



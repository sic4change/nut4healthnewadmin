/// Package imports
/// import 'package:flutter/foundation.dart';

import 'package:adminnut4health/src/features/contracts_report/domain/case_full.dart';
import 'package:adminnut4health/src/features/contracts_report/presentation/admissions_and_discharges_datagridsource.dart';
import 'package:adminnut4health/src/features/countries/domain/country.dart';
import 'package:adminnut4health/src/features/locations/domain/location.dart';
import 'package:adminnut4health/src/features/points/domain/point.dart';
import 'package:adminnut4health/src/features/provinces/domain/province.dart';
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

/// Render contract data grid
class AdmissionsAndDischargesDataGrid extends LocalizationSampleView {
  /// Creates getting started data grid
  const AdmissionsAndDischargesDataGrid({Key? key}) : super(key: key);

  @override
  _AdmissionsAndDischargesDataGridState createState() => _AdmissionsAndDischargesDataGridState();
}

class _AdmissionsAndDischargesDataGridState extends LocalizationSampleViewState {

  final GlobalKey<SfDataGridState> _key = GlobalKey<SfDataGridState>();

  /// DataGridSource required for SfDataGrid to obtain the row data.
  late AdmissionsAndDischargesDataGridSource mainInformDataGridSource;

  static const double dataPagerHeight = 60;
  int _rowsPerPage = 15;

  /// Selected locale
  late String selectedLocale;


  int start = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).millisecondsSinceEpoch;

  int end = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59).millisecondsSinceEpoch;


  /// Translate names
  late String _category, _patientsAtBeginning, _newAdmissions, _reAdmissions, _referred,
      _transfered, _totalAdmissions, _totalAttended,
      _start, _end, _exportXLS, _exportPDF, _total, _contracts, _selectCountry,
      _selectRegion, _selectLocation, _selectProvince, _selectPointType, _selectPoint;

  late Map<String, double> columnWidths = {
    'Categoría': 200,
    'Pacientes al inicio': 200,
    'Nuevos casos': 200,
    'Readmisiones': 200,
    'Referidos': 200,
    'Transferidos': 200,
    'TOTAL ADMISIONES': 200,
    'TOTAL ATENDIDOS/AS': 200,
  };


  AsyncValue<List<CaseFull>> casesAsyncValue = AsyncValue.data(List.empty());
  AsyncValue<List<CaseFull>> openCasesBeforeStartDateAsyncValue = AsyncValue.data(List.empty());

  List<Country> countries = <Country>[];
  Country? countrySelected;

  List<Region> regions = <Region>[];
  Region? regionSelected;

  List<Location> locations = <Location>[];
  Location? locationSelected;

  List<Province> provinces = <Province>[];
  Province? provinceSelected;

  final pointTypes =  ["CRENAM", "CRENAS", "CRENI", "Otro"];
  String? pointTypeSelected;

  List<Point> points = <Point>[];
  Point? pointSelected;

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

  _saveLocations(AsyncValue<List<Location>>? locations) {
    if (locations == null) {
      return;
    } else {
      this.locations.clear();
      this.locations.add(const Location(locationId: '', name: 'TODAS', country: '', regionId: '', active: false));
      this.locations.addAll(locations.value!);
    }
  }

  _saveProvinces(AsyncValue<List<Province>>? provinces) {
    if (provinces == null) {
      return;
    } else {
      this.provinces.clear();
      this.provinces.add(const Province.all());
      this.provinces.addAll(provinces.value!);
    }
  }

  _savePoints(AsyncValue<List<Point>>? points) {
    if (points == null) {
      return;
    } else {
      this.points.clear();
      this.points.add(Point.getPointAll());
      this.points.addAll(points.value!);
    }
  }

  _saveMainInforms(AsyncValue<List<CaseFull>>? casesByDate, AsyncValue<List<CaseFull>>? casesBeforeStartDate) {
    if (casesByDate == null || casesBeforeStartDate == null) {
      mainInformDataGridSource.setMainInforms(List.empty(), List.empty(), selectedLocale);
    } else {
      mainInformDataGridSource.setMainInforms(casesByDate.value, casesBeforeStartDate.value, selectedLocale);
    }
  }

  Widget _buildView(AsyncValue<List<CaseFull>> cases, AsyncValue<List<CaseFull>> openCasesBeforeStartDate) {
    if (cases.value != null && openCasesBeforeStartDate.value != null) {
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
          return SingleChildScrollView(
            child: Column(
                children: <Widget>[
                  _buildHeaderButtons(),
                  const SizedBox(height: 20.0,),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: SfDataGridTheme(
                        data: SfDataGridThemeData(headerColor: Colors.blueAccent),
                        child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: _buildDataGrid()
                        )
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
            ),
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
        _patientsAtBeginning = 'Patients at beginning';
        _exportXLS = 'Export XLS';
        _exportPDF = 'Export PDF';
        _total = 'Total Locations';
        _contracts = 'Diagnosis';
        _start = 'Start';
        _end = 'End';
        break;
      case 'es_ES':
        _category = 'Categoría';
        _patientsAtBeginning = 'Pacientes al comienzo';
        _exportXLS = 'Exportar XLS';
        _exportPDF = 'Exportar PDF';
        _total = 'Totales';
        _contracts = 'Diagnósticos';
        _start = 'Inicio';
        _end = 'Fin';
        break;
      case 'fr_FR':
        _category = 'Catégorie';
        _patientsAtBeginning = 'Patients au début';
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
            columnName: 'Categoría',
            width: columnWidths['Categoría']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _category,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Pacientes al inicio',
            width: columnWidths['Pacientes al inicio']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _patientsAtBeginning,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Nuevos casos',
            width: columnWidths['Nuevos casos']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _newAdmissions,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Readmisiones',
            width: columnWidths['Readmisiones']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _reAdmissions,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Referidos',
            width: columnWidths['Referidos']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _referred,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Transferidos',
            width: columnWidths['Transferidos']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _transfered,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'TOTAL ADMISIONES',
            width: columnWidths['TOTAL ADMISIONES']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _totalAdmissions,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'TOTAL ATENDIDOS/AS',
            width: columnWidths['TOTAL ATENDIDOS/AS']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _totalAttended,
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
    mainInformDataGridSource = AdmissionsAndDischargesDataGridSource(List.empty());

    selectedLocale = model.locale.toString();

    _category = 'Categoría';
    _patientsAtBeginning = 'Pacientes al inicio';
    _newAdmissions = 'Nuevos casos';
    _reAdmissions = 'Readmisiones';
    _referred = 'Referidos';
    _transfered = 'Transferidos';
    _totalAdmissions = 'TOTAL ADMISIONES';
    _totalAttended = 'TOTAL ATENDIDOS/AS';
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

          final locationFilter = Tuple2(countrySelected?.countryId??"", regionSelected?.regionId??"");
          final locationsAsyncValue = ref.watch(locationsByCountryAndRegionStreamProvider(locationFilter));
          if (locationsAsyncValue.value != null) {
            _saveLocations(locationsAsyncValue);
          }

          final provinceFilter = Tuple3(
            countrySelected?.countryId??"",
            regionSelected?.regionId??"",
            locationSelected?.locationId??"",
          );
          final provincesAsyncValue = ref.watch(provincesByLocationStreamProvider(provinceFilter));
          if (provincesAsyncValue.value != null) {
            _saveProvinces(provincesAsyncValue);
          }

          final pointFilter = Tuple5(
              countrySelected?.countryId??"",
              regionSelected?.regionId??"",
              locationSelected?.locationId??"",
              provinceSelected?.provinceId??"",
              pointTypeSelected??"",
          );
          final pointsAsyncValue = ref.watch(pointsByLocationStreamProvider(pointFilter));
          if (pointsAsyncValue.value != null) {
            _savePoints(pointsAsyncValue);
          }

          final casesFilters = Tuple8(
              start,
              end,
              countrySelected?.countryId??"",
              regionSelected?.regionId??"",
              locationSelected?.locationId??"",
              provinceSelected?.provinceId??"",
              pointTypeSelected??"",
              pointSelected?.pointId??"",
          );
          casesAsyncValue = ref.watch(casesByDateAndLocationStreamProvider(casesFilters));

          final openCasesFilters = Tuple7(
            start,
            countrySelected?.countryId??"",
            regionSelected?.regionId??"",
            locationSelected?.locationId??"",
            provinceSelected?.provinceId??"",
            pointTypeSelected??"",
            pointSelected?.pointId??"",
          );
          openCasesBeforeStartDateAsyncValue = ref.watch(openCasesBeforeStartDateStreamProvider(openCasesFilters));

          if (casesAsyncValue.value != null && openCasesBeforeStartDateAsyncValue.value != null) {
            _saveMainInforms(casesAsyncValue, openCasesBeforeStartDateAsyncValue);
          }

          return _buildView(casesAsyncValue, openCasesBeforeStartDateAsyncValue);
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
        _buildLocationPicker(),
        _buildProvincePicker(),
        _buildPointTypePicker(),
        _buildPointPicker(),
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
                          locationSelected = null;
                          provinceSelected = null;
                          pointSelected = null;
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
                          locationSelected = null;
                          provinceSelected = null;
                          pointSelected = null;
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

  Widget _buildLocationPicker() {
    switch (model.locale.toString()) {
      case 'es_ES':
        _selectLocation = 'Selecciona una provincia';
        break;
      case 'fr_FR':
        _selectLocation = 'Sélectionnez une province';
        break;
      default:
        _selectLocation = 'Select province';
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
                      value: locationSelected?.name,
                      hint: Text(_selectLocation),
                      items: locations.map((Location l) {
                        return DropdownMenuItem<String>(
                            value: l.name,
                            child: Text(l.name,
                                style: TextStyle(color: model.textColor)));
                      }).toList(),
                      onChanged: (dynamic value) {
                        setState(() {
                          locationSelected = locations.firstWhere((l) => l.name == value);
                          provinceSelected = null;
                          pointSelected = null;
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

  Widget _buildProvincePicker() {
    switch (model.locale.toString()) {
      case 'es_ES':
        _selectProvince = 'Selecciona un municipio';
        break;
      case 'fr_FR':
        _selectProvince = 'Sélectionnez une municipalité';
        break;
      default:
        _selectProvince = 'Select municipality';
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
                      value: provinceSelected?.name,
                      hint: Text(_selectProvince),
                      items: provinces.map((Province p) {
                        return DropdownMenuItem<String>(
                            value: p.name,
                            child: Text(p.name,
                                style: TextStyle(color: model.textColor)));
                      }).toList(),
                      onChanged: (dynamic value) {
                        setState(() {
                          provinceSelected = provinces.firstWhere((p) => p.name == value);
                          pointSelected = null;
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

  Widget _buildPointTypePicker() {
    switch (model.locale.toString()) {
      case 'es_ES':
        _selectPointType = 'Selecciona un tipo de centro';
        break;
      case 'fr_FR':
        _selectPointType = 'Sélectionnez un type de centre';
        break;
      default:
        _selectPointType = 'Select type of centre';
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
                      value: pointTypeSelected,
                      hint: Text(_selectPointType),
                      items: pointTypes.map((String p) {
                        return DropdownMenuItem<String>(
                            value: p,
                            child: Text(p,
                                style: TextStyle(color: model.textColor)));
                      }).toList(),
                      onChanged: (dynamic value) {
                        setState(() {
                          pointTypeSelected = value;
                          pointSelected = null;
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

  Widget _buildPointPicker() {
    switch (model.locale.toString()) {
      case 'es_ES':
        _selectPoint = 'Selecciona un punto';
        break;
      case 'fr_FR':
        _selectPoint = 'Sélectionnez un place';
        break;
      default:
        _selectPoint = 'Select point';
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
                      value: pointSelected?.name,
                      hint: Text(_selectPoint),
                      items: points.map((Point p) {
                        return DropdownMenuItem<String>(
                            value: p.name,
                            child: Text(p.name,
                                style: TextStyle(color: model.textColor)));
                      }).toList(),
                      onChanged: (dynamic value) {
                        setState(() {
                          pointSelected = points.firstWhere((p) => p.name == value);
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



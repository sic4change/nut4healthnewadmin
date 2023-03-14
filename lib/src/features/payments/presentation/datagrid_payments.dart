/// Package imports
/// import 'package:flutter/foundation.dart';


import 'package:adminnut4health/src/features/payments/presentation/payment_datagridsource.dart';
import 'package:adminnut4health/src/features/payments/presentation/payments_screen_controller.dart';
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

import 'package:file_picker/file_picker.dart';
import 'dart:html' show FileReader;

import '../../../common_widgets/export/save_file_mobile.dart'
  if (dart.library.html) '../../../common_widgets/export/save_file_web.dart' as helper;

import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../domain/PaymentWithScreenerAndContract.dart';


/// Render payment data grid
class PaymentDataGrid extends LocalizationSampleView {
  /// Creates getting started data grid
  const PaymentDataGrid({Key? key}) : super(key: key);

  @override
  _PaymentDataGridState createState() => _PaymentDataGridState();
}

class _PaymentDataGridState extends LocalizationSampleViewState {

  final GlobalKey<SfDataGridState> _key = GlobalKey<SfDataGridState>();

  /// DataGridSource required for SfDataGrid to obtain the row data.
  late PaymentDataGridSource paymentDataGridSource;

  static const double dataPagerHeight = 60;
  int _rowsPerPage = 15;

  /// Selected locale
  late String selectedLocale;

  /// Translate names
  late String _id, _date, _screenerName, _screenerDPI, _screenerEmail, _screenerPhone,
      _quantity, _childName, _childAddress, _status, _type, _exportXLS, _exportPDF,
      _total, _payments
  ;

  late Map<String, double> columnWidths = {
    'Id': 150,
    'Fecha': 150,
    'Nombre Agente Salud': 150,
    'DNI/DPI Agente Salud': 150,
    'Email Agente Salud': 150,
    'Teléfono Agente Salud': 150,
    'Cantidad': 150,
    'Nombre Menor': 150,
    'Dirección Menor': 150,
    'Estado': 150,
    'Tipo': 150,
  };

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

  _savePayments(AsyncValue<List<PaymentWithScreener>>? payments) {
    if (payments == null) {
      paymentDataGridSource.setPayments(List.empty());
    } else {
      paymentDataGridSource.setPayments(payments.value!);
    }
  }

  Widget _buildView(AsyncValue<List<PaymentWithScreener>> payments) {
    if (payments.value != null && payments.value!.isNotEmpty) {
      paymentDataGridSource.buildDataGridRows();
      paymentDataGridSource.updateDataSource();
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

  Future<String> readBlob(Blob blob) async {
    final reader = FileReader();
    reader.readAsText(blob);
    await reader.onLoad.first;
    return reader.result as String;
  }


  Widget _buildHeaderButtons() {
    Future<void> exportDataGridToExcel() async {
      final Workbook workbook = _key.currentState!.exportToExcelWorkbook(
          excludeColumns: ['Id', 'Nombre Menor', 'Dirección Menor'],
          cellExport: (DataGridCellExcelExportDetails details) {

          });
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();
      await helper.FileSaveHelper.saveAndLaunchFile(bytes, '$_payments.xlsx');
    }

    Future<void> exportDataGridToPdf() async {
      final ByteData data = await rootBundle.load('images/nut_logo.jpg');
      final PdfDocument document = _key.currentState!.exportToPdfDocument(
          fitAllColumnsInOnePage: true,
          excludeColumns: ['Id', 'Nombre Menor', 'Dirección Menor'],
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

            header.graphics.drawString(_payments,
              PdfStandardFont(PdfFontFamily.helvetica, 13,
                  style: PdfFontStyle.bold),
              bounds: const Rect.fromLTWH(0, 25, 200, 60),
            );

            details.pdfDocumentTemplate.top = header;
          });
      final List<int> bytes = document.saveSync();
      await helper.FileSaveHelper.saveAndLaunchFile(bytes, '$_payments.pdf');
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
    var addMorePage = 0;
    if ((paymentDataGridSource.rows.length / _rowsPerPage).remainder(1) != 0) {
      addMorePage  = 1;
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SfDataPager(
          delegate: paymentDataGridSource,
          availableRowsPerPage: const <int>[15, 20, 25],
          pageCount: (paymentDataGridSource.rows.length / _rowsPerPage) + addMorePage,
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
                columnName: 'Id',
                summaryType: GridSummaryType.count),
          ],
          position: GridTableSummaryRowPosition.bottom),
    ];
  }

  SfDataGrid _buildDataGrid() {
    final selectedLocale = model.locale.toString();
    switch (selectedLocale) {
      case 'en_US':
        _id = 'Id';
        _date = 'Date';
        _screenerName = 'Health Agent Name';
        _screenerDPI = 'Health Agent ID';
        _screenerEmail = 'Health Agent Email';
        _screenerPhone = 'Health Agent Phone';
        _quantity = 'Quantity';
        _childName = 'Child Name';
        _childAddress = 'Child Address';
        _status = 'Status';
        _type = 'Type';
        _payments = 'Payments';
        _exportXLS = 'Export XLS';
        _exportPDF = 'Export PDF';
        _total = 'Total Diagnosis';
        break;
      case 'es_ES':
        _id = 'Id';
        _date = 'Fecha';
        _screenerName = 'Nombre Agente de Salud';
        _screenerDPI = 'DNI/DPI Agente Salud';
        _screenerEmail = 'Email Agente Salud';
        _screenerPhone = 'Teléfono Agente Salud';
        _quantity = 'Cantidad';
        _childName = 'Nombre Menor';
        _childAddress = 'Dirección Menor';
        _status = 'Estado';
        _type = 'Tipo';
        _payments = 'Pagos';
        _exportXLS = 'Exportar XLS';
        _exportPDF = 'Exportar PDF';
        _total = 'Diagnósticos totale';
        break;
      case 'fr_FR':
        _id = 'Identifiant';
        _date = 'Date';
        _screenerName = 'Nom de l\'agent de santé';
        _screenerDPI = 'Identifiant de l\'agent de santé';
        _screenerEmail = 'Email de l\'agent de santé';
        _screenerPhone = 'Téléphone de l\'agent de santé';
        _quantity = 'Quantité';
        _childName = 'Nom de l\'enfant';
        _childAddress = 'Adresse de l\'enfant';
        _status = 'Statut';
        _type = 'Type';
        _payments = 'Paiements';
        _exportXLS = 'Exporter XLS';
        _exportPDF = 'Exporter PDF';
        _total = 'Total des diagnostics';

        break;
    }
    return SfDataGrid(
      key: _key,
      source: paymentDataGridSource,
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
      allowSorting: true,
      allowMultiColumnSorting: true,
      columns: <GridColumn>[
        GridColumn(
            width: columnWidths['Id']!,
            columnName: 'Id',
            visible: false,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _id,
                overflow: TextOverflow.ellipsis,
              ),
            )),
        GridColumn(
          columnName: 'Estado',
          width: columnWidths['Estado']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _status.toString(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
          columnName: 'Tipo',
          width: columnWidths['Tipo']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _type.toString(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
          columnName: 'Nombre Agente Salud',
          width: columnWidths['Nombre Agente Salud']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _screenerName,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
          columnName: 'DNI/DPI Agente Salud',
          width: columnWidths['DNI/DPI Agente Salud']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _screenerDPI,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
          columnName: 'Email Agente Salud',
          width: columnWidths['Email Agente Salud']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _screenerEmail.toString(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        GridColumn(
          columnName: 'Teléfono Agente Salud',
          width: columnWidths['Teléfono Agente Salud']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _screenerPhone.toString(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
            columnName: 'Fecha',
            width: columnWidths['Fecha']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _date,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Cantidad',
            width: columnWidths['Cantidad']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _quantity,
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
    paymentDataGridSource = PaymentDataGridSource(List.empty());
    selectedLocale = model.locale.toString();
    _id = 'Id';
    _date = 'Fecha';
    _screenerName = 'Nombre Agente de Salud';
    _screenerDPI = 'DNI/DPI Agente Salud';
    _screenerEmail = 'Email Agente Salud';
    _screenerPhone = 'Teléfono Agente Salud';
    _quantity = 'Cantidad';
    _childName = 'Nombre Menor';
    _childAddress = 'Dirección Menor';
    _status = 'Estado';
    _type = 'Tipo';
    _payments = 'Pagos';
    _exportXLS = 'Exportar XLS';
    _exportPDF = 'Exportar PDF';
    _total = 'Diagnósticos totale';
    _exportXLS = 'Exportar XLS';
    _exportPDF = 'Exportar PDF';
    _total = 'Diagnósticos totales';
    _date = 'Fecha';
  }

  @override
  Widget buildSample(BuildContext context) {
    return Consumer(
        builder: (context, ref, child) {
          ref.listen<AsyncValue>(
            paymentsScreenControllerProvider,
                (_, state) => {
            },
          );
          final paymentsAsyncValue = ref.watch(paymentsStreamProvider);
          if (paymentsAsyncValue.value != null) {
            _savePayments(paymentsAsyncValue);
          }
          return _buildView(paymentsAsyncValue);
        });
  }

}



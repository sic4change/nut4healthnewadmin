/// Package imports
/// import 'package:flutter/foundation.dart';


import 'package:adminnut4health/src/features/payments/domain/payment.dart';
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
import '../../authentication/data/firebase_auth_repository.dart';
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

  var currentUserRole = "";

  /// Translate names
  late String _id, _date, _screenerName, _screenerDPI, _screenerEmail, _screenerPhone,
      _quantity, _childName, _childAddress, _status, _type, _exportXLS, _exportPDF,
      _total, _payments,  _save, _cancel, _editPayment;

  /// Editing controller for forms to perform update the values.
  TextEditingController?
      statusController;

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
        _cancel = 'Cancel';
        _save = 'Save';
        _editPayment = 'Edit';
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
        _cancel = 'Cancelar';
        _save = 'Guardar';
        _editPayment = 'Editar';
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
        _cancel = 'Annuler';
        _save = 'Enregistrer';
        _editPayment = 'Modifier';
        break;
    }
    return SfDataGrid(
      key: _key,
      source: paymentDataGridSource,
      rowsPerPage: _rowsPerPage,
      tableSummaryRows: _getTableSummaryRows(),
      allowSwiping: currentUserRole == 'super-admin' ? true : false,
      startSwipeActionsBuilder: _buildStartSwipeWidget,
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
              _editPayment,
              style: TextStyle(color: Colors.white, fontSize: 12),
            )
          ],
        ),
      ),
    );
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

  /// Updating the DataGridRows after changing the value and notify the DataGrid
  /// to refresh the view
  void _processCellUpdate(DataGridRow row, BuildContext buildContext) {
    final Payment? payment = paymentDataGridSource.getPayments()?.firstWhere((element) => element.payment.paymentId == row.getCells()[0].value).payment;
    if (_formKey.currentState!.validate()) {
      ref.read(paymentsScreenControllerProvider.notifier).updatePayment(
          Payment(paymentId: payment!.paymentId,
              status: statusController!.text,
              type: payment!.type,
              creationDate: payment!.creationDate,
              screenerId:payment!.screenerId
          )
      );
      Navigator.pop(buildContext);
    }
  }

  /// Building the forms to edit the data
  Widget _buildAlertDialogContent() {
    final statusOptions = ["CREATED", "PAID", "CANCELLED"];
    return Column(
      children: <Widget>[
        _buildRowComboSelection(controller: statusController!, columnName: 'Estado',
            dropDownMenuItems: statusOptions, text: _status),
      ],
    );
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

  // Updating the data to the TextEditingController
  void _updateTextFieldContext(DataGridRow row) {
    final String? status = row
        .getCells()
        .firstWhere(
          (DataGridCell element) => element.columnName == 'Estado',
    )
        ?.value
        .toString();

    statusController!.text = status ?? '';


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
        title: Text(_editPayment),
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

  @override
  void initState() {
    super.initState();
    statusController = TextEditingController();
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
    _cancel = 'Cancelar';
    _save = 'Guardar';
    _editPayment = 'Edit';
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
          final paymentsAsyncValue = ref.watch(paymentsStreamProvider);
          if (paymentsAsyncValue.value != null) {
            _savePayments(paymentsAsyncValue);
          }
          return _buildView(paymentsAsyncValue);
        });
  }

}



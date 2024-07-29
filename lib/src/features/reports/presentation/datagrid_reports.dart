/// Package imports
/// import 'package:flutter/foundation.dart';


import 'package:adminnut4health/src/features/reports/domain/reportWithUser.dart';
import 'package:adminnut4health/src/utils/functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Barcode import
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../../sample/model/sample_view.dart';
import '../../authentication/data/firebase_auth_repository.dart';
import '../data/firestore_repository.dart';
/// Local import
import '../domain/report.dart';
import 'reports_screen_controller.dart';
import 'report_datagridsource.dart';

import '../../../common_widgets/export/save_file_mobile.dart'
if (dart.library.html) '../../../common_widgets/export/save_file_web.dart' as helper;

import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Render report data grid
class ReportDataGrid extends LocalizationSampleView {
  /// Creates getting started data grid
  const ReportDataGrid({Key? key}) : super(key: key);

  @override
  _ReportDataGridState createState() => _ReportDataGridState();
}

class _ReportDataGridState extends LocalizationSampleViewState {

  final GlobalKey<SfDataGridState> _key = GlobalKey<SfDataGridState>();

  /// DataGridSource required for SfDataGrid to obtain the row data.
  late ReportDataGridSource reportDataGridSource;

  static const double dataPagerHeight = 60;
  int _rowsPerPage = 15;

  /// Selected locale
  late String selectedLocale;

  late String currentUserEmail;
  String currentUserRole = "";

  /// Translate names
  late String _date, _name, _surnames, _email, _text, _response, _updatedby,
      _lastupdate,  _exportXLS, _exportPDF, _total, _editReport, _removeReport,
      _save, _cancel, _reports, _removedReport, _id, _userId;

  late Map<String, double> columnWidths = {
    'Fecha': 150,
    'Nombre': 150,
    'Apellidos': 150,
    'Email': 150,
    'Mensaje': 300,
    'Respuesta': 150,
    'Respondido por': 150,
    'Fecha respuesta': 150,
    'ID': 200,
    'Usuario ID': 200,
  };

  /// Editing controller for forms to perform update the values.
  TextEditingController? responseController;

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

  _saveReports(AsyncValue<List<ReportWithUser>>? reports) {
    if (reports == null) {
      reportDataGridSource.setReports(List.empty());
    } else {
      reportDataGridSource.setReports(reports.value);
    }
  }

  Widget _buildView(AsyncValue<List<ReportWithUser>> reports) {
    if (reports.value != null && reports.value!.isNotEmpty) {
      reportDataGridSource.buildDataGridRows();
      reportDataGridSource.updateDataSource();
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

  Widget _buildHeaderButtons() {
    Future<void> exportDataGridToExcel() async {
      final Workbook workbook = _key.currentState!.exportToExcelWorkbook(
          excludeColumns: ['Nombre', 'Apellidos'],
          cellExport: (DataGridCellExcelExportDetails details) {

          });
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();
      await helper.FileSaveHelper.saveAndLaunchFile(bytes, '$_reports.xlsx');
    }

    Future<void> exportDataGridToPdf() async {
      exportDataGridToPdfStandard(
        dataGridState: _key.currentState!,
        title: _reports,
        excludeColumns: ['ID', 'Usuario ID', 'Nombre', 'Apellidos'],
      );
    }

    if (currentUserRole == 'super-admin') {
      return Row(
        children: <Widget>[
          _buildPDFExportingButton(_exportPDF, onPressed: exportDataGridToPdf),
          _buildExcelExportingButton(_exportXLS, onPressed: exportDataGridToExcel),
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
    var rows = reportDataGridSource.rows;
    if (reportDataGridSource.effectiveRows.isNotEmpty ) {
      rows = reportDataGridSource.effectiveRows;
    }
    var addMorePage = 0;
    if ((rows.length / _rowsPerPage).remainder(1) != 0) {
      addMorePage  = 1;
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SfDataPager(
        delegate: reportDataGridSource,
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
    return Column(
      children: <Widget>[
        _buildRow(controller: responseController!, columnName: 'Respuesta', text: _response),
      ],
    );
  }

  // Updating the data to the TextEditingController
  void _updateTextFieldContext(DataGridRow row) {
    final String? response = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'Respuesta')
        ?.value
        .toString();

    responseController!.text = response ?? '';
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
        title: Text(_editReport),
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

  /// Updating the DataGridRows after changing the value and notify the DataGrid
  /// to refresh the view
  void _processCellUpdate(DataGridRow row, BuildContext buildContext) {
    final Report? report = reportDataGridSource.getReports()?.firstWhere((element) => element.report.reportId == row.getCells()[0].value).report;
    if (_formKey.currentState!.validate()) {
      ref.read(reportsScreenControllerProvider.notifier).updateReport(
          Report(
            reportId: report!.reportId,
            date: report.date,
            user: report.user,
            email: report.email,
            text: report.text,
            sent: report.sent,
            response: responseController!.text,
            updatedby: currentUserEmail,
            lastupdate: DateTime.now(),
          )
      );
      Navigator.pop(buildContext);
    }
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
    final report = reportDataGridSource.getReports()?.firstWhere((element) => element.report.reportId == row.getCells()[0].value);
    if (report != null) {
      ref.read(reportsScreenControllerProvider.notifier).deleteReport(report.report);
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
        content: Text(_removedReport),
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
              _editReport,
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
              _removeReport,
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
        _date = 'Date';
        _name = 'Name';
        _surnames = 'Surnames';
        _email = 'Email';
        _text = 'Text';
        _response = 'Response';
        _updatedby = 'Answered by';
        _lastupdate = 'Answer date';
        _id = 'ID';
        _userId = 'User ID';

        _exportXLS = 'Export XLS';
        _exportPDF = 'Export PDF';
        _total = 'Total Reports';
        _editReport = 'Edit';
        _removeReport = 'Remove';
        _cancel = 'Cancel';
        _save = 'Save';
        _reports = 'Reports';
        _removedReport = 'Report deleted successfully.';
        break;
      case 'es_ES':
        _date = 'Fecha';
        _name = 'Nombre';
        _surnames = 'Apellidos';
        _email = 'Email';
        _text = 'Mensaje';
        _response = 'Respuesta';
        _updatedby = 'Respondido por';
        _lastupdate = 'Fecha respuesta';
        _id = 'ID';
        _userId = 'Usuario ID';

        _exportXLS = 'Exportar XLS';
        _exportPDF = 'Exportar PDF';
        _total = 'Reportes totales';
        _editReport = 'Editar';
        _removeReport = 'Eliminar';
        _cancel = 'Cancelar';
        _save = 'Guardar';
        _reports = 'Reportes';
        _removedReport = 'Reporte eliminado correctamente.';
        break;
      case 'fr_FR':
        _date = 'Date';
        _name = 'Nom';
        _surnames = 'Noms de famille';
        _email = 'Email';
        _text = 'Message';
        _response = 'Répondu par';
        _lastupdate = 'Date de réponse';
        _id = 'ID';
        _userId = 'Utilisateur ID';

        _exportXLS = 'Exporter XLS';
        _exportPDF = 'Exporter PDF';
        _total = 'Total des rapports';
        _editReport = 'Modifier';
        _removeReport = 'Supprimer';
        _cancel = 'Annuler';
        _save = 'Enregistrer';
        _reports = 'Rapports';
        _removedReport = 'Rapport supprimé avec succès.';
        break;
    }

    return SfDataGrid(
      key: _key,
      source: reportDataGridSource,
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
            columnName: 'Fecha',
            width: columnWidths['Fecha']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _date,
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
            columnName: 'Apellidos',
            width: columnWidths['Apellidos']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _surnames,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Email',
            width: columnWidths['Email']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _email,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Mensaje',
            width: columnWidths['Mensaje']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _text,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Respuesta',
            width: columnWidths['Respuesta']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _response,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Respondido por',
            width: columnWidths['Respondido por']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _updatedby,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Fecha respuesta',
            width: columnWidths['Fecha respuesta']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _lastupdate,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'ID',
            width: columnWidths['ID']!,
            visible: false,
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
            columnName: 'Usuario ID',
            width: columnWidths['Usuario ID']!,
            visible: false,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _userId,
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
    reportDataGridSource = ReportDataGridSource(List.empty());
    responseController = TextEditingController();
    selectedLocale = model.locale.toString();

    _date = 'Fecha';
    _name = 'Nombre';
    _surnames = 'Apellidos';
    _email = 'Email';
    _text = 'Mensaje';
    _response = 'Respuesta';
    _id = 'ID';
    _userId = 'Usuario ID';

    _updatedby = 'Respondido por';
    _lastupdate = 'Fecha respuesta';
    _exportXLS = 'Exportar XLS';
    _exportPDF = 'Exportar PDF';
    _total = 'Usuarios totales';
    _editReport = 'Editar';
    _removeReport = 'Eliminar';
    _cancel = 'Cancelar';
    _save = 'Guardar';
    _reports = 'Reportes';
    _removedReport = '';
  }


  @override
  Widget buildSample(BuildContext context) {
    return Consumer(
        builder: (context, ref, child) {
          ref.listen<AsyncValue>(
            reportsScreenControllerProvider,
                (_, state) => {
            },
          );
          final user = ref.watch(authRepositoryProvider).currentUser;
          if (user != null && user.metadata.lastSignInTime != null) {
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

            currentUserEmail = user.email??"";
          }
          final reportsAsyncValue = ref.watch(reportsStreamProvider);
          if (reportsAsyncValue.value != null) {
            _saveReports(reportsAsyncValue);
          }
          return _buildView(reportsAsyncValue);
        });
  }

}



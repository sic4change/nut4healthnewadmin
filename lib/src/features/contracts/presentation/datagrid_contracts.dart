/// Package imports
/// import 'package:flutter/foundation.dart';


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
import '../domain/ContractWithScreenerAndMedicalAndPoint.dart';
import 'contract_datagridsource.dart';

import 'package:file_picker/file_picker.dart';
import 'dart:html' show FileReader;

import '../../../common_widgets/export/save_file_mobile.dart'
  if (dart.library.html) '../../../common_widgets/export/save_file_web.dart' as helper;

import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'contracts_screen_controller.dart';

/// Render contract data grid
class ContractDataGrid extends LocalizationSampleView {
  /// Creates getting started data grid
  const ContractDataGrid({Key? key}) : super(key: key);

  @override
  _ContractDataGridState createState() => _ContractDataGridState();
}

class _ContractDataGridState extends LocalizationSampleViewState {

  final GlobalKey<SfDataGridState> _key = GlobalKey<SfDataGridState>();

  /// DataGridSource required for SfDataGrid to obtain the row data.
  late ContractDataGridSource contractDataGridSource;

  static const double dataPagerHeight = 60;
  int _rowsPerPage = 15;

  /// Selected locale
  late String selectedLocale;

  /// Translate names
  late String _id, _code, _status, _exportXLS, _exportPDF, _total, _contracts,
      _armCircunference, _armCircunferenceConfirmed, _weight, _height, _name,
      _surnames, _sex, _dni, _tutor, _contact, _address, _date, _point, _agent,
      _medical, _medicalDate, _smsSent, _duration, _desnutrition, _transactionHash,
      _transactionValidateHash;

  late Map<String, double> columnWidths = {
    'Id': 150,
    'Código': 150,
    'Estado': 150,
    'Desnutrición': 150,
    'Perímetro braquial (cm)': 150,
    'Perímetro braquial confirmado (cm)': 150,
    'Peso (kg)': 150,
    'Altura (cm)': 150,
    'Nombre': 150,
    'Apellidos': 150,
    'Sexo': 150,
    'Código Identificación': 150,
    'Madre, Padre o Tutor': 150,
    'Contacto': 150,
    'Lugar': 150,
    'Fecha': 150,
    'Puesto Salud': 150,
    'Agente Salud': 150,
    'Servicio Salud': 150,
    'Fecha Atención Médica': 150,
    'SMS Enviado': 150,
    'Duración': 150,
    'Hash transacción': 150,
    'Hash transacción validada': 150,
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

  _saveContracts(AsyncValue<List<ContractWithScreenerAndMedicalAndPoint>>? contracts) {
    if (contracts == null) {
      contractDataGridSource.setContracts(List.empty());
    } else {
      contractDataGridSource.setContracts(contracts.value!);
    }
  }

  Widget _buildView(AsyncValue<List<ContractWithScreenerAndMedicalAndPoint>> contracts) {
    if (contracts.value != null && contracts.value!.isNotEmpty) {
      contractDataGridSource.buildDataGridRows();
      contractDataGridSource.updateDataSource();
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
          excludeColumns: ['Id', 'Nombre', 'Apellidos', 'Lugar', 'Madre, Padre o Tutor', 'Contacto'],
          cellExport: (DataGridCellExcelExportDetails details) {

          });
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();
      await helper.FileSaveHelper.saveAndLaunchFile(bytes, '$_contracts.xlsx');
    }

    Future<void> exportDataGridToPdf() async {
      final ByteData data = await rootBundle.load('images/nut_logo.jpg');
      final PdfDocument document = _key.currentState!.exportToPdfDocument(
          fitAllColumnsInOnePage: true,
          excludeColumns: ['Id', 'Nombre', 'Apellidos', 'Lugar', 'Madre, Padre o Tutor', 'Contacto'],
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
    var rows = contractDataGridSource.rows;
    if (contractDataGridSource.effectiveRows.isNotEmpty ) {
      rows = contractDataGridSource.effectiveRows;
    }
    var addMorePage = 0;
    if ((rows.length / _rowsPerPage).remainder(1) != 0) {
      addMorePage  = 1;
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SfDataPager(
          delegate: contractDataGridSource,
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
        _code = 'Code';
        _status = 'Status';
        _armCircunference = 'Brachial circumference (cm)';
        _armCircunferenceConfirmed = 'Confirmed brachial circumference (cm)';
        _weight = 'Weight (kg)';
        _height = 'Height (cm)';
        _name = 'Name';
        _surnames = 'Surnames';
        _sex = 'Sex';
        _dni = 'Identification Code';
        _tutor = 'Mother, Father or Guardian';
        _contact = 'Contact';
        _address = 'Address';
        _exportXLS = 'Export XLS';
        _exportPDF = 'Export PDF';
        _total = 'Total Diagnosis';
        _contracts = 'Diagnosis';
        _date = 'Date';
        _point = 'Healthcare Position';
        _agent = 'Healthcare Agent';
        _medical = 'Healtcare Service';
        _medicalDate = 'Medical Appointment Date';
        _smsSent = 'SMS Sent';
        _duration = 'Duration';
        _desnutrition = 'Desnutrition';
        _transactionHash = 'Transaction Hash';
        _transactionValidateHash = 'Transaction validate Hash';
        break;
      case 'es_ES':
        _id = 'Id';
        _code = 'Código';
        _status = 'Estado';
        _armCircunference = 'Perímetro braquial (cm)';
        _armCircunferenceConfirmed = 'Perímetro braquial confirmado (cm)';
        _weight = 'Peso (kg)';
        _height = 'Altura (cm)';
        _name = 'Nombre';
        _surnames = 'Apellidos';
        _sex = 'Sexo';
        _dni = 'Código Identificación';
        _tutor = 'Madre, Padre o Tutor';
        _contact = 'Contacto';
        _address = 'Lugar';
        _exportXLS = 'Exportar XLS';
        _exportPDF = 'Exportar PDF';
        _total = 'Diagnósticos totale';
        _contracts = 'Diagnósticos';
        _date = 'Fecha';
        _point = 'Puesto Salud';
        _agent = 'Agente Salud';
        _medical = 'Servicio Salud';
        _medicalDate = 'Fecha Atención Médica';
        _smsSent = 'SMS Enviado';
        _duration = 'Duración';
        _desnutrition = 'Desnutrición';
        _transactionHash = 'Hash transacción';
        _transactionValidateHash = 'Hash transacción validada';
        break;
      case 'fr_FR':
        _id = 'Identifiant';
        _code = 'Code';
        _status = 'Statut';
        _armCircunference = 'Circonférence brachiale (cm)';
        _armCircunferenceConfirmed = 'Circonférence brachiale confirme (cm)';
        _weight = 'Poids (kg)';
        _height = 'Taille (cm)';
        _name = 'Nom';
        _surnames = 'Nom de famille';
        _sex = 'Sexe';
        _dni = 'Code identification';
        _tutor = 'Mère, père ou tuteur';
        _contact = 'Contact';
        _address = 'Adresse';
        _exportXLS = 'Exporter XLS';
        _exportPDF = 'Exporter PDF';
        _total = 'Total des diagnostics';
        _contracts = 'Diagnostics';
        _date = 'Date';
        _point = 'Poste de santé';
        _agent = 'Agent de santé';
        _medical = 'Servicio de santé';
        _medicalDate = 'Date de consultation médicale';
        _smsSent = 'SMS envoyé';
        _duration = 'Durée';
        _desnutrition = 'Désnutrition';
        _transactionHash = 'Hachage de transaction';
        _transactionValidateHash = 'Hachage de transaction validé';
        break;
    }
    return SfDataGrid(
      key: _key,
      source: contractDataGridSource,
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
          columnName: 'Código',
            width: columnWidths['Código']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _code,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ),
        GridColumn(
          columnName: 'Estado',
          width: columnWidths['Estado']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _status,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
          columnName: 'Desnutrición',
          width: columnWidths['Desnutrición']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _desnutrition,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
          columnName: 'Perímetro braquial (cm)',
          width: columnWidths['Perímetro braquial (cm)']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _armCircunference.toString(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        GridColumn(
          columnName: 'Perímetro braquial confirmado (cm)',
          width: columnWidths['Perímetro braquial confirmado (cm)']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _armCircunferenceConfirmed.toString(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
          columnName: 'Peso (kg)',
          width: columnWidths['Peso (kg)']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _weight.toString(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
          columnName: 'Altura (cm)',
          width: columnWidths['Altura (cm)']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _height.toString(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        GridColumn(
          columnName: 'Nombre',
          width: columnWidths['Nombre']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _name.toString(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
          columnName: 'Apellidos',
          width: columnWidths['Apellidos']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _surnames.toString(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
          columnName: 'Sexo',
          width: columnWidths['Sexo']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _sex.toString(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
          columnName: 'Código Identificación',
          width: columnWidths['Código Identificación']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _dni.toString(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
          columnName: 'Madre, Padre o Tutor',
          width: columnWidths['Madre, Padre o Tutor']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _tutor.toString(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
          columnName: 'Contacto',
          width: columnWidths['Contacto']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _contact.toString(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
          columnName: 'Lugar',
          width: columnWidths['Lugar']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _address.toString(),
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
              _date.toString(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
          columnName: 'Puesto Salud',
          width: columnWidths['Puesto Salud']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _point.toString(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
          columnName: 'Agente Salud',
          width: columnWidths['Agente Salud']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _agent.toString(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        GridColumn(
          columnName: 'Servicio Salud',
          width: columnWidths['Servicio Salud']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _medical.toString(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        GridColumn(
          columnName: 'Fecha Atención Médica',
          width: columnWidths['Fecha Atención Médica']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _medicalDate.toString(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
          columnName: 'SMS Enviado',
          width: columnWidths['SMS Enviado']!,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(
                _smsSent,
                overflow: TextOverflow.ellipsis,
              )),
        ),
        GridColumn(
          columnName: 'Duración',
          width: columnWidths['Duración']!,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(
                _duration,
                overflow: TextOverflow.ellipsis,
              )),
        ),
        GridColumn(
            columnName: 'Hash transacción',
            width: columnWidths['Hash transacción']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _transactionHash,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Hash transacción validada',
            width: columnWidths['Hash transacción validada']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _transactionValidateHash,
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
    contractDataGridSource = ContractDataGridSource(List.empty());

    selectedLocale = model.locale.toString();

    _id = 'Id';
    _code = 'Código';
    _contracts = 'Diagnosis';
    _status = 'Estado';
    _armCircunference = 'Perímetro braquial (cm)';
    _armCircunferenceConfirmed = 'Perímetro braquial confirmado (cm)';
    _weight = 'Peso (kg)';
    _height = 'Altura (cm)';
    _name = 'Nombre';
    _surnames = 'Apellidos';
    _sex = 'Sexo';
    _dni = 'Código Identificación';
    _tutor = 'Madre, Padre o Tutor';
    _contact = 'Contacto';
    _address = 'Lugar';
    _exportXLS = 'Exportar XLS';
    _exportPDF = 'Exportar PDF';
    _total = 'Diagnósticos totales';
    _contracts = 'Diagnósticos';
    _date = 'Fecha';
    _point = 'Puesto Salud';
    _agent = 'Agente Salud';
    _medical = 'Servicio Salud';
    _medicalDate = 'Fecha Atención Médica';
    _smsSent = 'SMS Enviado';
    _duration = 'Duración';
    _desnutrition = 'Desnutrición';
    _transactionHash = 'Hash transacción';
    _transactionValidateHash = 'Hash transacción validada';
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
          final contractsAsyncValue = ref.watch(contractsStreamProvider);
          if (contractsAsyncValue.value != null) {
            _saveContracts(contractsAsyncValue);
          }
          return _buildView(contractsAsyncValue);
        });
  }

}



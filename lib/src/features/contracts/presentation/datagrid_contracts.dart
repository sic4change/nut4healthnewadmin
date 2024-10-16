/// Package imports
/// import 'package:flutter/foundation.dart';


import 'package:adminnut4health/src/features/authentication/data/firebase_auth_repository.dart';
import 'package:adminnut4health/src/features/contracts/domain/contract.dart';
import 'package:adminnut4health/src/features/users/data/firestore_repository.dart';
import 'package:adminnut4health/src/features/users/domain/user.dart';
import 'package:adminnut4health/src/utils/alert_dialogs.dart';
import 'package:adminnut4health/src/utils/functions.dart';
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
  late String _chefValidation, _regionalValidation, _id, _code, _fefa, _status,
      _exportXLS, _exportPDF, _total, _contracts,
      _armCircunference, _armCircunferenceConfirmed, _weight, _height, _name,
      _surnames, _sex, _childBirthdate, _dni, _tutor, _tutorBirthdate, _tutorDNI,
      _tutorStatus, _weeks, _childMinor,
      _contact, _address, _date, _point, _agent,
      _medical, _medicalDate, _smsSent, _duration, _desnutrition, _transactionHash,
      _transactionValidateHash, _validateData, _medicalId, _screenerId, _pointId;

  late Map<String, double> columnWidths = {
    'Validación Médico Jefe': 150,
    'Validación Dirección Regional': 150,
    'ID': 150,
    'Código': 150,
    'FEFA': 150,
    'Estado': 150,
    'Desnutrición': 150,
    'Perímetro braquial (cm)': 150,
    'Perímetro braquial confirmado (cm)': 150,
    'Peso (kg)': 150,
    'Altura (cm)': 150,
    'Nombre': 150,
    'Apellidos': 150,
    'Sexo': 150,
    'Fecha nacimiento': 150,
    'Código Identificación': 150,
    'Madre, Padre o Tutor': 150,
    'Fecha nacimiento tutor': 150,
    'Código Identificación tutor': 150,
    'Estado tutor': 150,
    'Semanas embarazo': 150,
    'Hijo/a menor a 6 meses': 150,
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
    'Servicio Salud ID': 150,
    'Agente Salud ID': 150,
    'Punto ID': 150,
  };

  /// Used to validate the forms
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AsyncValue<List<ContractWithScreenerAndMedicalAndPoint>> contractsAsyncValue = AsyncValue.data(List.empty());
  List<String> pointsIds = List.empty();

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
      var contractsList = contracts.value!;
      if (pointsIds.isNotEmpty) {
        contractsList = contractsList.where((c) => pointsIds.contains(c.point!.pointId)).toList();
      }
      contractDataGridSource.setContracts(contractsList);
    }
  }

  Widget _buildView(AsyncValue<List<ContractWithScreenerAndMedicalAndPoint>> contracts) {
    if (contracts.value != null) {
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
          if (contractDataGridSource.getContracts()!.isEmpty) {
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
      final excludeColumns = ['Contacto', 'FEFA'];
      if (!User.showPersonalData()) {
        excludeColumns.addAll(['Nombre', 'Apellidos', 'Lugar', 'Madre, Padre o Tutor']);
      }
      if (User.currentRole != 'super-admin') {
        excludeColumns.addAll(['ID', 'Punto ID', 'Servicio Salud ID', 'Agente Salud ID']);
      }
      final Workbook workbook = _key.currentState!.exportToExcelWorkbook(
          excludeColumns: excludeColumns,
      );
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();
      await helper.FileSaveHelper.saveAndLaunchFile(bytes, '$_contracts.xlsx');
    }

    Future<void> exportDataGridToPdf() async {
      final excludeColumns = ['Contacto', 'FEFA', 'ID', 'Punto ID', 'Servicio Salud ID', 'Agente Salud ID'];
      if (!User.showPersonalData()) {
        excludeColumns.addAll(['Nombre', 'Apellidos', 'Lugar', 'Madre, Padre o Tutor']);
      }
      exportDataGridToPdfStandard(
        dataGridState: _key.currentState!,
        title: _contracts,
        excludeColumns: excludeColumns
      );
    }

    if (User.needValidation){
      return Row(
        children: <Widget>[
          _buildValidationButton(onPressed: () {
            showValidationDialog(
              context: context,
                selectedLocale: selectedLocale,
              onPressed: () {
                if (User.currentRole == 'medico-jefe') {
                  chefValidation();
                }

                if (User.currentRole == 'direccion-regional-salud') {
                  regionalValidation();
                }
              }
            );
          }),
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

  Widget _buildValidationButton({required VoidCallback onPressed}) {
    switch (selectedLocale) {
      case 'en_US':
        _validateData = 'VALIDATE DATA';
        break;
      case 'es_ES':
        _validateData = 'VALIDAR DATOS';
        break;
      case 'fr_FR':
        _validateData = 'VALIDER LES DONNÉES';
        break;
    }
    return Container(
        height: 60.0,
        padding: const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0),
        child: TextButton(
          onPressed: onPressed,
          child: Text(_validateData),)
    );
  }

  Future<void> chefValidation() async {
    final contracts = contractDataGridSource.getContracts()!.where((c) => !c.contract.chefValidation);
    for (var c in contracts) {
      ref.read(contractsScreenControllerProvider.notifier).updateContract(
          Contract(
            contractId: c.contract.contractId,
            status: c.contract.status,
            code: c.contract.code,
            isFEFA: c.contract.isFEFA,
            point: c.contract.point,
            screenerId: c.contract.screenerId,
            medicalId: c.contract.medicalId,
            armCircunference: c.contract.armCircunference,
            armCircumferenceMedical: c.contract.armCircumferenceMedical,
            weight: c.contract.weight,
            height: c.contract.height,
            childName: c.contract.childName,
            childSurname: c.contract.childSurname,
            sex: c.contract.sex,
            childBirthdate: c.contract.childBirthdate,
            childDNI: c.contract.childDNI,
            childTutor: c.contract.childTutor,
            tutorBirthdate: c.contract.tutorBirthdate,
            tutorDNI: c.contract.tutorDNI,
            tutorStatus: c.contract.tutorStatus,
            weeks: c.contract.weeks,
            childMinor: c.contract.childMinor,
            childPhoneContract: c.contract.childPhoneContract,
            childAddress: c.contract.childAddress,
            creationDate: c.contract.creationDate,
            medicalDate: c.contract.medicalDate,
            smsSent: c.contract.smsSent,
            duration: c.contract.duration,
            percentage: c.contract.percentage,
            transactionHash: c.contract.transactionHash,
            transactionValidateHash: c.contract.transactionValidateHash,
            chefValidation: true,
            regionalValidation: c.contract.regionalValidation,
          )
      );
    }}

  Future<void> regionalValidation() async {
    final contractsWithChefValidation = contractDataGridSource.getContracts()!.where((c) => c.contract.chefValidation && !c.contract.regionalValidation);
    for (var c in contractsWithChefValidation) {
      ref.read(contractsScreenControllerProvider.notifier).updateContract(
          Contract(
            contractId: c.contract.contractId,
            status: c.contract.status,
            code: c.contract.code,
            isFEFA: c.contract.isFEFA,
            point: c.contract.point,
            screenerId: c.contract.screenerId,
            medicalId: c.contract.medicalId,
            armCircunference: c.contract.armCircunference,
            armCircumferenceMedical: c.contract.armCircumferenceMedical,
            weight: c.contract.weight,
            height: c.contract.height,
            childName: c.contract.childName,
            childSurname: c.contract.childSurname,
            sex: c.contract.sex,
            childBirthdate: c.contract.childBirthdate,
            childDNI: c.contract.childDNI,
            childTutor: c.contract.childTutor,
            tutorBirthdate: c.contract.tutorBirthdate,
            tutorDNI: c.contract.tutorDNI,
            tutorStatus: c.contract.tutorStatus,
            weeks: c.contract.weeks,
            childMinor: c.contract.childMinor,
            childPhoneContract: c.contract.childPhoneContract,
            childAddress: c.contract.childAddress,
            creationDate: c.contract.creationDate,
            medicalDate: c.contract.medicalDate,
            smsSent: c.contract.smsSent,
            duration: c.contract.duration,
            percentage: c.contract.percentage,
            transactionHash: c.contract.transactionHash,
            transactionValidateHash: c.contract.transactionValidateHash,
            chefValidation: c.contract.chefValidation,
            regionalValidation: true,
          )
      );
    }}

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
                columnName: 'ID',
                summaryType: GridSummaryType.count),
          ],
          position: GridTableSummaryRowPosition.bottom),
    ];
  }

  SfDataGrid _buildDataGrid() {
    final selectedLocale = model.locale.toString();
    switch (selectedLocale) {
      case 'en_US':
        _chefValidation = 'Chef validation';
        _regionalValidation = 'Regional validation';
        _id = 'ID';
        _code = 'Code';
        _fefa = 'FEFA';
        _status = 'Status';
        _armCircunference = 'Brachial circumference (cm)';
        _armCircunferenceConfirmed = 'Confirmed brachial circumference (cm)';
        _weight = 'Weight (kg)';
        _height = 'Height (cm)';
        _name = 'Name';
        _surnames = 'Surnames';
        _sex = 'Sex';
        _childBirthdate = 'Birthdate';
        _dni = 'Identification Code';
        _tutor = 'Mother, Father or Guardian';
        _tutorBirthdate = 'Tutor Birthdate';
        _tutorDNI = 'Tutor Identification Code';
        _tutorStatus = 'Tutor Status';
        _weeks = 'Pregnancy Weeks';
        _childMinor = 'Child under 6 months';
        _contact = 'Contact';
        _address = 'Address';
        _exportXLS = 'Export XLS';
        _exportPDF = 'Export PDF';
        _total = 'Total Diagnosis';
        _contracts = 'Diagnosis';
        _date = 'Date';
        _point = 'Healthcare Position';
        _agent = 'Healthcare Agent';
        _medical = 'Healthcare Service';
        _medicalDate = 'Medical Appointment Date';
        _smsSent = 'SMS Sent';
        _duration = 'Duration';
        _desnutrition = 'Desnutrition';
        _transactionHash = 'Transaction Hash';
        _transactionValidateHash = 'Transaction validate Hash';
        _pointId = 'Point ID';
        _medicalId = 'Healthcare Service ID';
        _screenerId = 'Healthcare Agent ID';
        break;
      case 'es_ES':
        _chefValidation = 'Validación Médico Jefe';
        _regionalValidation = 'Validación Dirección Regional';
        _id = 'ID';
        _code = 'Código';
        _fefa = 'FEFA';
        _status = 'Estado';
        _armCircunference = 'Perímetro braquial (cm)';
        _armCircunferenceConfirmed = 'Perímetro braquial confirmado (cm)';
        _weight = 'Peso (kg)';
        _height = 'Altura (cm)';
        _name = 'Nombre';
        _surnames = 'Apellidos';
        _sex = 'Sexo';
        _childBirthdate = 'Fecha nacimiento';
        _dni = 'Código Identificación';
        _tutor = 'Madre, Padre o Tutor';
        _tutorBirthdate = 'Fecha nacimiento tutor';
        _tutorDNI = 'Código Identificación tutor';
        _tutorStatus = 'Estado tutor';
        _weeks = 'Semanas embarazo';
        _childMinor = 'Hijo/a menor a 6 meses';
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
        _pointId = 'Punto ID';
        _medicalId = 'Servicio Salud ID';
        _screenerId = 'Agente Salud ID';
        break;
      case 'fr_FR':
        _chefValidation = 'Validation du médecin-chef';
        _regionalValidation = 'Validation direction régionale de la santé';
        _id = 'Identifiant';
        _code = 'Code';
        _fefa = 'FEFA';
        _status = 'Statut';
        _armCircunference = 'Circonférence brachiale (cm)';
        _armCircunferenceConfirmed = 'Circonférence brachiale confirme (cm)';
        _weight = 'Poids (kg)';
        _height = 'Taille (cm)';
        _name = 'Nom';
        _surnames = 'Nom de famille';
        _sex = 'Sexe';
        _childBirthdate = 'Date de naissance';
        _dni = 'Code identification';
        _tutor = 'Mère, père ou tuteur';
        _tutorBirthdate = 'Date de naissance du tuteur';
        _tutorDNI = 'Code d\'identification du tuteur';
        _tutorStatus = 'Statut du tuteur';
        _weeks = 'Semaines de grossesse';
        _childMinor = 'Enfant de moins de 6 mois';
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
        _pointId = 'Place ID';
        _medicalId = 'Servicio de santé ID';
        _screenerId = 'Agent de santé ID';
        break;
    }
    return SfDataGrid(
      key: _key,
      source: contractDataGridSource,
      rowsPerPage: _rowsPerPage,
      allowEditing: true,
      tableSummaryRows: _getTableSummaryRows(),
      allowColumnsResizing: true,
      selectionMode: SelectionMode.single,
      navigationMode: GridNavigationMode.cell,
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
            columnName: 'Validación Médico Jefe',
            width: columnWidths['Validación Médico Jefe']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _chefValidation,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Validación Dirección Regional',
            width: columnWidths['Validación Dirección Regional']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _regionalValidation,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
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
            columnName: 'FEFA',
            width: columnWidths['FEFA']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _fefa,
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
          visible: User.showPersonalData(),
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
          visible: User.showPersonalData(),
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
          columnName: 'Fecha nacimiento',
          width: columnWidths['Fecha nacimiento']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _childBirthdate.toString(),
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
          visible: User.showPersonalData(),
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
          columnName: 'Fecha nacimiento tutor',
          width: columnWidths['Fecha nacimiento tutor']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _tutorBirthdate.toString(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
          columnName: 'Código Identificación tutor',
          width: columnWidths['Código Identificación tutor']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _tutorDNI.toString(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
          columnName: 'Estado tutor',
          width: columnWidths['Estado tutor']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _tutorStatus.toString(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
          columnName: 'Semanas embarazo',
          width: columnWidths['Semanas embarazo']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _weeks.toString(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
          columnName: 'Hijo/a menor a 6 meses',
          width: columnWidths['Hijo/a menor a 6 meses']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _childMinor.toString(),
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
          visible: User.showPersonalData(),
          columnName: 'Lugar',
          width: columnWidths['Lugar']!,
          allowEditing: true,
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
        GridColumn(
            width: columnWidths['ID']!,
            columnName: 'ID',
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
            width: columnWidths['Servicio Salud ID']!,
            columnName: 'Servicio Salud ID',
            visible: false,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _medicalId,
                overflow: TextOverflow.ellipsis,
              ),
            )),
        GridColumn(
            width: columnWidths['Agente Salud ID']!,
            columnName: 'Agente Salud ID',
            visible: false,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _screenerId,
                overflow: TextOverflow.ellipsis,
              ),
            )),
        GridColumn(
            width: columnWidths['Punto ID']!,
            columnName: 'Punto ID',
            visible: false,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _pointId,
                overflow: TextOverflow.ellipsis,
              ),
            )),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    contractDataGridSource = ContractDataGridSource(List.empty());

    selectedLocale = model.locale.toString();

    _chefValidation = 'Validación Médico Jefe';
    _regionalValidation = 'Validación Dirección Regional';
    _id = 'ID';
    _code = 'Código';
    _fefa = 'FEFA';
    _contracts = 'Diagnosis';
    _status = 'Estado';
    _armCircunference = 'Perímetro braquial (cm)';
    _armCircunferenceConfirmed = 'Perímetro braquial confirmado (cm)';
    _weight = 'Peso (kg)';
    _height = 'Altura (cm)';
    _name = 'Nombre';
    _surnames = 'Apellidos';
    _sex = 'Sexo';
    _childBirthdate = 'Fecha nacimiento';
    _dni = 'Código Identificación';
    _tutor = 'Madre, Padre o Tutor';
    _tutorBirthdate = 'Fecha nacimiento tutor';
    _tutorDNI = 'Código Identificación tutor';
    _tutorStatus = 'Estado tutor';
    _weeks = 'Semanas embarazo';
    _childMinor = 'Hijo/a menor a 6 meses';
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
    _validateData = 'VALIDAR DATOS';
    _medicalId = 'Servicio Salud ID';
    _screenerId = 'Agente Salud ID';
    _pointId = 'Punto ID';
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

          if (User.currentRole == 'medico-jefe') {
            final pointsAsyncValue = ref.watch(pointsByLocationStreamProvider);
            if (pointsAsyncValue.value != null) {
              final points = pointsAsyncValue.value!;
              if (pointsIds.isEmpty) {
                pointsIds = points.map((e) => e.pointId).toList();
              }
            }
          } else if (User.currentRole == 'direccion-regional-salud') {
            final pointsAsyncValue = ref.watch(pointsByRegionStreamProvider);
            if (pointsAsyncValue.value != null) {
              final points = pointsAsyncValue.value!;
              if (pointsIds.isEmpty) {
                pointsIds = points.map((e) => e.pointId).toList();
              }
            }
          }

          contractsAsyncValue = ref.watch(contractsStreamProvider);

          if (contractsAsyncValue.value != null) {
            _saveContracts(contractsAsyncValue);
          }

          return _buildView(contractsAsyncValue);
        });
  }

}



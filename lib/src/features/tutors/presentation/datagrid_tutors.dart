/// Package imports
/// import 'package:flutter/foundation.dart';

import 'package:adminnut4health/src/features/tutors/domain/tutorWithPoint.dart';
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
import '../domain/tutor.dart';
import 'tutors_screen_controller.dart';
import 'tutor_datagridsource.dart';

import '../../../common_widgets/export/save_file_mobile.dart'
if (dart.library.html) '../../../common_widgets/export/save_file_web.dart' as helper;

import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Render tutor data grid
class TutorDataGrid extends LocalizationSampleView {
  /// Creates getting started data grid
  const TutorDataGrid({Key? key}) : super(key: key);

  @override
  _TutorDataGridState createState() => _TutorDataGridState();
}

class _TutorDataGridState extends LocalizationSampleViewState {

  final GlobalKey<SfDataGridState> _key = GlobalKey<SfDataGridState>();

  /// DataGridSource required for SfDataGrid to obtain the row data.
  late TutorDataGridSource tutorDataGridSource;

  static const double dataPagerHeight = 60;
  int _rowsPerPage = 15;

  /// Selected locale
  late String selectedLocale;

  late String currentUserEmail;
  var currentUserRole = "";

  /// Translate names
  late String _point, _name, _surnames, _address, _phone, _birthdate, _lastDate,
      _ethnicity, _sex, _weight, _height, _status, _pregnant, _weeks,
      _childMinor, _observations, _active, _exportXLS, _exportPDF, _total,
      _editTutor, _removeTutor, _save, _cancel, _tutors, _removedTutor;

  late Map<String, double> columnWidths = {
    'Punto': 150,
    'Nombre': 150,
    'Apellidos': 150,
    'Vecindario': 150,
    'Teléfono': 150,
    'Fecha de nacimiento': 150,
    'Fecha de alta': 150,
    'Etnia': 150,
    'Sexo': 150,
    'Peso (kg)': 150,
    'Altura (cm)': 150,
    'Estado': 150,
    'Embarazada': 150,
    'Semanas': 150,
    'Hijos/as menores a 6 meses': 150,
    'Observaciones': 150,
    'Activo': 150,
  };

  /// Editing controller for forms to perform update the values.
  TextEditingController? nameController, surnamesController, addressController,
      phoneController, birthdateController, lastDateController, ethnicityController,
      sexController, weightController, heightController, statusController,
      pregnantController, weeksController, childMinorController, observationsController,
      activeController;

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

  _saveTutors(AsyncValue<List<TutorWithPoint>>? tutors) {
    if (tutors == null) {
      tutorDataGridSource.setTutors(List.empty());
    } else {
      tutorDataGridSource.setTutors(tutors.value);
    }
  }

  Widget _buildView(AsyncValue<List<TutorWithPoint>> tutors) {
    if (tutors.value != null && tutors.value!.isNotEmpty) {
      tutorDataGridSource.buildDataGridRows();
      tutorDataGridSource.updateDataSource();
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
          cellExport: (DataGridCellExcelExportDetails details) {

          });
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();
      await helper.FileSaveHelper.saveAndLaunchFile(bytes, '$_tutors.xlsx');
    }

    Future<void> exportDataGridToPdf() async {
      final ByteData data = await rootBundle.load('images/nut_logo.jpg');
      final PdfDocument document = _key.currentState!.exportToPdfDocument(
          fitAllColumnsInOnePage: true,
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

            header.graphics.drawString(
              _tutors,
              PdfStandardFont(PdfFontFamily.helvetica, 13,
                  style: PdfFontStyle.bold),
              bounds: const Rect.fromLTWH(0, 25, 200, 60),
            );

            details.pdfDocumentTemplate.top = header;
          });
      final List<int> bytes = document.saveSync();
      await helper.FileSaveHelper.saveAndLaunchFile(bytes, '$_tutors.pdf');
      document.dispose();
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
    var addMorePage = 0;
    if ((tutorDataGridSource.rows.length / _rowsPerPage).remainder(1) != 0) {
      addMorePage  = 1;
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SfDataPager(
        delegate: tutorDataGridSource,
        availableRowsPerPage: const <int>[15, 20, 25],
        pageCount: (tutorDataGridSource.rows.length / _rowsPerPage) + addMorePage,
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
        _buildRow(controller: nameController!, columnName: 'Nombre', text: _name),
        _buildRow(controller: surnamesController!, columnName: 'Apellidos', text: _surnames),
        _buildRow(controller: addressController!, columnName: 'Vecindario', text: _address),
        _buildRow(controller: phoneController!, columnName: 'Teléfono', text: _phone),
        _buildRow(controller: birthdateController!, columnName: 'Fecha de nacimiento', text: _birthdate),
        _buildRow(controller: lastDateController!, columnName: 'Fecha de alta', text: _lastDate),
        _buildRow(controller: ethnicityController!, columnName: 'Etnia', text: _ethnicity),
        _buildRow(controller: sexController!, columnName: 'Sexo', text: _sex),
        _buildRow(controller: weightController!, columnName: 'Peso (kg)', text: _weight),
        _buildRow(controller: heightController!, columnName: 'Altura (cm)', text: _height),
        _buildRow(controller: statusController!, columnName: 'Estado', text: _status),
        _buildRow(controller: pregnantController!, columnName: 'Embarazada', text: _pregnant),
        _buildRow(controller: weeksController!, columnName: 'Semanas', text: _weeks),
        _buildRow(controller: childMinorController!, columnName: 'Hijos/as menores a 6 meses', text: _childMinor),
        _buildRow(controller: observationsController!, columnName: 'Observaciones', text: _observations),
        _buildRow(controller: activeController!, columnName: 'Activo', text: _active),
      ],
    );
  }

  // Updating the data to the TextEditingController
  void _updateTextFieldContext(DataGridRow row) {
    final String? name = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'Nombre')
        ?.value
        .toString();
    nameController!.text = name ?? '';

    final String? surnames = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'Apellidos')
        ?.value
        .toString();
    surnamesController!.text = surnames ?? '';

    final String? address = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'Vecindario')
        ?.value
        .toString();
    addressController!.text = address ?? '';

    final String? phone = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'Teléfono')
        ?.value
        .toString();
    phoneController!.text = phone ?? '';

    final String? birthdate = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'Fecha de nacimiento')
        ?.value
        .toString();
    birthdateController!.text = birthdate ?? '';

    final String? lastDate = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'Fecha de alta')
        ?.value
        .toString();
    lastDateController!.text = lastDate ?? '';

    final String? ethnicity = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'Etnia')
        ?.value
        .toString();
    ethnicityController!.text = ethnicity ?? '';

    final String? sex = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'Sexo')
        ?.value
        .toString();
    sexController!.text = sex ?? '';

    final String? weight = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'Peso (kg)')
        ?.value
        .toString();
    weightController!.text = weight ?? '';

    final String? height = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'Altura (cm)')
        ?.value
        .toString();
    heightController!.text = height ?? '';

    final String? status = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'Estado')
        ?.value
        .toString();
    statusController!.text = status ?? '';

    final String? pregnant = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'Embarazada')
        ?.value
        .toString();
    pregnantController!.text = pregnant ?? '';

    final String? weeks = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'Semanas')
        ?.value
        .toString();
    weeksController!.text = weeks ?? '';

    final String? childMinor = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'Hijos/as menores a 6 meses')
        ?.value
        .toString();
    childMinorController!.text = childMinor ?? '';

    final String? observations = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'Observaciones')
        ?.value
        .toString();
    observationsController!.text = observations ?? '';

    final String? active = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'Activo')
        ?.value
        .toString();
    activeController!.text = active ?? '';
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
        title: Text(_editTutor),
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
    final Tutor? tutor = tutorDataGridSource.getTutors()?.firstWhere((element) => element.tutor.tutorId == row.getCells()[0].value).tutor;
    if (_formKey.currentState!.validate()) {
      ref.read(tutorsScreenControllerProvider.notifier).updateTutor(
          Tutor(
            tutorId: tutor!.tutorId,
            pointId: tutor.pointId,
            name: nameController!.text,
            surnames: surnamesController!.text,
            address: addressController!.text,
            phone: phoneController!.text,
            birthdate: DateTime.now(), // TODO: birthdateController!.text,
            lastDate: DateTime.now(), // TODO: lastDateController!.text,
            ethnicity: ethnicityController!.text,
            sex: sexController!.text,
            weight: double.parse(weightController!.text),
            height: double.parse(heightController!.text),
            status: statusController!.text,
            pregnant: pregnantController!.text,
            weeks: int.parse(weeksController!.text),
            childMinor: childMinorController!.text,
            observations: observationsController!.text,
            active: activeController!.text == '✔' ? true : false
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
    final tutor = tutorDataGridSource.getTutors()?.firstWhere((element) => element.tutor.tutorId == row.getCells()[0].value);
    if (tutor != null) {
      ref.read(tutorsScreenControllerProvider.notifier).deleteTutor(tutor.tutor);
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
        content: Text(_removedTutor),
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
              _editTutor,
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
              _removeTutor,
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
        _point = 'Point';
        _name = 'Name';
        _surnames = 'Surnames';
        _address = 'Address';
        _phone = 'Phone';
        _birthdate = 'Birthdate';
        _lastDate = 'Register date';
        _ethnicity = 'Ethnicity';
        _sex = 'Sex';
        _weight = 'Weight (kg)';
        _height = 'Height (cm)';
        _status = 'Status';
        _pregnant = 'Pregnant';
        _weeks = 'Weeks';
        _childMinor = 'Children under 6 months';
        _observations = 'Observations';
        _active = 'Active';

        _exportXLS = 'Export XLS';
        _exportPDF = 'Export PDF';
        _total = 'Total Tutors';
        _editTutor = 'Edit';
        _removeTutor = 'Remove';
        _cancel = 'Cancel';
        _save = 'Save';
        _tutors = 'Tutors';
        _removedTutor = 'Tutor deleted successfully.';
        break;
      case 'es_ES':
        _point = 'Punto';
        _name = 'Nombre';
        _surnames = 'Apellidos';
        _address = 'Vecindario';
        _phone = 'Teléfono';
        _birthdate = 'Fecha de nacimiento';
        _lastDate = 'Fecha de alta';
        _ethnicity = 'Etnia';
        _sex = 'Sexo';
        _weight = 'Peso (kg)';
        _height = 'Altura (cm)';
        _status = 'Estado';
        _pregnant = 'Embarazada';
        _weeks = 'Semanas';
        _childMinor = 'Hijos/as menores a 6 meses';
        _observations = 'Observaciones';
        _active = 'Activo';

        _exportXLS = 'Exportar XLS';
        _exportPDF = 'Exportar PDF';
        _total = 'Tutores totales';
        _editTutor = 'Editar';
        _removeTutor = 'Eliminar';
        _cancel = 'Cancelar';
        _save = 'Guardar';
        _tutors = 'Tutores';
        _removedTutor = 'Tutore eliminado correctamente.';
        break;
      case 'fr_FR':
        _point = 'Place';
        _name = 'Nom';
        _surnames = 'Noms de famille';
        _address = 'Quartier';
        _phone = 'Téléphone';
        _birthdate = 'Date de naissance';
        _lastDate = 'Date d\'enregistrement';
        _ethnicity = 'Appartenance ethnique';
        _sex = 'Sexe';
        _weight = 'Poids (kg)';
        _height = 'Hauteur (cm)';
        _status = 'État';
        _pregnant = 'Enceinte';
        _weeks = 'Semaines';
        _childMinor = 'Enfants de moins de 6 mois';
        _observations = 'Observations';
        _active = 'Actif';

        _exportXLS = 'Exporter XLS';
        _exportPDF = 'Exporter PDF';
        _total = 'Total des tuteurs';
        _editTutor = 'Modifier';
        _removeTutor = 'Supprimer';
        _cancel = 'Annuler';
        _save = 'Enregistrer';
        _tutors = 'Tuteurs';
        _removedTutor = 'Tuteur supprimé avec succès.';
        break;
    }

    return SfDataGrid(
      key: _key,
      source: tutorDataGridSource,
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
      allowSorting: true,
      allowMultiColumnSorting: true,
      columns: <GridColumn>[
        GridColumn(
            columnName: 'Punto',
            width: columnWidths['Punto']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _point,
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
            columnName: 'Vecindario',
            width: columnWidths['Vecindario']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _address,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Teléfono',
            width: columnWidths['Teléfono']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _phone,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Fecha de nacimiento',
            width: columnWidths['Fecha de nacimiento']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _birthdate,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Fecha de alta',
            width: columnWidths['Fecha de alta']!,
            label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _lastDate,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Etnia',
            width: columnWidths['Etnia']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _ethnicity,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Sexo',
            width: columnWidths['Sexo']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _sex,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Peso (kg)',
            width: columnWidths['Peso (kg)']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _weight,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Altura (cm)',
            width: columnWidths['Altura (cm)']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _height,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Estado',
            width: columnWidths['Estado']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _status,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Embarazada',
            width: columnWidths['Embarazada']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _pregnant,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Semanas',
            width: columnWidths['Semanas']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _weeks,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Hijos/as menores a 6 meses',
            width: columnWidths['Hijos/as menores a 6 meses']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _childMinor,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Observaciones',
            width: columnWidths['Observaciones']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _observations,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ),
        GridColumn(
            columnName: 'Activo',
            width: columnWidths['Activo']!,
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _active,
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
    tutorDataGridSource = TutorDataGridSource(List.empty());

    nameController = TextEditingController();
    surnamesController = TextEditingController();
    addressController = TextEditingController();
    phoneController = TextEditingController();
    birthdateController = TextEditingController();
    lastDateController = TextEditingController();
    ethnicityController = TextEditingController();
    sexController = TextEditingController();
    weightController = TextEditingController();
    heightController = TextEditingController();
    statusController = TextEditingController();
    pregnantController = TextEditingController();
    weeksController = TextEditingController();
    childMinorController = TextEditingController();
    observationsController = TextEditingController();
    activeController = TextEditingController();
    selectedLocale = model.locale.toString();

    _point = 'Punto';
    _name = 'Nombre';
    _surnames = 'Apellidos';
    _address = 'Vecindario';
    _phone = 'Teléfono';
    _birthdate = 'Fecha de nacimiento';
    _lastDate = 'Fecha de alta';
    _ethnicity = 'Etnia';
    _sex = 'Sexo';
    _weight = 'Peso (kg)';
    _height = 'Altura (cm)';
    _status = 'Estado';
    _pregnant = 'Embarazada';
    _weeks = 'Semanas';
    _childMinor = 'Hijos/as menores a 6 meses';
    _observations = 'Observaciones';
    _active = 'Activo';
    _exportXLS = 'Exportar XLS';
    _exportPDF = 'Exportar PDF';
    _total = 'Usuarios totales';
    _editTutor = 'Editar';
    _removeTutor = 'Eliminar';
    _cancel = 'Cancelar';
    _save = 'Guardar';
    _tutors = 'Tutores';
    _removedTutor = '';
  }


  @override
  Widget buildSample(BuildContext context) {
    return Consumer(
        builder: (context, ref, child) {
          ref.listen<AsyncValue>(
            tutorsScreenControllerProvider,
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

            currentUserEmail = user.email??"";
          }
          final tutorsAsyncValue = ref.watch(tutorsStreamProvider);
          if (tutorsAsyncValue.value != null) {
            _saveTutors(tutorsAsyncValue);
          }
          return _buildView(tutorsAsyncValue);
        });
  }

}



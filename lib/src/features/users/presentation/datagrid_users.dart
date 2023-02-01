/// Package imports
/// import 'package:flutter/foundation.dart';


import 'package:adminnut4health/src/features/users/presentation/users_screen_controller.dart';
import 'package:csv/csv.dart';
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
import '../../configurations/domain/configuration.dart';
import '../../points/domain/point.dart';
/// Local import
import '../data/firestore_repository.dart';
import '../domain/UserWithConfigurationAndPoint.dart';
import '../domain/user.dart';
import 'user_datagridsource.dart';

import 'package:file_picker/file_picker.dart';
import 'dart:html' show FileReader;

import '../../../common_widgets/export/save_file_mobile.dart'
  if (dart.library.html) '../../../common_widgets/export/save_file_web.dart' as helper;

import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;

/// Render user data grid
class UserDataGrid extends SampleView {
  /// Creates getting started data grid
  const UserDataGrid({Key? key}) : super(key: key);

  @override
  _UserDataGridState createState() => _UserDataGridState();
}

class _UserDataGridState extends SampleViewState {

  final GlobalKey<SfDataGridState> _key = GlobalKey<SfDataGridState>();

  /// DataGridSource required for SfDataGrid to obtain the row data.
  late UserDataGridSource userDataGridSource;

  static const double dataPagerHeight = 60;
  int _rowsPerPage = 15;

  late Map<String, double> columnWidths = {
    'Foto': 150,
    'Username': 150,
    'Nombre': 150,
    'Apellidos': 150,
    'DNI/DPI': 150,
    'Email': 180,
    'Teléfono': 150,
    'Rol': 150,
    'Configuración': 150,
    'Punto': 200,
    'Puntos': 150,
    'CreateDate': 150
  };

  /// Editing controller for forms to perform update the values.
  TextEditingController? usernameController,
      nameController,
      surnamesController,
      dniController,
      emailController,
      phoneController,
      pointsController,
      pointController,
      roleController,
      configurationController
  ;

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

  _saveUsers(AsyncValue<List<UserWithConfigurationAndPoint>>? users) {
    if (users == null) {
      userDataGridSource.setUsers(List.empty());
    } else {
      final notEmptyUsers = users.value!.where((element) => !element.user!.email.contains('@anonymous.com')).toList();
      userDataGridSource.setUsers(notEmptyUsers);
    }
  }

  _saveConfigurations(AsyncValue<List<Configuration>>? configurations) {
    if (configurations == null) {
      userDataGridSource.setConfigurations(List.empty());
    } else {
      userDataGridSource.setConfigurations(configurations.value!);
    }
  }

  _savePoints(AsyncValue<List<Point>>? points) {
    if (points == null) {
      userDataGridSource.setPoints(List.empty());
    } else {
      userDataGridSource.setPoints(points.value!);
    }
  }

  Widget _buildView(AsyncValue<List<UserWithConfigurationAndPoint>> users) {
    if (users.value != null && users.value!.isNotEmpty) {
      userDataGridSource.buildDataGridRows();
      userDataGridSource.updateDataSource();
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
                              child: _buildDataGrid()
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

  void _importUsers() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final myUint8List = new Uint8List.fromList(result.files.single.bytes!);
      final blob = Blob([myUint8List], 'text/plain');
      readBlob(blob).then((it) {
        List<List<dynamic>> rowsAsListOfValues =
            const CsvToListConverter().convert(it);
        for (final row in rowsAsListOfValues) {
          if (row.length > 1) {
            final email = row[5].toString();
            try {
              final userFoundByEmail = userDataGridSource
                  .getUsers()!
                  .firstWhere((element) => element.user.email == email);
              final userToUpdate = userFoundByEmail.user;
              ref.read(usersScreenControllerProvider.notifier).updateUser(User(
                  userId: userToUpdate.userId,
                  username: row[1].toString(),
                  name: row[2].toString(),
                  surname: row[3].toString(),
                  dni: row[4].toString(),
                  email: userToUpdate.email,
                  phone: row[6].toString(),
                  role: row[7].toString(),
                  point: userDataGridSource
                      .getPoints()
                      .firstWhere(
                          (element) => element.name == row[8].toString())
                      .pointId,
                  configuration: userDataGridSource
                      .getConfigurations()
                      .firstWhere(
                          (element) => element.name == row[9].toString())
                      .id,
                  points: int.tryParse(row[10].toString())));
            } catch (e) {
              if (e is Error && e.toString().contains('No element')) {
                ref.read(usersScreenControllerProvider.notifier).addUser(User(
                    userId: "",
                    photo: row[0].toString(),
                    username: row[1].toString(),
                    name: row[2].toString(),
                    surname: row[3].toString(),
                    dni: row[4].toString(),
                    email: row[5].toString(),
                    phone: row[6].toString(),
                    role: row[7].toString(),
                    point: userDataGridSource
                        .getPoints()
                        .firstWhere(
                            (element) => element.name == row[8].toString())
                        .pointId,
                    configuration: userDataGridSource
                        .getConfigurations()
                        .firstWhere(
                            (element) => element.name == row[9].toString())
                        .id,
                    points: int.tryParse(row[10].toString())));
              } else {
                print("another error import");
              }
            }
          }
        }
      });
    } else {
      // User canceled the picker
    }
  }

  Future<String> readBlob(Blob blob) async {
    final reader = FileReader();
    reader.readAsText(blob);
    await reader.onLoad.first;
    return reader.result as String;
  }

  void _createUser() {
    _createTextFieldContext();
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        scrollable: true,
        titleTextStyle: TextStyle(
            color: model.textColor, fontWeight: FontWeight.bold, fontSize: 16),
        title: const Text('Crear usuario'),
        actions: _buildActionCreateButtons(context),
        content: Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Form(
              key: _formKey,
              child: _buildAlertDialogCreateContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderButtons() {
    Future<void> exportDataGridToExcel() async {
      final Workbook workbook = _key.currentState!.exportToExcelWorkbook(
          cellExport: (DataGridCellExcelExportDetails details) {
          });
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();
      await helper.FileSaveHelper.saveAndLaunchFile(bytes, 'Usuarios.xlsx');
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
              'Usuarios',
              PdfStandardFont(PdfFontFamily.helvetica, 13,
                  style: PdfFontStyle.bold),
              bounds: const Rect.fromLTWH(0, 25, 200, 60),
            );

            details.pdfDocumentTemplate.top = header;
          });
      final List<int> bytes = document.saveSync();
      await helper.FileSaveHelper.saveAndLaunchFile(bytes, 'Users.pdf');
      document.dispose();
    }

    return Row(
      children: <Widget>[
        _buildCreatingButton('Crear Usuario', 'images/Add.png'),
        _buildImportButton('Importar CSV', 'images/ExcelExport.png'),
        _buildExportingButton('Exportar a XLS', 'images/ExcelExport.png',
            onPressed: exportDataGridToExcel),
        _buildExportingButton('Exportar a PDF', 'images/PdfExport.png',
            onPressed: exportDataGridToPdf)
      ],
    );
  }

  Widget _buildImportButton(String buttonName, String imagePath) {
    return Container(
      height: 60.0,
      padding: const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0),
      child: MaterialButton(
        onPressed: _importUsers,
        color: model.backgroundColor,
        child: SizedBox(
          width: 150.0,
          height: 40.0,
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: ImageIcon(
                  AssetImage(imagePath),
                  size: 30,
                  color: Colors.white,
                ),
              ),
              Text(buttonName, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreatingButton(String buttonName, String imagePath) {
    return Container(
      height: 60.0,
      padding: const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0),
      child: MaterialButton(
        onPressed: _createUser,
        color: model.backgroundColor,
        child: SizedBox(
          width: 150.0,
          height: 40.0,
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: ImageIcon(
                  AssetImage(imagePath),
                  size: 30,
                  color: Colors.white,
                ),
              ),
              Text(buttonName, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExportingButton(String buttonName, String imagePath,
      {required VoidCallback onPressed}) {
    return Container(
      height: 60.0,
      padding: const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0),
      child: MaterialButton(
        onPressed: onPressed,
        color: model.backgroundColor,
        child: SizedBox(
          width: 150.0,
          height: 40.0,
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: ImageIcon(
                  AssetImage(imagePath),
                  size: 30,
                  color: Colors.white,
                ),
              ),
              Text(buttonName, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataPager() {
    return SfDataPager(
        delegate: userDataGridSource,
        availableRowsPerPage: const <int>[15, 20, 25],
        pageCount: userDataGridSource.rows.length / _rowsPerPage,
        onRowsPerPageChanged: (int? rowsPerPage) {
          setState(() {
            _rowsPerPage = rowsPerPage!;
          });
        },
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
          title: 'Usuarios totales: {Count}',
          columns: <GridSummaryColumn>[
            const GridSummaryColumn(
                name: 'Count',
                columnName: 'Username',
                summaryType: GridSummaryType.count),
          ],
          position: GridTableSummaryRowPosition.bottom),
    ];
  }

  RegExp _getRegExp(TextInputType keyboardType, String columnName) {
    if (keyboardType == TextInputType.number) {
      return RegExp('[0-9]');
    } else if (keyboardType == TextInputType.text) {
      return RegExp(r'^[a-zA-Z0-9]+$');
    } /*else if (keyboardType == TextInputType.emailAddress) {
      return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    }*/ else {
      return RegExp(r'^[a-zA-Z0-9]+$');
    }
  }

  Widget _buildRowComboSelection({required TextEditingController controller, required String columnName, required List<String> dropDownMenuItems}) {
    String value = controller.text;
    if (value.isEmpty) {
      value = dropDownMenuItems[0];
    }
    return Row(
      children: <Widget>[
        Container(
            width: 150,
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Text(columnName)),
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

  /// Building the each field with label and TextFormField
  Widget _buildRow(
      {required TextEditingController controller, required String columnName}) {
    TextInputType keyboardType = TextInputType.text;
    if (<String>['Puntos'].contains(columnName)) {
      keyboardType =  TextInputType.number;
    } else if (<String>['Email'].contains(columnName)) {
      keyboardType =  TextInputType.emailAddress;
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
            child: Text(columnName)),
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
    final roleOptions = ["Super Admin", "Donante", "Servicio Salud", "Agente Salud"];
    final pointOptions = userDataGridSource.getPoints().map((e) => e.name).toList();
    pointOptions.insert(0, "");
    final configurationOptions = userDataGridSource.getConfigurations().map((e) => e.name).toList();
    configurationOptions.insert(0, "");
    return Column(
      children: <Widget>[
        _buildRow(controller: usernameController!, columnName: 'Username'),
        _buildRow(controller: nameController!, columnName: 'Nombre'),
        _buildRow(controller: surnamesController!, columnName: 'Apellidos'),
        _buildRow(controller: dniController!, columnName: 'DNI/DPI'),
        _buildRow(controller: phoneController!, columnName: 'Teléfono'),
        _buildRowComboSelection(controller: roleController!, columnName: 'Rol',
            dropDownMenuItems: roleOptions),
        _buildRowComboSelection(controller: pointController!, columnName: 'Punto',
            dropDownMenuItems: pointOptions),
        _buildRowComboSelection(controller: configurationController!,
            columnName: 'Configuración', dropDownMenuItems: configurationOptions),
      ],
    );
  }

  /// Building the forms to create the data
  Widget _buildAlertDialogCreateContent() {
    final roleOptions = ["Super Admin", "Donante", "Servicio Salud", "Agente Salud"];
    final pointOptions = userDataGridSource.getPoints().map((e) => e.name).toList();
    pointOptions.insert(0, "");
    final configurationOptions = userDataGridSource.getConfigurations().map((e) => e.name).toList();
    configurationOptions.insert(0, "");
    return Column(
      children: <Widget>[
        _buildRow(controller: usernameController!, columnName: 'Username'),
        _buildRow(controller: nameController!, columnName: 'Nombre'),
        _buildRow(controller: surnamesController!, columnName: 'Apellidos'),
        _buildRow(controller: dniController!, columnName: 'DNI/DPI'),
        _buildRow(controller: emailController!, columnName: 'Email'),
        _buildRow(controller: phoneController!, columnName: 'Teléfono'),
        _buildRowComboSelection(controller: roleController!, columnName: 'Rol',
            dropDownMenuItems: roleOptions),
        _buildRowComboSelection(controller: pointController!, columnName: 'Punto',
            dropDownMenuItems: pointOptions),
        _buildRowComboSelection(controller: configurationController!,
            columnName: 'Configuración', dropDownMenuItems: configurationOptions),
      ],
    );
  }

  void _createTextFieldContext() {
    usernameController!.text = '';
    nameController!.text = '';
    surnamesController!.text = '';
    dniController!.text = '';
    emailController!.text = '';
    phoneController!.text =  '';
    pointsController!.text = '';
    roleController!.text = '';
    pointController!.text = '';
    configurationController!.text = '';
  }

  // Updating the data to the TextEditingController
  void _updateTextFieldContext(DataGridRow row) {
    final String? username = row
        .getCells()
        .firstWhere((DataGridCell element) => element.columnName == 'Username')
        ?.value
        .toString();
    usernameController!.text = username ?? '';

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

    final String? dni = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'DNI/DPI')
        ?.value;

    dniController!.text  = dni ?? '';

    final String? email = row
        .getCells()
        .firstWhere(
          (DataGridCell element) => element.columnName == 'Email',
    )
        ?.value
        .toString();

    emailController!.text = email ?? '';

    final String? phone = row
        .getCells()
        .firstWhere(
          (DataGridCell element) => element.columnName == 'Teléfono',
    )
        ?.value
        .toString();

    phoneController!.text = phone ?? '';

    final String? rol = row
        .getCells()
        .firstWhere(
          (DataGridCell element) => element.columnName == 'Rol',
    )
        ?.value
        .toString();

    roleController!.text = rol ?? '';

    final String? point = row
        .getCells()
        .firstWhere(
          (DataGridCell element) => element.columnName == 'Punto',
    )
        ?.value
        .toString();

    pointController!.text = point ?? '';

    final String? configuration = row
        .getCells()
        .firstWhere(
          (DataGridCell element) => element.columnName == 'Configuración',
    )
        ?.value
        .toString();

    configurationController!.text = configuration ?? '';

    final dynamic points = row
        .getCells()
        .firstWhere(
            (DataGridCell element) => element.columnName == 'Puntos')
        ?.value;

    pointsController!.text =
    points == null ? '' : points.toString();

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
        title: const Text('Editar usuario'),
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

  void _processCellCreate(BuildContext buildContext) async {
    if (_formKey.currentState!.validate()) {
      ref.read(usersScreenControllerProvider.notifier).addUser(
          User( userId: "",
              username: usernameController!.text, name: nameController!.text,
              surname: surnamesController!.text, dni: dniController!.text,
              email: emailController!.text, phone: phoneController!.text,
              role: roleController!.text,
              point: userDataGridSource.getPoints().firstWhere((element) => element.name == pointController!.text).pointId,
              configuration: userDataGridSource.getConfigurations().firstWhere((element) => element.name == configurationController!.text).id,
              points: int.tryParse(pointsController!.text))
      );
      Navigator.pop(buildContext);
    }
  }

  /// Updating the DataGridRows after changing the value and notify the DataGrid
  /// to refresh the view
  void _processCellUpdate(DataGridRow row, BuildContext buildContext) {
    final String? id = userDataGridSource.getUsers()?.firstWhere((element) => element.user.email == row.getCells()[5].value).user.userId;
    if (_formKey.currentState!.validate()) {
      ref.read(usersScreenControllerProvider.notifier).updateUser(
          User(userId: id!,
              username: usernameController!.text, name: nameController!.text,
              surname: surnamesController!.text, dni: dniController!.text,
              email: emailController!.text, phone: phoneController!.text,
              role: roleController!.text,
              point: userDataGridSource.getPoints().firstWhere((element) => element.name == pointController!.text).pointId,
              configuration: userDataGridSource.getConfigurations().firstWhere((element) => element.name == configurationController!.text).id,
              points: int.tryParse(pointsController!.text)
          )
      );
      Navigator.pop(buildContext);
    }
  }

  List<Widget> _buildActionCreateButtons(BuildContext buildContext) {
    return <Widget>[
      TextButton(
        onPressed: () => _processCellCreate(buildContext),
        child: Text(
          'GUARDAR',
          style: TextStyle(color: model.backgroundColor),
        ),
      ),
      TextButton(
        onPressed: () => Navigator.pop(buildContext),
        child: Text(
          'CANCELAR',
          style: TextStyle(color: model.backgroundColor),
        ),
      ),
    ];
  }

  /// Building the option button on the bottom of the alert popup
  List<Widget> _buildActionButtons(DataGridRow row, BuildContext buildContext) {
    return <Widget>[
      TextButton(
        onPressed: () => _processCellUpdate(row, buildContext),
        child: Text(
          'GUARDAR',
          style: TextStyle(color: model.backgroundColor),
        ),
      ),
      TextButton(
        onPressed: () => Navigator.pop(buildContext),
        child: Text(
          'CANCELAR',
          style: TextStyle(color: model.backgroundColor),
        ),
      ),
    ];
  }

  /// Deleting the DataGridRow
  void _handleDeleteWidgetTap(DataGridRow row) {
    final user = userDataGridSource.getUsers()?.firstWhere((element) => element.user.email == row.getCells()[5].value).user;
    if (user != null) {
      ref.read(usersScreenControllerProvider.notifier).deleteUser(user);
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
        content: const Text('Usuario eliminado correctamente'),
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
          children: const <Widget>[
            Icon(Icons.edit, color: Colors.white, size: 16),
            SizedBox(width: 8.0),
            Text(
              'EDITAR',
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
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Icon(Icons.delete, color: Colors.white, size: 16),
            SizedBox(width: 8.0),
            Text(
              'BORRAR',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  SfDataGrid _buildDataGrid() {
    return SfDataGrid(
      key: _key,
      source: userDataGridSource,
      rowsPerPage: _rowsPerPage,
      tableSummaryRows: _getTableSummaryRows(),
      allowSwiping: true,
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
            width: columnWidths['Foto']!,
            allowFiltering: false,
            columnName: 'Foto',
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: const Text(
                'Foto',
                overflow: TextOverflow.ellipsis,
              ),
            )),
        GridColumn(
            width: columnWidths['Username']!,
            columnName: 'Username',
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: const Text(
                'Username',
                overflow: TextOverflow.ellipsis,
              ),
            )),
        GridColumn(
          columnName: 'Nombre',
            width: columnWidths['Nombre']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: const Text(
              'Nombre',
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
            child: const Text(
              'Apellidos',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
          columnName: 'DNI/DPI',
          width: columnWidths['DNI/DPI']!,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: const Text(
              'DNI/DPI',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
          columnName: 'Email',
          width: columnWidths['Email']!,
          label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Email',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
          columnName: 'Teléfono',
          width: columnWidths['Teléfono']!,
          label: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0),
            child: const Text(
              'Teléfono',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
          columnName: 'Rol',
          width: columnWidths['Rol']!,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text(
                'Rol',
                overflow: TextOverflow.ellipsis,
              )),
        ),
        GridColumn(
          columnName: 'Punto',
          width: columnWidths['Punto']!,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text(
                'Punto',
                overflow: TextOverflow.ellipsis,
              )),
        ),
        GridColumn(
          columnName: 'Configuración',
          width: columnWidths['Configuración']!,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text(
                'Configuración',
                overflow: TextOverflow.ellipsis,
              )),
        ),
        GridColumn(
          columnName: 'Puntos',
          width: columnWidths['Puntos']!,
          columnWidthMode: ColumnWidthMode.lastColumnFill,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text(
                'Puntos',
                overflow: TextOverflow.ellipsis,
              )),
        ),
        GridColumn(
            width: columnWidths['CreateDate']!,
            columnName: 'CreateDate',
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: const Text(
                'CreateDate',
                overflow: TextOverflow.ellipsis,
              ),
            )),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    userDataGridSource = UserDataGridSource(List.empty(), List.empty(), List.empty());
    usernameController = TextEditingController();
    nameController = TextEditingController();
    surnamesController = TextEditingController();
    dniController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    roleController = TextEditingController();
    pointController  = TextEditingController();
    configurationController  = TextEditingController();
    pointsController = TextEditingController();
  }


  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (context, ref, child) {
          ref.listen<AsyncValue>(
            usersScreenControllerProvider,
                (_, state) => {
                },
          );
          final usersAsyncValue = ref.watch(usersStreamProvider);
          final pointsAsyncValue = ref.watch(pointsStreamProvider);
          final configurationsAsyncValue = ref.watch(configurationsStreamProvider);
          if (usersAsyncValue.value != null) {
            _saveUsers(usersAsyncValue);
          }
          if (pointsAsyncValue.value != null) {
            _savePoints(pointsAsyncValue);
          }
          if (configurationsAsyncValue.value != null) {
            _saveConfigurations(configurationsAsyncValue);
          }
          // a veces no se mete aqui
          return _buildView(usersAsyncValue);
        });
  }
}



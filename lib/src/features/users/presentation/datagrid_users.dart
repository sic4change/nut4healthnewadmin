/// Package imports
/// import 'package:flutter/foundation.dart';
import 'package:adminnut4health/src/features/users/presentation/users_screen_controller.dart';
import 'package:adminnut4health/src/utils/async_value_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Barcode import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../../sample/model/sample_view.dart';
/// Local import
import '../data/firestore_repository.dart';
import '../domain/user.dart';
import 'user_datagridsource.dart';

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
      rolController,
      pointController,
      configurationController,
      pointsController;

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

  Widget _buildView(AsyncValue<List<User>> users) {
    if (users.value != null && users.value!.isNotEmpty) {
      userDataGridSource.setUsers(users.value);
      userDataGridSource.buildDataGridRows();
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
                        _buildExportingButtons(),
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

  Widget _buildExportingButtons() {
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
        _buildExportingButton('Exportar a Excel', 'images/ExcelExport.png',
            onPressed: exportDataGridToExcel),
        _buildExportingButton('Exportar a PDF', 'images/PdfExport.png',
            onPressed: exportDataGridToPdf)
      ],
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
    } else if (keyboardType == TextInputType.emailAddress) {
      return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    } else {
      return RegExp(r'^[a-zA-Z0-9]+$');
    }
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
    return Column(
      children: <Widget>[
        _buildRow(controller: usernameController!, columnName: 'Username'),
        _buildRow(controller: nameController!, columnName: 'Nombre'),
        _buildRow(controller: surnamesController!, columnName: 'Apellidos'),
        _buildRow(controller: dniController!, columnName: 'DNI/DPI'),
        //_buildRow(controller: emailController!, columnName: 'Email'),
        _buildRow(controller: phoneController!, columnName: 'Teléfono'),
        _buildRow(controller: rolController!, columnName: 'Rol'),
        _buildRow(controller: pointController!, columnName: 'Punto'),
        _buildRow(controller: configurationController!, columnName: 'Configuración'),
        //_buildRow(controller: pointsController!, columnName: 'Puntos'),
      ],
    );
  }

  /// Building the forms to edit the data
  Widget _buildAlertDialogCreateContent() {
    return Column(
      children: <Widget>[
        _buildRow(controller: usernameController!, columnName: 'Username'),
        _buildRow(controller: nameController!, columnName: 'Nombre'),
        _buildRow(controller: surnamesController!, columnName: 'Apellidos'),
        _buildRow(controller: dniController!, columnName: 'DNI/DPI'),
        _buildRow(controller: emailController!, columnName: 'Email'),
        _buildRow(controller: phoneController!, columnName: 'Teléfono'),
        _buildRow(controller: rolController!, columnName: 'Rol'),
        _buildRow(controller: pointController!, columnName: 'Punto'),
        _buildRow(controller: configurationController!, columnName: 'Configuración'),
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
    rolController!.text = '';
    pointController!.text =  '';
    configurationController!.text = '';
    pointsController!.text = '';
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

    rolController!.text = rol ?? '';

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

  void _processCellCreate(BuildContext buildContext) {
    if (_formKey.currentState!.validate()) {
      userDataGridSource.getUsers()!.add(User( userId: "",
          username: usernameController!.text, name: nameController!.text,
          surname: surnamesController!.text, dni: dniController!.text,
          email: emailController!.text, phone: phoneController!.text,
          role: rolController!.text, point: pointController!.text,
          configuration: configurationController!.text,
          points: int.tryParse(pointsController!.text)));
      userDataGridSource.buildDataGridRows();
      userDataGridSource.notifyListeners();
      Navigator.pop(buildContext);
    }
  }

  /// Updating the DataGridRows after changing the value and notify the DataGrid
  /// to refresh the view
  void _processCellUpdate(DataGridRow row, BuildContext buildContext) {
    final int rowIndex = userDataGridSource.rows.indexOf(row);

    if (_formKey.currentState!.validate()) {
      userDataGridSource.getUsers()![rowIndex] = User( userId: "",
        username: usernameController!.text, name: nameController!.text,
         surname: surnamesController!.text, dni: dniController!.text,
        email: emailController!.text, phone: phoneController!.text,
        role: rolController!.text, point: pointController!.text,
          configuration: configurationController!.text,
        points: int.tryParse(pointsController!.text)
      );
      userDataGridSource.buildDataGridRows();
      userDataGridSource.notifyListeners();
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
    final int index = userDataGridSource.rows.indexOf(row);
    userDataGridSource.rows.remove(row);
    userDataGridSource.getUsers()?.remove(userDataGridSource.getUsers()![index]);
    userDataGridSource.notifyListeners();
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

  /// Callback for left swiping, and it will flipped for RTL case
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

  /// Callback for right swiping, and it will flipped for RTL case
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
    userDataGridSource = UserDataGridSource(List.empty());
    usernameController = TextEditingController();
    nameController = TextEditingController();
    surnamesController = TextEditingController();
    dniController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    rolController = TextEditingController();
    pointController = TextEditingController();
    configurationController = TextEditingController();
    pointsController = TextEditingController();
  }


  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (context, ref, child) {
          ref.listen<AsyncValue>(
            usersScreenControllerProvider,
                (_, state) => state.showAlertDialogOnError(context),
          );
          final usersAsyncValue = ref.watch(usersStreamProvider);
          return _buildView(usersAsyncValue);
        });
  }
}



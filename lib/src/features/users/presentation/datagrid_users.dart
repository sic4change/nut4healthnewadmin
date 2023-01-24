/// Package imports
/// import 'package:flutter/foundation.dart';
import 'package:adminnut4health/src/features/users/presentation/users_screen_controller.dart';
import 'package:adminnut4health/src/utils/async_value_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Barcode import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../../sample/model/sample_view.dart';
/// Local import
import '../data/firestore_repository.dart';
import '../domain/user.dart';
import 'user_datagridsource.dart';

/// Render user data grid
class UserDataGrid extends SampleView {
  /// Creates getting started data grid
  const UserDataGrid({Key? key}) : super(key: key);

  @override
  _UserDataGridState createState() => _UserDataGridState();
}

class _UserDataGridState extends SampleViewState {
  /// DataGridSource required for SfDataGrid to obtain the row data.
  late UserDataGridSource userDataGridSource;

  static const double dataPagerHeight = 60;
  int _rowsPerPage = 15;

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
              SizedBox(
                  height: constraint.maxHeight - dataPagerHeight,
                  width: constraint.maxWidth,
                  child: _buildDataGrid()),
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

  List<GridTableSummaryRow> getTableSummaryRows() {
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
          position: GridTableSummaryRowPosition.top),
    ];
  }


  SfDataGrid _buildDataGrid() {
    return SfDataGrid(
      source: userDataGridSource,
      rowsPerPage: _rowsPerPage,
      tableSummaryRows: getTableSummaryRows(),
      columns: <GridColumn>[
        GridColumn(
            width: (model.isWeb || model.isMacOS || model.isLinux) ? 150 : 130,
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
          width: (model.isWeb || model.isMacOS || model.isLinux) ? 150 : 130,
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
          width: (model.isWeb || model.isMacOS || model.isLinux) ? 150 : 130,
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
          width: (model.isWeb || model.isMacOS || model.isLinux) ? 150 : 130,
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
          width: (model.isWeb || model.isMacOS || model.isLinux) ? 180 : 150,
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
          width: (model.isWeb || model.isMacOS || model.isLinux) ? 150 : 130,
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
          width: (model.isWeb || model.isMacOS || model.isLinux) ? 150 : 130,
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
          width: (model.isWeb || model.isMacOS || model.isLinux) ? 150 : 130,
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
          width: (model.isWeb || model.isMacOS || model.isLinux) ? 150 : 130,
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
          width: (model.isWeb || model.isMacOS || model.isLinux) ? 150 : 130,
          columnWidthMode: ColumnWidthMode.lastColumnFill,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text(
                'Puntos',
                overflow: TextOverflow.ellipsis,
              )),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    userDataGridSource = UserDataGridSource(List.empty());
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

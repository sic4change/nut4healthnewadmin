/// Package imports
/// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Barcode import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../../sample/model/sample_view.dart';
/// Local import
import '../../../sample/samples/datagrid/datagridsource/team_datagridsource.dart';
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

  SfDataGrid _buildDataGrid() {
    return SfDataGrid(
      source: userDataGridSource,
      columns: <GridColumn>[
        GridColumn(
            width: 130,
            columnName: 'username',
            label: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: const Text(
                'Username',
                overflow: TextOverflow.ellipsis,
              ),
            )),
        GridColumn(
          columnName: 'name',
          width: (model.isWeb || model.isMacOS || model.isLinux) ? 150 : 130,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: const Text(
              'Nombre',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridColumn(
          columnName: 'surname',
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
          columnName: 'mail',
          width: 180.0,
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
          columnName: 'phone',
          width: model.isLinux ? 120.0 : 105.0,
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
          columnName: 'status',
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text(
                'Estado',
                overflow: TextOverflow.ellipsis,
              )),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    userDataGridSource = UserDataGridSource();
  }

  @override
  Widget build(BuildContext context) {
    return _buildDataGrid();
  }
}

/// Dart import

/// Packages import
import 'package:flutter/material.dart';

/// DataGrid import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../domain/PaymentWithScreenerAndContract.dart';

/// Set payments's data collection to data grid source.
class PaymentDataGridSource extends DataGridSource {
  /// Creates the payment data source class with required details.
  PaymentDataGridSource(List<PaymentWithScreener> paymentData) {
    _payments = paymentData;
    buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = <DataGridRow>[];
  List<PaymentWithScreener>? _payments = <PaymentWithScreener>[];

  /// Building DataGridRows
  void buildDataGridRows() {
    if (_payments != null && _payments!.isNotEmpty) {
      _dataGridRows = _payments!.map<DataGridRow>((PaymentWithScreener paymentWithScreenerAndContract) {
        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<String>(columnName: 'Id', value: paymentWithScreenerAndContract.payment.paymentId),
          DataGridCell<String>(columnName: 'Estado', value: paymentWithScreenerAndContract.payment.status),
          DataGridCell<String>(columnName: 'Tipo', value: paymentWithScreenerAndContract.payment.type),
          DataGridCell<String>(columnName: 'Nombre Agente Salud', value: "${paymentWithScreenerAndContract.screener.name} ${paymentWithScreenerAndContract.screener.surname}"),
          DataGridCell<String>(columnName: 'DNI/DPI Agente Salud', value: paymentWithScreenerAndContract.screener.dni),
          DataGridCell<String>(columnName: 'Email Agente Salud', value: paymentWithScreenerAndContract.screener.email),
          DataGridCell<String>(columnName: 'Teléfono Agente Salud', value: paymentWithScreenerAndContract.screener.phone),
          DataGridCell<DateTime>(columnName: 'Fecha', value: paymentWithScreenerAndContract.payment.creationDate),
          DataGridCell<double>(columnName: 'Cantidad', value: paymentWithScreenerAndContract.payment.quantity),
        ]);
      }).toList();
    }
  }

  // Overrides
  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  Widget? buildTableSummaryCellWidget(
      GridTableSummaryRow summaryRow,
      GridSummaryColumn? summaryColumn,
      RowColumnIndex rowColumnIndex,
      String summaryValue) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      child: Text(summaryValue),
    );
  }

  Widget _buildEmail(dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: _getWidget(const Icon(Icons.email, size: 20), value),
    );
  }

  Widget _buildPhone(dynamic value) {
    if (value.toString().isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: _getWidget(const Icon(Icons.phone, size: 20), value),
      );
    } else {
      return const Text("");
    }
  }

  Widget _buildDate(dynamic value) {
    String valueString = value.toString();
    if (valueString == null || valueString.isEmpty || valueString == '1970-01-01 00:00:00.000') {
      return const Text("");
    } else {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: _getWidget(const Icon(Icons.calendar_month, size: 20), value.toString()),
      );
    }
  }

  Widget _buildStatus(dynamic value) {
    return Center(
      child: Text(
        value,
        style: _getStatusTextStyle(value),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _getWidget(Widget image, String text) {
    return Container(
      color: Colors.transparent,
      child: Row(
        children: <Widget>[
          Container(
            child: image,
          ),
          const SizedBox(width: 6),
          Expanded(
              child: Text(
            text,
            overflow: TextOverflow.ellipsis,
          ))
        ],
      ),
    );
  }


  TextStyle _getStatusTextStyle(dynamic value) {
    if (value.toString() == 'CREATED') {
      return const TextStyle(color: Colors.orange);
    } else if (value.toString() == 'PAID') {
      return TextStyle(color: Colors.green);
    } else if (value.toString() == 'CANCELLED') {
      return const TextStyle(color: Colors.red);
    }  else {
      return const TextStyle(color: Colors.orange);
    }
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(cells: <Widget>[
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[0].value.toString()),
      ),
      _buildStatus(row.getCells()[1].value.toString()),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[2].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[3].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[4].value.toString()),
      ),
      _buildEmail(row.getCells()[5].value.toString()),
      _buildPhone(row.getCells()[6].value.toString()),
      _buildDate(row.getCells()[7].value.toString()),
      Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[8].value.toString()),
      ),
    ]);
  }

  setPayments(List<PaymentWithScreener>? paymentData) {
    _payments = paymentData;
  }

  List<PaymentWithScreener>? getPayments() {
    return _payments;
  }

  /// Update DataSource
  void updateDataSource() {
    notifyListeners();
  }

}

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;

class CustomDataGridToExcelConverter extends DataGridToExcelConverter {
  @override
  void exportColumnHeader(SfDataGrid dataGrid, GridColumn column,
      String columnName, Worksheet worksheet) {
    String label = columnName;
    if (column.label is Container) {
      final Container container = column.label as Container;
      if (container.child is Text) {
        final Text textWidget = container.child as Text;
        label = textWidget.data ?? column.columnName;
      }
    }
    super.exportColumnHeader(dataGrid, column, label, worksheet);
  }

  @override
  void exportColumnHeaders(SfDataGrid dataGrid, Worksheet worksheet) {
    // TODO: Add your requirements in exportColumnHeaders
    super.exportColumnHeaders(dataGrid, worksheet);
  }

  @override
  void exportRow(SfDataGrid dataGrid, DataGridRow row, GridColumn column,
      Worksheet worksheet) {
    // TODO: Add your requirements in exportRow
    super.exportRow(dataGrid, row, column, worksheet);
  }

  @override
  void exportRows(
      SfDataGrid dataGrid, List<DataGridRow> rows, Worksheet worksheet) {
    // TODO: Add your requirements in exportRows
    super.exportRows(dataGrid, rows, worksheet);
  }

  @override
  void exportStackedHeaderRow(SfDataGrid dataGrid,
      StackedHeaderRow stackedHeaderRow, Worksheet worksheet) {
    // TODO: Add your requirements in exportStackedHeaderRow
    super.exportStackedHeaderRow(dataGrid, stackedHeaderRow, worksheet);
  }

  @override
  void exportStackedHeaderRows(SfDataGrid dataGrid, Worksheet worksheet) {
    // TODO: Add your requirements in exportStackedHeaderRows
    super.exportStackedHeaderRows(dataGrid, worksheet);
  }

  @override
  void exportTableSummaryRow(SfDataGrid dataGrid,
      GridTableSummaryRow summaryRow, Worksheet worksheet) {
    // TODO: Add your requirements in exportTableSummaryRow
    super.exportTableSummaryRow(dataGrid, summaryRow, worksheet);
  }

  @override
  void exportTableSummaryRows(SfDataGrid dataGrid,
      GridTableSummaryRowPosition position, Worksheet worksheet) {
    // TODO: Add your requirements in exportTableSummaryRows
    super.exportTableSummaryRows(dataGrid, position, worksheet);
  }

  @override
  Object? getCellValue(DataGridRow row, GridColumn column) {
    // TODO: implement getCellValue
    return super.getCellValue(row, column);
  }
}
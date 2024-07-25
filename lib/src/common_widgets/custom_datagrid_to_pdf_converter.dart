import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class CustomDataGridToPdfConverter extends DataGridToPdfConverter {
  @override
  void exportColumnHeader(SfDataGrid dataGrid, GridColumn column,
      String columnName, PdfGrid pdfGrid) {
    String label = columnName;
    if (column.label is Container) {
      final Container container = column.label as Container;
      if (container.child is Text) {
        final Text textWidget = container.child as Text;
        label = textWidget.data ?? column.columnName;
      }
    }
    super.exportColumnHeader(dataGrid, column, label, pdfGrid);
  }

  @override
  void exportColumnHeaders(
      SfDataGrid dataGrid, List<GridColumn> columns, PdfGrid pdfGrid) {
    // TODO: Add your requirements column headers

    super.exportColumnHeaders(dataGrid, columns, pdfGrid);
  }

  @override
  void exportRows(
      List<GridColumn> columns, List<DataGridRow> rows, PdfGrid pdfGrid) {
    // TODO: Add your requirements in exportRows

    super.exportRows(columns, rows, pdfGrid);
  }

  @override
  void exportRow(List<GridColumn> columns, DataGridRow row, PdfGrid pdfGrid) {
    // TODO: Add your requirements in exportRow

    super.exportRow(columns, row, pdfGrid);
  }
}
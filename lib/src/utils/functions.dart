import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../common_widgets/export/save_file_mobile.dart'
if (dart.library.html) '../common_widgets/export/save_file_web.dart' as helper;

Future<Uint8List> readFontStreamFromAsset(String key) async {
  assert(key.isNotEmpty, 'Asset key cannot be empty');
  final fontData = await rootBundle.load(key);
  return fontData.buffer.asUint8List();
}

Future<void> exportDataGridToPdfStandard ({
    required SfDataGridState dataGridState,
    List<String>? excludeColumns,
    required String title
}) async {
  final ByteData data = await rootBundle.load('images/nut_logo.jpg');
  final fontData = await readFontStreamFromAsset('fonts/NotoNaskhArabic-Regular.ttf');
  final font = PdfTrueTypeFont(fontData, 12);
  final PdfDocument document = dataGridState.exportToPdfDocument(
      excludeColumns: excludeColumns??[],
      fitAllColumnsInOnePage: true,
      cellExport: (DataGridCellPdfExportDetails details) => details.pdfCell.style.font = font,
      headerFooterExport: (DataGridPdfHeaderFooterExportDetails details) {
        final double width = details.pdfPage.getClientSize().width;
        final PdfPageTemplateElement header =
        PdfPageTemplateElement(Rect.fromLTWH(0, 0, width, 65));

        header.graphics.drawImage(
            PdfBitmap(data.buffer
                .asUint8List(data.offsetInBytes, data.lengthInBytes)),
            Rect.fromLTWH(width - 148, 0, 148, 60));

        header.graphics.drawString(
          title,
          PdfStandardFont(PdfFontFamily.helvetica, 13,
              style: PdfFontStyle.bold),
          bounds: const Rect.fromLTWH(0, 25, 200, 60),
        );

        details.pdfDocumentTemplate.top = header;
      });
  final List<int> bytes = document.saveSync();
  await helper.FileSaveHelper.saveAndLaunchFile(bytes, '$title.pdf');
  document.dispose();
}
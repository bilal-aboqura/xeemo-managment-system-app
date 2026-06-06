import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:intl/intl.dart';

import '../models/sales_ticket_model.dart';
import 'supabase_service.dart';

/// Service for exporting tickets to Excel format
class ExcelExportService {
  /// Export a list of tickets to Excel file
  ///
  /// Returns the file path of the exported Excel file
  Future<String> exportTicketsToExcel(List<SalesTicket> tickets) async {
    try {
      SupabaseService.logInfo('Exporting ${tickets.length} tickets to Excel');

      // Create a new Excel workbook
      final Workbook workbook = Workbook();
      final Worksheet sheet = workbook.worksheets[0];
      sheet.name = 'Sales Tickets';

      // Define header style
      final Style headerStyle = workbook.styles.add('HeaderStyle');
      headerStyle.bold = true;
      headerStyle.backColor = '#4285F4';
      headerStyle.fontColor = '#FFFFFF';
      headerStyle.hAlign = HAlignType.center;

      // Define headers
      final headers = [
        'Ticket ID',
        'Client Name',
        'Client Phone',
        'Sale Amount',
        'Worker Notes',
        'Client Notes',
        'Latitude',
        'Longitude',
        'Status',
        'Created At',
        'Worker ID',
      ];

      // Write headers
      for (int i = 0; i < headers.length; i++) {
        final cell = sheet.getRangeByIndex(1, i + 1);
        cell.setText(headers[i]);
        cell.cellStyle = headerStyle;
        cell.columnWidth = 15;
      }

      // Adjust column widths
      sheet.getRangeByIndex(1, 1).columnWidth = 36; // Ticket ID
      sheet.getRangeByIndex(1, 2).columnWidth = 20; // Client Name
      sheet.getRangeByIndex(1, 3).columnWidth = 15; // Client Phone
      sheet.getRangeByIndex(1, 4).columnWidth = 12; // Sale Amount
      sheet.getRangeByIndex(1, 5).columnWidth = 30; // Worker Notes
      sheet.getRangeByIndex(1, 6).columnWidth = 30; // Client Notes
      sheet.getRangeByIndex(1, 10).columnWidth = 20; // Created At
      sheet.getRangeByIndex(1, 11).columnWidth = 36; // Worker ID

      // Date formatter
      final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

      // Write data rows
      for (int row = 0; row < tickets.length; row++) {
        final ticket = tickets[row];
        final rowIndex = row + 2; // Start from row 2 (after header)

        sheet.getRangeByIndex(rowIndex, 1).setText(ticket.ticketId);
        sheet.getRangeByIndex(rowIndex, 2).setText(ticket.clientName);
        sheet.getRangeByIndex(rowIndex, 3).setText(ticket.clientPhone);
        sheet.getRangeByIndex(rowIndex, 4).setNumber(ticket.saleAmount);
        sheet.getRangeByIndex(rowIndex, 5).setText(ticket.workerNotes);
        sheet.getRangeByIndex(rowIndex, 6).setText(ticket.clientNotes);
        sheet.getRangeByIndex(rowIndex, 7).setNumber(ticket.latitude);
        sheet.getRangeByIndex(rowIndex, 8).setNumber(ticket.longitude);
        sheet.getRangeByIndex(rowIndex, 9).setText(ticket.status.name);
        sheet
            .getRangeByIndex(rowIndex, 10)
            .setText(dateFormat.format(ticket.createdAt));
        sheet.getRangeByIndex(rowIndex, 11).setText(ticket.workerId);

        // Format amount as currency
        sheet.getRangeByIndex(rowIndex, 4).numberFormat = '\$#,##0.00';
      }

      // Add totals row
      if (tickets.isNotEmpty) {
        final totalsRow = tickets.length + 2;
        sheet.getRangeByIndex(totalsRow, 3).setText('Total:');
        sheet.getRangeByIndex(totalsRow, 3).cellStyle.bold = true;
        sheet
            .getRangeByIndex(totalsRow, 4)
            .setFormula('=SUM(D2:D${tickets.length + 1})');
        sheet.getRangeByIndex(totalsRow, 4).cellStyle.bold = true;
        sheet.getRangeByIndex(totalsRow, 4).numberFormat = '\$#,##0.00';
      }

      // Save the workbook
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      // Get save directory
      String filePath;
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

      if (Platform.isAndroid) {
        // Request storage permissions
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }

        // Try to use the public Documents directory
        // This is typically /storage/emulated/0/Documents
        final publicDocumentsDir = Directory('/storage/emulated/0/Documents');

        if (await publicDocumentsDir.exists()) {
          filePath =
              '${publicDocumentsDir.path}/tickets_export_$timestamp.xlsx';
        } else {
          // Fallback to app-specific external storage if Documents is not accessible
          final directory = await getExternalStorageDirectory();
          filePath = '${directory?.path ?? ""}/tickets_export_$timestamp.xlsx';
        }
      } else {
        // iOS / Windows / Other
        final directory = await getApplicationDocumentsDirectory();
        filePath = '${directory.path}/tickets_export_$timestamp.xlsx';
      }

      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      SupabaseService.logInfo('Excel exported to: $filePath');
      return filePath;
    } catch (e, stackTrace) {
      SupabaseService.logError('Failed to export Excel', e, stackTrace);
      rethrow;
    }
  }

  /// Share the exported file
  Future<void> shareFile(String filePath) async {
    try {
      await Share.shareXFiles([
        XFile(filePath),
      ], subject: 'Sales Tickets Export');
    } catch (e) {
      SupabaseService.logError('Failed to share file', e);
      rethrow;
    }
  }

  /// Export worker analytics to Excel
  Future<String> exportWorkerAnalytics(List<dynamic> analytics) async {
    try {
      SupabaseService.logInfo('Exporting worker analytics to Excel');

      final Workbook workbook = Workbook();
      final Worksheet sheet = workbook.worksheets[0];
      sheet.name = 'Worker Analytics';

      // Header style
      final Style headerStyle = workbook.styles.add('HeaderStyle2');
      headerStyle.bold = true;
      headerStyle.backColor = '#10B981';
      headerStyle.fontColor = '#FFFFFF';
      headerStyle.hAlign = HAlignType.center;

      // Headers
      final headers = [
        'الترتيب',
        'اسم العامل',
        'عدد الزيارات',
        'إجمالي المبيعات',
        'أعلى منتج',
        'كمية أعلى منتج',
      ];

      for (int i = 0; i < headers.length; i++) {
        final cell = sheet.getRangeByIndex(1, i + 1);
        cell.setText(headers[i]);
        cell.cellStyle = headerStyle;
        cell.columnWidth = 18;
      }

      // Data rows
      for (int row = 0; row < analytics.length; row++) {
        final worker = analytics[row];
        final rowIndex = row + 2;

        sheet.getRangeByIndex(rowIndex, 1).setNumber((row + 1).toDouble());
        sheet.getRangeByIndex(rowIndex, 2).setText(worker.workerName);
        sheet
            .getRangeByIndex(rowIndex, 3)
            .setNumber(worker.ticketCount.toDouble());
        sheet.getRangeByIndex(rowIndex, 4).setNumber(worker.totalSales);

        if (worker.topProducts.isNotEmpty) {
          sheet
              .getRangeByIndex(rowIndex, 5)
              .setText(worker.topProducts.first.productName);
          sheet
              .getRangeByIndex(rowIndex, 6)
              .setNumber(worker.topProducts.first.quantity.toDouble());
        }
      }

      // Save
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      String filePath;
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }

        final publicDocumentsDir = Directory('/storage/emulated/0/Documents');
        if (await publicDocumentsDir.exists()) {
          filePath =
              '${publicDocumentsDir.path}/worker_analytics_$timestamp.xlsx';
        } else {
          final directory = await getExternalStorageDirectory();
          filePath =
              '${directory?.path ?? ""}/worker_analytics_$timestamp.xlsx';
        }
      } else {
        final directory = await getApplicationDocumentsDirectory();
        filePath = '${directory.path}/worker_analytics_$timestamp.xlsx';
      }

      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      SupabaseService.logInfo('Worker analytics exported to: $filePath');
      return filePath;
    } catch (e, stackTrace) {
      SupabaseService.logError(
        'Failed to export worker analytics',
        e,
        stackTrace,
      );
      rethrow;
    }
  }
}

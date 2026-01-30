import 'dart:io';
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
        sheet.getRangeByIndex(rowIndex, 10).setText(dateFormat.format(ticket.createdAt));
        sheet.getRangeByIndex(rowIndex, 11).setText(ticket.workerId);

        // Format amount as currency
        sheet.getRangeByIndex(rowIndex, 4).numberFormat = '\$#,##0.00';
      }

      // Add totals row
      if (tickets.isNotEmpty) {
        final totalsRow = tickets.length + 2;
        sheet.getRangeByIndex(totalsRow, 3).setText('Total:');
        sheet.getRangeByIndex(totalsRow, 3).cellStyle.bold = true;
        sheet.getRangeByIndex(totalsRow, 4).setFormula('=SUM(D2:D${tickets.length + 1})');
        sheet.getRangeByIndex(totalsRow, 4).cellStyle.bold = true;
        sheet.getRangeByIndex(totalsRow, 4).numberFormat = '\$#,##0.00';
      }

      // Save the workbook
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      // Get documents directory and save file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${directory.path}/tickets_export_$timestamp.xlsx';
      
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
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Sales Tickets Export',
      );
    } catch (e) {
      SupabaseService.logError('Failed to share file', e);
      rethrow;
    }
  }
}

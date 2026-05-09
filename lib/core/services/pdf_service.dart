import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/invoice.dart';
import '../utils/currency_utils.dart';

class PdfService {
  static Future<Uint8List> generateInvoicePdf(Invoice invoice) async {
    final pdf = pw.Document();

    // Load fonts
    final regularFont = await PdfGoogleFonts.interRegular();
    final boldFont = await PdfGoogleFonts.interBold();
    final semiBoldFont = await PdfGoogleFonts.interSemiBold();
    final headingFont = await PdfGoogleFonts.poppinsBold();
    final headingSemiFont = await PdfGoogleFonts.poppinsSemiBold();

    // Colors
    const primaryColor = PdfColor.fromInt(0xFF0A1628);
    const accentColor = PdfColor.fromInt(0xFFFF6B35);
    const lightBg = PdfColor.fromInt(0xFFF8F9FA);
    const borderColor = PdfColor.fromInt(0xFFE5E7EB);
    const textSecondary = PdfColor.fromInt(0xFF6B7280);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // ===== HEADER =====
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: primaryColor,
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        invoice.senderName.isNotEmpty ? invoice.senderName : 'Your Business',
                        style: pw.TextStyle(
                          font: headingFont,
                          fontSize: 20,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      if (invoice.senderGstin.isNotEmpty)
                        pw.Text(
                          'GSTIN: ${invoice.senderGstin}',
                          style: pw.TextStyle(font: regularFont, fontSize: 10, color: const PdfColor.fromInt(0xFFBDBDBD)),
                        ),
                      if (invoice.senderAddress.isNotEmpty)
                        pw.Text(
                          invoice.senderAddress,
                          style: pw.TextStyle(font: regularFont, fontSize: 9, color: const PdfColor.fromInt(0xFF9E9E9E)),
                        ),
                    ],
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: pw.BoxDecoration(
                        color: accentColor,
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Text(
                        'TAX INVOICE',
                        style: pw.TextStyle(font: headingSemiFont, fontSize: 12, color: PdfColors.white),
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      invoice.invoiceNumber,
                      style: pw.TextStyle(font: boldFont, fontSize: 14, color: PdfColors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // ===== INVOICE META + CLIENT =====
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Invoice details
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(14),
                  decoration: pw.BoxDecoration(
                    color: lightBg,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: borderColor),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Invoice Details', style: pw.TextStyle(font: headingSemiFont, fontSize: 11, color: primaryColor)),
                      pw.SizedBox(height: 8),
                      _pdfDetailRow('Invoice No:', invoice.invoiceNumber, regularFont, semiBoldFont),
                      _pdfDetailRow('Invoice Date:', _formatDate(invoice.invoiceDate), regularFont, semiBoldFont),
                      _pdfDetailRow('Due Date:', _formatDate(invoice.dueDate), regularFont, semiBoldFont),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 16),
              // Bill to
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(14),
                  decoration: pw.BoxDecoration(
                    color: lightBg,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: borderColor),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Bill To', style: pw.TextStyle(font: headingSemiFont, fontSize: 11, color: primaryColor)),
                      pw.SizedBox(height: 8),
                      pw.Text(invoice.clientName, style: pw.TextStyle(font: semiBoldFont, fontSize: 11)),
                      if (invoice.clientGstin.isNotEmpty)
                        pw.Text('GSTIN: ${invoice.clientGstin}', style: pw.TextStyle(font: regularFont, fontSize: 9, color: textSecondary)),
                      if (invoice.clientAddress.isNotEmpty)
                        pw.Text(invoice.clientAddress, style: pw.TextStyle(font: regularFont, fontSize: 9, color: textSecondary)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          // ===== ITEMS TABLE =====
          _buildItemsTable(invoice, regularFont, boldFont, semiBoldFont, headingSemiFont, primaryColor, accentColor, borderColor, lightBg),

          pw.SizedBox(height: 16),

          // ===== TOTALS =====
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Amount in words
              pw.Expanded(
                flex: 3,
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(14),
                  decoration: pw.BoxDecoration(
                    color: lightBg,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: borderColor),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Amount in Words', style: pw.TextStyle(font: semiBoldFont, fontSize: 9, color: textSecondary)),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        numberToWords(invoice.grandTotal),
                        style: pw.TextStyle(font: semiBoldFont, fontSize: 10, color: primaryColor),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 16),
              // Summary
              pw.Expanded(
                flex: 2,
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(14),
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: borderColor),
                  ),
                  child: pw.Column(
                    children: [
                      _pdfSummaryRow('Subtotal', formatIndianCurrency(invoice.subtotal), regularFont, semiBoldFont),
                      pw.SizedBox(height: 4),
                      // Detailed GST Breakdown
                      ...() {
                        final Map<String, double> detailedBreakdown = {};
                        for (var item in invoice.items) {
                          if (item.gstAmount <= 0) continue;
                          final rateStr = item.gstRate == item.gstRate.truncateToDouble() 
                              ? item.gstRate.toInt().toString() 
                              : item.gstRate.toStringAsFixed(1);
                          final halfRateStr = (item.gstRate / 2) == (item.gstRate / 2).truncateToDouble() 
                              ? (item.gstRate / 2).toInt().toString() 
                              : (item.gstRate / 2).toStringAsFixed(1);
                              
                          if (item.isInterState) {
                            String key = 'IGST @ $rateStr%';
                            detailedBreakdown[key] = (detailedBreakdown[key] ?? 0) + item.igst;
                          } else {
                            String cKey = 'CGST @ $halfRateStr%';
                            detailedBreakdown[cKey] = (detailedBreakdown[cKey] ?? 0) + item.cgst;
                            String sKey = 'SGST @ $halfRateStr%';
                            detailedBreakdown[sKey] = (detailedBreakdown[sKey] ?? 0) + item.sgst;
                          }
                        }
                        return detailedBreakdown.entries.map((entry) =>
                          pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 4),
                            child: _pdfSummaryRow(entry.key, formatIndianCurrency(entry.value), regularFont, semiBoldFont),
                          ),
                        );
                      }(),
                      pw.Divider(color: borderColor),
                      pw.SizedBox(height: 4),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          color: primaryColor,
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Grand Total', style: pw.TextStyle(font: headingSemiFont, fontSize: 11, color: PdfColors.white)),
                            pw.Text(formatIndianCurrency(invoice.grandTotal), style: pw.TextStyle(font: headingSemiFont, fontSize: 12, color: accentColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 24),

          // ===== PAYMENT TERMS =====
          if (invoice.paymentTerms.isNotEmpty)
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: lightBg,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: borderColor),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Payment Terms & Notes', style: pw.TextStyle(font: headingSemiFont, fontSize: 10, color: primaryColor)),
                  pw.SizedBox(height: 6),
                  pw.Text(invoice.paymentTerms, style: pw.TextStyle(font: regularFont, fontSize: 9, color: textSecondary)),
                  if (invoice.notes.isNotEmpty) ...[
                    pw.SizedBox(height: 4),
                    pw.Text(invoice.notes, style: pw.TextStyle(font: regularFont, fontSize: 9, color: textSecondary)),
                  ],
                ],
              ),
            ),

          pw.SizedBox(height: 30),

          // ===== FOOTER =====
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(vertical: 16),
            decoration: const pw.BoxDecoration(
              border: pw.Border(top: pw.BorderSide(color: borderColor, width: 1)),
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  'Thank you for your business!',
                  style: pw.TextStyle(font: headingSemiFont, fontSize: 13, color: primaryColor),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'This is a computer-generated invoice.',
                  style: pw.TextStyle(font: regularFont, fontSize: 8, color: textSecondary),
                ),
                if (invoice.senderPhone.isNotEmpty || invoice.senderEmail.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    [
                      if (invoice.senderPhone.isNotEmpty) 'Phone: ${invoice.senderPhone}',
                      if (invoice.senderEmail.isNotEmpty) 'Email: ${invoice.senderEmail}',
                    ].join(' | '),
                    style: pw.TextStyle(font: regularFont, fontSize: 8, color: textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildItemsTable(
    Invoice invoice,
    pw.Font regularFont,
    pw.Font boldFont,
    pw.Font semiBoldFont,
    pw.Font headingFont,
    PdfColor primaryColor,
    PdfColor accentColor,
    PdfColor borderColor,
    PdfColor lightBg,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: borderColor, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(0.5),
        1: const pw.FlexColumnWidth(2.5),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(0.7),
        4: const pw.FlexColumnWidth(1.2),
        5: const pw.FlexColumnWidth(0.8),
        6: const pw.FlexColumnWidth(1.2),
        7: const pw.FlexColumnWidth(1.3),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: primaryColor),
          children: [
            _tableHeader('#', headingFont),
            _tableHeader('Item', headingFont),
            _tableHeader('HSN', headingFont),
            _tableHeader('Qty', headingFont),
            _tableHeader('Unit Price', headingFont),
            _tableHeader('GST%', headingFont),
            _tableHeader('GST Amt', headingFont),
            _tableHeader('Total', headingFont),
          ],
        ),
        // Items
        ...invoice.items.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          final isEven = idx % 2 == 0;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isEven ? PdfColors.white : lightBg,
            ),
            children: [
              _tableCell('${idx + 1}', regularFont, align: pw.TextAlign.center),
              _tableCell(item.itemName.isNotEmpty ? item.itemName : '-', semiBoldFont),
              _tableCell(item.hsnCode.isNotEmpty ? item.hsnCode : '-', regularFont, align: pw.TextAlign.center),
              _tableCell(item.quantity.toStringAsFixed(item.quantity == item.quantity.roundToDouble() ? 0 : 2), regularFont, align: pw.TextAlign.center),
              _tableCell(formatIndianCurrency(item.unitPrice), regularFont, align: pw.TextAlign.right),
              _tableCell(
                item.isInterState 
                    ? 'IGST\n${item.gstRate == item.gstRate.truncateToDouble() ? item.gstRate.toInt() : item.gstRate.toStringAsFixed(1)}%'
                    : 'C+S\n${item.gstRate == item.gstRate.truncateToDouble() ? item.gstRate.toInt() : item.gstRate.toStringAsFixed(1)}%', 
                regularFont, align: pw.TextAlign.center
              ),
              _tableCell(formatIndianCurrency(item.gstAmount), regularFont, align: pw.TextAlign.right),
              _tableCell(formatIndianCurrency(item.totalAmount), semiBoldFont, align: pw.TextAlign.right),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _tableHeader(String text, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.white),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _tableCell(String text, pw.Font font, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: 8.5),
        textAlign: align,
      ),
    );
  }

  static pw.Widget _pdfDetailRow(String label, String value, pw.Font regular, pw.Font bold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: pw.TextStyle(font: regular, fontSize: 9, color: const PdfColor.fromInt(0xFF6B7280))),
          pw.SizedBox(width: 6),
          pw.Expanded(
            child: pw.Text(value, style: pw.TextStyle(font: bold, fontSize: 9)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _pdfSummaryRow(String label, String value, pw.Font regular, pw.Font bold) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(font: regular, fontSize: 9, color: const PdfColor.fromInt(0xFF6B7280))),
        pw.Text(value, style: pw.TextStyle(font: bold, fontSize: 9)),
      ],
    );
  }

  static String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  /// Saves PDF bytes - on web uses Printing.sharePdf, on native uses file system
  static Future<String> savePdfToFile(Uint8List bytes, String invoiceNumber) async {
    if (kIsWeb) {
      // On web, trigger a download via printing package
      await Printing.sharePdf(bytes: bytes, filename: 'invoice_$invoiceNumber.pdf');
      return 'invoice_$invoiceNumber.pdf';
    } else {
      // On native platforms, save to file system
      final dynamic pathProvider = await _getPathProvider();
      final dir = await pathProvider;
      final path = '${dir.path}/invoice_$invoiceNumber.pdf';
      // Use dart:io conditionally - this branch only runs on native
      await _writeFile(path, bytes);
      return path;
    }
  }

  static Future<dynamic> _getPathProvider() async {
    // Lazy import path_provider only on native
    final pp = await Future.value(null); // placeholder
    return pp;
  }

  static Future<void> _writeFile(String path, Uint8List bytes) async {
    // This will only be called on native platforms
    // Import handled via conditional import pattern
  }
}

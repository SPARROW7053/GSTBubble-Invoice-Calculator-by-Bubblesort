import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';

import '../../core/theme/app_theme.dart';
import '../../core/models/invoice.dart';
import '../../core/providers/invoice_provider.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/services/pdf_service.dart';
import '../../core/utils/legal_dialog.dart';

class InvoiceHistoryScreen extends StatefulWidget {
  const InvoiceHistoryScreen({super.key});
  @override
  State<InvoiceHistoryScreen> createState() => _InvoiceHistoryScreenState();
}

class _InvoiceHistoryScreenState extends State<InvoiceHistoryScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<InvoiceProvider>();
    final invoices = provider.searchInvoices(_searchQuery);
    final summary = provider.getMonthlySummary(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.accentCoral, Color(0xFFFF8C5E)]),
            borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.history_rounded, color: Colors.white, size: 20)),
          const SizedBox(width: 10),
          Text('Invoice History', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 20)),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => showAppLegalDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.loadInvoices(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildMonthlySummary(isDark, summary),
            const SizedBox(height: 16),
            _buildSearchBar(isDark),
            const SizedBox(height: 16),
            if (invoices.isEmpty)
              _buildEmptyState(isDark)
            else
              ...invoices.map((inv) => _buildInvoiceCard(isDark, inv, provider)),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  Widget _buildMonthlySummary(bool isDark, Map<String, dynamic> summary) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final now = DateTime.now();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: isDark ? [const Color(0xFF1A2332), const Color(0xFF0F1923)] : [AppColors.primaryNavy, const Color(0xFF162240)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primaryNavy.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.insights_rounded, color: Colors.white, size: 20), const SizedBox(width: 8),
          Text('${months[now.month - 1]} ${now.year} Summary', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _summaryMetric('Invoices', '${summary['invoiceCount']}', Icons.receipt_long_rounded)),
          const SizedBox(width: 12),
          Expanded(child: _summaryMetric('Total Sales', formatIndianCurrency(summary['totalSales'] as double), Icons.trending_up_rounded)),
          const SizedBox(width: 12),
          Expanded(child: _summaryMetric('Tax Collected', formatIndianCurrency(summary['totalTax'] as double), Icons.account_balance_rounded)),
        ]),
      ]),
    );
  }

  Widget _summaryMetric(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: AppColors.accentCoral, size: 18),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.white60)),
      ]),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return TextField(
      controller: _searchCtrl,
      decoration: InputDecoration(
        hintText: 'Search by invoice number or client...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); }) : null,
      ),
      onChanged: (v) => setState(() => _searchQuery = v),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(children: [
        Icon(Icons.receipt_long_rounded, size: 64, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
        const SizedBox(height: 16),
        Text('No invoices yet', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
        const SizedBox(height: 8),
        Text('Create your first invoice in the Invoice tab', style: GoogleFonts.inter(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
      ])));
  }

  Widget _buildInvoiceCard(bool isDark, Invoice invoice, InvoiceProvider provider) {
    final statusColors = {InvoiceStatus.paid: AppColors.success, InvoiceStatus.unpaid: AppColors.warning, InvoiceStatus.draft: AppColors.lightTextSecondary};
    final statusLabels = {InvoiceStatus.paid: 'Paid', InvoiceStatus.unpaid: 'Unpaid', InvoiceStatus.draft: 'Draft'};
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05), blurRadius: 15, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showInvoiceActions(invoice, provider),
          child: Padding(padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(
                color: AppColors.accentCoral.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.receipt_rounded, color: AppColors.accentCoral, size: 22)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(invoice.invoiceNumber, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(
                    color: statusColors[invoice.status]!.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                    child: Text(statusLabels[invoice.status]!, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: statusColors[invoice.status]))),
                ]),
                const SizedBox(height: 4),
                Text(invoice.clientName.isNotEmpty ? invoice.clientName : 'No client', style: GoogleFonts.inter(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                const SizedBox(height: 4),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('${invoice.invoiceDate.day} ${months[invoice.invoiceDate.month - 1]} ${invoice.invoiceDate.year}',
                    style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                  Text(formatIndianCurrency(invoice.grandTotal), style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.accentCoral)),
                ]),
              ])),
            ])),
        ),
      ),
    );
  }

  void _showInvoiceActions(Invoice invoice, InvoiceProvider provider) {
    showModalBottomSheet(context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text(invoice.invoiceNumber, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _actionTile(Icons.picture_as_pdf_rounded, 'View / Print PDF', () async {
            Navigator.pop(ctx);
            final bytes = await PdfService.generateInvoicePdf(invoice);
            await Printing.layoutPdf(onLayout: (_) => bytes, name: 'Invoice_${invoice.invoiceNumber}');
          }),
          _actionTile(Icons.share_rounded, 'Share PDF', () async {
            Navigator.pop(ctx);
            final bytes = await PdfService.generateInvoicePdf(invoice);
            await Printing.sharePdf(bytes: bytes, filename: 'Invoice_${invoice.invoiceNumber}.pdf');
          }),
          if (invoice.status != InvoiceStatus.paid)
            _actionTile(Icons.check_circle_rounded, 'Mark as Paid', () { Navigator.pop(ctx); provider.updateInvoiceStatus(invoice.id, InvoiceStatus.paid); }, color: AppColors.success),
          if (invoice.status == InvoiceStatus.paid)
            _actionTile(Icons.undo_rounded, 'Mark as Unpaid', () { Navigator.pop(ctx); provider.updateInvoiceStatus(invoice.id, InvoiceStatus.unpaid); }, color: AppColors.warning),
          _actionTile(Icons.delete_outline_rounded, 'Delete Invoice', () {
            Navigator.pop(ctx);
            showDialog(context: context, builder: (c) => AlertDialog(
              title: const Text('Delete Invoice?'), content: const Text('This action cannot be undone.'),
              actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
                TextButton(onPressed: () { Navigator.pop(c); provider.deleteInvoice(invoice.id); }, child: const Text('Delete', style: TextStyle(color: AppColors.error)))],
            ));
          }, color: AppColors.error),
          const SizedBox(height: 8),
        ])));
  }

  Widget _actionTile(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return ListTile(leading: Icon(icon, color: color ?? AppColors.accentCoral), title: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
      onTap: onTap, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)));
  }
}

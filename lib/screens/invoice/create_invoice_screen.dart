import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';

import '../../core/theme/app_theme.dart';
import '../../core/models/invoice.dart';
import '../../core/providers/invoice_provider.dart';
import '../../core/providers/business_provider.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/services/pdf_service.dart';
import '../../core/data/hsn_codes.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});
  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();

  // Client controllers
  final _clientNameCtrl = TextEditingController();
  final _clientGstinCtrl = TextEditingController();
  final _clientAddressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initInvoice());
  }

  void _initInvoice() {
    final invoiceProvider = context.read<InvoiceProvider>();
    final bizProvider = context.read<BusinessProvider>();
    final profile = bizProvider.profile;
    if (invoiceProvider.currentInvoice == null) {
      invoiceProvider.createNewInvoice(
        senderName: profile.businessName, senderGstin: profile.gstin,
        senderAddress: profile.address, senderPhone: profile.phone,
        senderEmail: profile.email, logoPath: profile.logoPath,
      );
    }
  }

  @override
  void dispose() {
    _clientNameCtrl.dispose();
    _clientGstinCtrl.dispose();
    _clientAddressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final invoiceProvider = context.watch<InvoiceProvider>();
    final invoice = invoiceProvider.currentInvoice;

    return Scaffold(
      appBar: AppBar(
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.accentCoral, Color(0xFFFF8C5E)]),
            borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 20)),
          const SizedBox(width: 10),
          Text('Create Invoice', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 20)),
        ]),
        actions: [
          if (invoice != null)
            TextButton.icon(
              onPressed: () => _resetInvoice(invoiceProvider),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('New'),
            ),
        ],
      ),
      body: invoice == null
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildSenderCard(isDark, invoice),
                  const SizedBox(height: 16),
                  _buildClientCard(isDark, invoiceProvider),
                  const SizedBox(height: 16),
                  _buildInvoiceDetailsCard(isDark, invoice, invoiceProvider),
                  const SizedBox(height: 16),
                  _buildLineItemsSection(isDark, invoice, invoiceProvider),
                  const SizedBox(height: 16),
                  _buildSummaryCard(isDark, invoice),
                  const SizedBox(height: 16),
                  _buildPaymentTermsCard(isDark, invoice, invoiceProvider),
                  const SizedBox(height: 20),
                  _buildGenerateButton(invoice, invoiceProvider),
                  const SizedBox(height: 30),
                ]),
              ),
            ),
    );
  }

  Widget _sectionCard(bool isDark, {required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: AppColors.accentCoral, size: 20),
          const SizedBox(width: 8),
          Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 16),
        ...children,
      ]),
    );
  }

  Widget _buildSenderCard(bool isDark, Invoice invoice) {
    return _sectionCard(isDark, title: 'From (Your Business)', icon: Icons.business_rounded, children: [
      if (invoice.senderName.isNotEmpty) ...[
        Text(invoice.senderName, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
        if (invoice.senderGstin.isNotEmpty) Text('GSTIN: ${invoice.senderGstin}', style: GoogleFonts.inter(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
        if (invoice.senderAddress.isNotEmpty) Text(invoice.senderAddress, style: GoogleFonts.inter(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
      ] else
        Text('Set up your business profile in the Business tab', style: GoogleFonts.inter(fontSize: 13, color: AppColors.accentCoral, fontStyle: FontStyle.italic)),
    ]);
  }

  Widget _buildClientCard(bool isDark, InvoiceProvider invoiceProvider) {
    final clients = context.watch<BusinessProvider>().clients;
    return _sectionCard(isDark, title: 'Bill To (Client)', icon: Icons.person_rounded, children: [
      if (clients.isNotEmpty) ...[
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(hintText: 'Select saved client'),
          items: [
            const DropdownMenuItem(value: '', child: Text('New Client')),
            ...clients.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
          ],
          onChanged: (id) {
            if (id == null || id.isEmpty) { _clientNameCtrl.clear(); _clientGstinCtrl.clear(); _clientAddressCtrl.clear(); return; }
            final client = clients.firstWhere((c) => c.id == id);
            _clientNameCtrl.text = client.name; _clientGstinCtrl.text = client.gstin; _clientAddressCtrl.text = client.address;
            invoiceProvider.updateCurrentInvoiceClient(clientName: client.name, clientGstin: client.gstin, clientAddress: client.address, clientId: client.id);
          },
        ),
        const SizedBox(height: 12),
      ],
      TextField(controller: _clientNameCtrl, decoration: const InputDecoration(hintText: 'Client Name', prefixIcon: Icon(Icons.person_outline)),
        onChanged: (v) => invoiceProvider.updateCurrentInvoiceClient(clientName: v, clientGstin: _clientGstinCtrl.text, clientAddress: _clientAddressCtrl.text)),
      const SizedBox(height: 10),
      TextField(controller: _clientGstinCtrl, decoration: const InputDecoration(hintText: 'Client GSTIN', prefixIcon: Icon(Icons.numbers)),
        onChanged: (v) => invoiceProvider.updateCurrentInvoiceClient(clientName: _clientNameCtrl.text, clientGstin: v, clientAddress: _clientAddressCtrl.text)),
      const SizedBox(height: 10),
      TextField(controller: _clientAddressCtrl, decoration: const InputDecoration(hintText: 'Client Address', prefixIcon: Icon(Icons.location_on_outlined)), maxLines: 2,
        onChanged: (v) => invoiceProvider.updateCurrentInvoiceClient(clientName: _clientNameCtrl.text, clientGstin: _clientGstinCtrl.text, clientAddress: v)),
    ]);
  }

  Widget _buildInvoiceDetailsCard(bool isDark, Invoice invoice, InvoiceProvider provider) {
    return _sectionCard(isDark, title: 'Invoice Details', icon: Icons.description_rounded, children: [
      Row(children: [
        Expanded(child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: isDark ? AppColors.darkInputBg : AppColors.lightInputBg, borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Invoice No.', style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
            const SizedBox(height: 4),
            Text(invoice.invoiceNumber, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.accentCoral)),
          ]))),
        const SizedBox(width: 12),
        Expanded(child: _datePickerField(isDark, 'Invoice Date', invoice.invoiceDate, (d) => provider.updateInvoiceDates(invoiceDate: d))),
      ]),
      const SizedBox(height: 10),
      _datePickerField(isDark, 'Due Date', invoice.dueDate, (d) => provider.updateInvoiceDates(dueDate: d)),
    ]);
  }

  Widget _datePickerField(bool isDark, String label, DateTime date, Function(DateTime) onChanged) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime(2030));
        if (picked != null) onChanged(picked);
      },
      child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: isDark ? AppColors.darkInputBg : AppColors.lightInputBg, borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.accentCoral),
            const SizedBox(width: 6),
            Text('${date.day} ${months[date.month - 1]} ${date.year}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
          ]),
        ])),
    );
  }

  Widget _buildLineItemsSection(bool isDark, Invoice invoice, InvoiceProvider provider) {
    return _sectionCard(isDark, title: 'Line Items (${invoice.items.length})', icon: Icons.list_alt_rounded, children: [
      ...invoice.items.asMap().entries.map((entry) => _buildLineItem(isDark, entry.key, entry.value, provider)),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, child: OutlinedButton.icon(
        onPressed: () => provider.addItemToInvoice(InvoiceItem()),
        icon: const Icon(Icons.add_rounded), label: const Text('Add Item'),
        style: OutlinedButton.styleFrom(foregroundColor: AppColors.accentCoral, side: const BorderSide(color: AppColors.accentCoral),
          padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      )),
    ]);
  }

  Widget _buildLineItem(bool isDark, int index, InvoiceItem item, InvoiceProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.accentCoral.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Text('#${index + 1}', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accentCoral))),
          const Spacer(),
          if (provider.currentInvoice!.items.length > 1)
            IconButton(icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20), onPressed: () => provider.removeInvoiceItem(index)),
        ]),
        const SizedBox(height: 10),
        TextField(decoration: const InputDecoration(hintText: 'Item Name', prefixIcon: Icon(Icons.inventory_2_outlined, size: 20)),
          controller: TextEditingController(text: item.itemName)..selection = TextSelection.collapsed(offset: item.itemName.length),
          onChanged: (v) => provider.updateInvoiceItem(index, item.copyWith(itemName: v))),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: TextField(
            decoration: InputDecoration(hintText: 'HSN Code', prefixIcon: const Icon(Icons.tag, size: 20),
              suffixIcon: IconButton(icon: const Icon(Icons.help_outline_rounded, size: 18, color: AppColors.accentCoral), onPressed: () => _showHsnHelper(index, item, provider))),
            controller: TextEditingController(text: item.hsnCode)..selection = TextSelection.collapsed(offset: item.hsnCode.length),
            onChanged: (v) => provider.updateInvoiceItem(index, item.copyWith(hsnCode: v)))),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: TextField(decoration: const InputDecoration(hintText: 'Qty'), keyboardType: TextInputType.number,
            controller: TextEditingController(text: item.quantity > 0 ? item.quantity.toString() : '')..selection = TextSelection.collapsed(offset: (item.quantity > 0 ? item.quantity.toString() : '').length),
            onChanged: (v) => provider.updateInvoiceItem(index, item.copyWith(quantity: double.tryParse(v) ?? 1)))),
          const SizedBox(width: 8),
          Expanded(child: TextField(decoration: const InputDecoration(hintText: 'Unit Price ₹'), keyboardType: TextInputType.number,
            controller: TextEditingController(text: item.unitPrice > 0 ? item.unitPrice.toString() : '')..selection = TextSelection.collapsed(offset: (item.unitPrice > 0 ? item.unitPrice.toString() : '').length),
            onChanged: (v) => provider.updateInvoiceItem(index, item.copyWith(unitPrice: double.tryParse(v) ?? 0)))),
          const SizedBox(width: 8),
          SizedBox(width: 80, child: TextField(decoration: const InputDecoration(hintText: 'GST %', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)), keyboardType: const TextInputType.numberWithOptions(decimal: true),
            controller: TextEditingController(text: item.gstRate.toString())..selection = TextSelection.collapsed(offset: item.gstRate.toString().length),
            onChanged: (v) => provider.updateInvoiceItem(index, item.copyWith(gstRate: double.tryParse(v) ?? 0)))),
        ]),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Amount: ${formatIndianCurrency(item.totalAmount)}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.accentCoral)),
          Row(children: [
            Text('Inter-state', style: GoogleFonts.inter(fontSize: 11)),
            Switch(value: item.isInterState, onChanged: (v) => provider.updateInvoiceItem(index, item.copyWith(isInterState: v)),
              activeThumbColor: AppColors.accentCoral, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
          ]),
        ]),
      ]),
    );
  }

  Widget _buildSummaryCard(bool isDark, Invoice invoice) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: isDark ? [const Color(0xFF1A2332), const Color(0xFF0F1923)] : [AppColors.primaryNavy, const Color(0xFF162240)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primaryNavy.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(children: [
        Row(children: [
          const Icon(Icons.summarize_rounded, color: Colors.white, size: 20), const SizedBox(width: 8),
          Text('Invoice Summary', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        ]),
        const SizedBox(height: 16),
        _summaryRow('Subtotal', formatIndianCurrency(invoice.subtotal)),
        ...invoice.gstBreakdown.entries.map((e) => _summaryRow('GST @ ${e.key.toStringAsFixed(0)}%', formatIndianCurrency(e.value))),
        if (invoice.totalCgst > 0) _summaryRow('Total CGST', formatIndianCurrency(invoice.totalCgst)),
        if (invoice.totalSgst > 0) _summaryRow('Total SGST', formatIndianCurrency(invoice.totalSgst)),
        if (invoice.totalIgst > 0) _summaryRow('Total IGST', formatIndianCurrency(invoice.totalIgst)),
        const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(color: Colors.white24)),
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Grand Total', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
            Text(formatIndianCurrency(invoice.grandTotal), style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.accentCoral)),
          ])),
        const SizedBox(height: 8),
        Text(numberToWords(invoice.grandTotal), style: GoogleFonts.inter(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.white60), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
        Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
      ]));
  }

  Widget _buildPaymentTermsCard(bool isDark, Invoice invoice, InvoiceProvider provider) {
    return _sectionCard(isDark, title: 'Payment Terms', icon: Icons.payment_rounded, children: [
      TextField(maxLines: 3, decoration: const InputDecoration(hintText: 'Payment terms...'),
        controller: TextEditingController(text: invoice.paymentTerms),
        onChanged: (v) => provider.updatePaymentTerms(v)),
    ]);
  }

  Widget _buildGenerateButton(Invoice invoice, InvoiceProvider provider) {
    return SizedBox(width: double.infinity, child: ElevatedButton.icon(
      onPressed: () => _generateInvoice(invoice, provider),
      icon: const Icon(Icons.picture_as_pdf_rounded),
      label: const Text('Generate Invoice PDF'),
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
    ));
  }

  Future<void> _generateInvoice(Invoice invoice, InvoiceProvider provider) async {
    try {
      await provider.saveInvoice();
      final pdfBytes = await PdfService.generateInvoicePdf(invoice);
      if (!mounted) return;
      await Printing.layoutPdf(onLayout: (_) => pdfBytes, name: 'Invoice_${invoice.invoiceNumber}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    }
  }

  void _showHsnHelper(int itemIndex, InvoiceItem item, InvoiceProvider provider) {
    final searchCtrl = TextEditingController();
    showModalBottomSheet(context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheetState) {
        final query = searchCtrl.text.toLowerCase();
        final filtered = commonHsnCodes.where((h) => h.code.contains(query) || h.description.toLowerCase().contains(query) || h.category.toLowerCase().contains(query)).toList();
        return DraggableScrollableSheet(initialChildSize: 0.7, maxChildSize: 0.9, minChildSize: 0.5, expand: false,
          builder: (_, ctrl) => Column(children: [
            Padding(padding: const EdgeInsets.all(16), child: Column(children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 12),
              Text('HSN Code Lookup', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              TextField(controller: searchCtrl, decoration: const InputDecoration(hintText: 'Search by code, name or category...', prefixIcon: Icon(Icons.search)),
                onChanged: (_) => setSheetState(() {})),
            ])),
            Expanded(child: ListView.builder(controller: ctrl, itemCount: filtered.length, itemBuilder: (_, i) {
              final hsn = filtered[i];
              return ListTile(
                leading: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppColors.accentCoral.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(hsn.code, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.accentCoral, fontSize: 13))),
                title: Text(hsn.description, style: GoogleFonts.inter(fontSize: 13)),
                subtitle: Text(hsn.category, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
                onTap: () { provider.updateInvoiceItem(itemIndex, item.copyWith(hsnCode: hsn.code)); Navigator.pop(ctx); },
              );
            })),
          ]));
      }));
  }

  void _resetInvoice(InvoiceProvider provider) {
    final bizProvider = context.read<BusinessProvider>();
    final profile = bizProvider.profile;
    _clientNameCtrl.clear(); _clientGstinCtrl.clear(); _clientAddressCtrl.clear();
    provider.createNewInvoice(senderName: profile.businessName, senderGstin: profile.gstin,
      senderAddress: profile.address, senderPhone: profile.phone, senderEmail: profile.email, logoPath: profile.logoPath);
  }
}

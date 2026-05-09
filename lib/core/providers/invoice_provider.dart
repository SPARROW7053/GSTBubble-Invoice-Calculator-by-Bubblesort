import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../services/database_service.dart';

class InvoiceProvider extends ChangeNotifier {
  final DatabaseService _dbService;
  List<Invoice> _invoices = [];
  Invoice? _currentInvoice;
  bool _isLoading = false;

  InvoiceProvider(this._dbService) {
    loadInvoices();
  }

  // Getters
  List<Invoice> get invoices => _invoices;
  Invoice? get currentInvoice => _currentInvoice;
  bool get isLoading => _isLoading;

  Future<void> loadInvoices() async {
    _isLoading = true;
    notifyListeners();

    _invoices = await _dbService.getAllInvoices();

    _isLoading = false;
    notifyListeners();
  }

  void createNewInvoice({
    required String senderName,
    required String senderGstin,
    required String senderAddress,
    required String senderPhone,
    required String senderEmail,
    String? logoPath,
  }) {
    final profile = _dbService.getBusinessProfile();
    final invoiceNumber = profile.nextInvoiceNumberFormatted;

    _currentInvoice = Invoice(
      invoiceNumber: invoiceNumber,
      senderName: senderName,
      senderGstin: senderGstin,
      senderAddress: senderAddress,
      senderPhone: senderPhone,
      senderEmail: senderEmail,
      logoPath: logoPath,
      paymentTerms: profile.paymentTerms,
    );
    notifyListeners();
  }

  void setCurrentInvoice(Invoice invoice) {
    _currentInvoice = invoice;
    notifyListeners();
  }

  void updateCurrentInvoiceClient({
    required String clientName,
    required String clientGstin,
    required String clientAddress,
    String? clientId,
  }) {
    if (_currentInvoice == null) return;
    _currentInvoice!.clientName = clientName;
    _currentInvoice!.clientGstin = clientGstin;
    _currentInvoice!.clientAddress = clientAddress;
    _currentInvoice!.clientId = clientId;
    notifyListeners();
  }

  void addItemToInvoice(InvoiceItem item) {
    if (_currentInvoice == null) return;
    _currentInvoice!.items.add(item);
    notifyListeners();
  }

  void updateInvoiceItem(int index, InvoiceItem item) {
    if (_currentInvoice == null || index >= _currentInvoice!.items.length) return;
    _currentInvoice!.items[index] = item;
    notifyListeners();
  }

  void removeInvoiceItem(int index) {
    if (_currentInvoice == null || _currentInvoice!.items.length <= 1) return;
    _currentInvoice!.items.removeAt(index);
    notifyListeners();
  }

  void updateInvoiceDates({DateTime? invoiceDate, DateTime? dueDate}) {
    if (_currentInvoice == null) return;
    if (invoiceDate != null) _currentInvoice!.invoiceDate = invoiceDate;
    if (dueDate != null) _currentInvoice!.dueDate = dueDate;
    notifyListeners();
  }

  void updatePaymentTerms(String terms) {
    if (_currentInvoice == null) return;
    _currentInvoice!.paymentTerms = terms;
    notifyListeners();
  }

  void updateNotes(String notes) {
    if (_currentInvoice == null) return;
    _currentInvoice!.notes = notes;
    notifyListeners();
  }

  Future<void> saveInvoice() async {
    if (_currentInvoice == null) return;

    // Check if invoice already exists
    final existing = await _dbService.getInvoice(_currentInvoice!.id);
    if (existing != null) {
      await _dbService.updateInvoice(_currentInvoice!);
    } else {
      _currentInvoice!.status = InvoiceStatus.unpaid;
      await _dbService.insertInvoice(_currentInvoice!);
      await _dbService.incrementInvoiceNumber();
    }

    await loadInvoices();
  }

  Future<void> updateInvoiceStatus(String id, InvoiceStatus status) async {
    await _dbService.updateInvoiceStatus(id, status);
    await loadInvoices();
  }

  Future<void> deleteInvoice(String id) async {
    await _dbService.deleteInvoice(id);
    await loadInvoices();
  }

  // Add item from calculator
  void addItemFromCalculator({
    required double baseAmount,
    required double gstRate,
    required bool isInterState,
  }) {
    if (_currentInvoice == null) {
      final profile = _dbService.getBusinessProfile();
      createNewInvoice(
        senderName: profile.businessName,
        senderGstin: profile.gstin,
        senderAddress: profile.address,
        senderPhone: profile.phone,
        senderEmail: profile.email,
        logoPath: profile.logoPath,
      );
    }

    final item = InvoiceItem(
      unitPrice: baseAmount,
      gstRate: gstRate,
      isInterState: isInterState,
      quantity: 1,
    );

    addItemToInvoice(item);
  }

  // Monthly summary for history
  Map<String, dynamic> getMonthlySummary(DateTime month) {
    final monthInvoices = _invoices.where((inv) =>
        inv.invoiceDate.year == month.year &&
        inv.invoiceDate.month == month.month &&
        inv.status != InvoiceStatus.draft).toList();

    double totalSales = 0;
    double totalTax = 0;

    for (final inv in monthInvoices) {
      totalSales += inv.subtotal;
      totalTax += inv.totalGst;
    }

    return {
      'invoiceCount': monthInvoices.length,
      'totalSales': totalSales,
      'totalTax': totalTax,
      'totalAmount': totalSales + totalTax,
    };
  }

  List<Invoice> searchInvoices(String query) {
    if (query.isEmpty) return _invoices;
    final q = query.toLowerCase();
    return _invoices.where((inv) =>
        inv.invoiceNumber.toLowerCase().contains(q) ||
        inv.clientName.toLowerCase().contains(q)).toList();
  }
}

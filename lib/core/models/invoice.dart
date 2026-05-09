import 'package:uuid/uuid.dart';

class InvoiceItem {
  final String id;
  String itemName;
  String hsnCode;
  double quantity;
  double unitPrice;
  double gstRate;
  bool isInterState;

  InvoiceItem({
    String? id,
    this.itemName = '',
    this.hsnCode = '',
    this.quantity = 1,
    this.unitPrice = 0,
    this.gstRate = 18,
    this.isInterState = false,
  }) : id = id ?? const Uuid().v4();

  double get amount => quantity * unitPrice;
  double get gstAmount => amount * gstRate / 100;
  double get cgst => isInterState ? 0 : gstAmount / 2;
  double get sgst => isInterState ? 0 : gstAmount / 2;
  double get igst => isInterState ? gstAmount : 0;
  double get totalAmount => amount + gstAmount;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemName': itemName,
      'hsnCode': hsnCode,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'gstRate': gstRate,
      'isInterState': isInterState ? 1 : 0,
    };
  }

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      id: map['id'] as String,
      itemName: map['itemName'] as String? ?? '',
      hsnCode: map['hsnCode'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 1,
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0,
      gstRate: (map['gstRate'] as num?)?.toDouble() ?? 18,
      isInterState: (map['isInterState'] as int?) == 1,
    );
  }

  InvoiceItem copyWith({
    String? itemName,
    String? hsnCode,
    double? quantity,
    double? unitPrice,
    double? gstRate,
    bool? isInterState,
  }) {
    return InvoiceItem(
      id: id,
      itemName: itemName ?? this.itemName,
      hsnCode: hsnCode ?? this.hsnCode,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      gstRate: gstRate ?? this.gstRate,
      isInterState: isInterState ?? this.isInterState,
    );
  }
}

enum InvoiceStatus { draft, unpaid, paid }

class Invoice {
  final String id;
  String invoiceNumber;
  DateTime invoiceDate;
  DateTime dueDate;
  
  // Sender
  String senderName;
  String senderGstin;
  String senderAddress;
  String senderPhone;
  String senderEmail;
  
  // Client
  String clientName;
  String clientGstin;
  String clientAddress;
  String? clientId;
  
  // Items
  List<InvoiceItem> items;
  
  // Status
  InvoiceStatus status;
  
  // Payment terms
  String paymentTerms;
  String notes;
  
  // Logo path
  String? logoPath;

  Invoice({
    String? id,
    this.invoiceNumber = '',
    DateTime? invoiceDate,
    DateTime? dueDate,
    this.senderName = '',
    this.senderGstin = '',
    this.senderAddress = '',
    this.senderPhone = '',
    this.senderEmail = '',
    this.clientName = '',
    this.clientGstin = '',
    this.clientAddress = '',
    this.clientId,
    List<InvoiceItem>? items,
    this.status = InvoiceStatus.draft,
    this.paymentTerms = 'Payment due within 30 days',
    this.notes = '',
    this.logoPath,
  })  : id = id ?? const Uuid().v4(),
        invoiceDate = invoiceDate ?? DateTime.now(),
        dueDate = dueDate ?? DateTime.now().add(const Duration(days: 30)),
        items = items ?? [InvoiceItem()];

  double get subtotal => items.fold(0, (sum, item) => sum + item.amount);
  double get totalCgst => items.fold(0, (sum, item) => sum + item.cgst);
  double get totalSgst => items.fold(0, (sum, item) => sum + item.sgst);
  double get totalIgst => items.fold(0, (sum, item) => sum + item.igst);
  double get totalGst => items.fold(0, (sum, item) => sum + item.gstAmount);
  double get grandTotal => items.fold(0, (sum, item) => sum + item.totalAmount);

  /// Returns a map of GST rates to their total tax amounts
  Map<double, double> get gstBreakdown {
    final Map<double, double> breakdown = {};
    for (final item in items) {
      breakdown[item.gstRate] = (breakdown[item.gstRate] ?? 0) + item.gstAmount;
    }
    return breakdown;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'invoiceDate': invoiceDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'senderName': senderName,
      'senderGstin': senderGstin,
      'senderAddress': senderAddress,
      'senderPhone': senderPhone,
      'senderEmail': senderEmail,
      'clientName': clientName,
      'clientGstin': clientGstin,
      'clientAddress': clientAddress,
      'clientId': clientId,
      'status': status.index,
      'paymentTerms': paymentTerms,
      'notes': notes,
      'logoPath': logoPath,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map, List<InvoiceItem> items) {
    return Invoice(
      id: map['id'] as String,
      invoiceNumber: map['invoiceNumber'] as String? ?? '',
      invoiceDate: DateTime.tryParse(map['invoiceDate'] as String? ?? '') ?? DateTime.now(),
      dueDate: DateTime.tryParse(map['dueDate'] as String? ?? '') ?? DateTime.now().add(const Duration(days: 30)),
      senderName: map['senderName'] as String? ?? '',
      senderGstin: map['senderGstin'] as String? ?? '',
      senderAddress: map['senderAddress'] as String? ?? '',
      senderPhone: map['senderPhone'] as String? ?? '',
      senderEmail: map['senderEmail'] as String? ?? '',
      clientName: map['clientName'] as String? ?? '',
      clientGstin: map['clientGstin'] as String? ?? '',
      clientAddress: map['clientAddress'] as String? ?? '',
      clientId: map['clientId'] as String?,
      items: items,
      status: InvoiceStatus.values[(map['status'] as int?) ?? 0],
      paymentTerms: map['paymentTerms'] as String? ?? 'Payment due within 30 days',
      notes: map['notes'] as String? ?? '',
      logoPath: map['logoPath'] as String?,
    );
  }
}

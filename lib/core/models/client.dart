import 'package:uuid/uuid.dart';

class Client {
  final String id;
  String name;
  String gstin;
  String address;
  String phone;
  String email;

  Client({
    String? id,
    this.name = '',
    this.gstin = '',
    this.address = '',
    this.phone = '',
    this.email = '',
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'gstin': gstin,
      'address': address,
      'phone': phone,
      'email': email,
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      gstin: map['gstin'] as String? ?? '',
      address: map['address'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
    );
  }
}

class BusinessProfile {
  String businessName;
  String ownerName;
  String gstin;
  String pan;
  String phone;
  String email;
  String address;
  String? logoPath;
  String invoicePrefix;
  int nextInvoiceNumber;
  double defaultGstRate;
  String currency;
  String paymentTerms;

  BusinessProfile({
    this.businessName = '',
    this.ownerName = '',
    this.gstin = '',
    this.pan = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.logoPath,
    this.invoicePrefix = 'INV',
    this.nextInvoiceNumber = 1,
    this.defaultGstRate = 18,
    this.currency = 'INR',
    this.paymentTerms = 'Payment due within 30 days of invoice date.\nBank transfer preferred.',
  });

  String get nextInvoiceNumberFormatted => 
    '$invoicePrefix-${nextInvoiceNumber.toString().padLeft(4, '0')}';

  Map<String, dynamic> toMap() {
    return {
      'businessName': businessName,
      'ownerName': ownerName,
      'gstin': gstin,
      'pan': pan,
      'phone': phone,
      'email': email,
      'address': address,
      'logoPath': logoPath,
      'invoicePrefix': invoicePrefix,
      'nextInvoiceNumber': nextInvoiceNumber,
      'defaultGstRate': defaultGstRate,
      'currency': currency,
      'paymentTerms': paymentTerms,
    };
  }

  factory BusinessProfile.fromMap(Map<String, dynamic> map) {
    return BusinessProfile(
      businessName: map['businessName'] as String? ?? '',
      ownerName: map['ownerName'] as String? ?? '',
      gstin: map['gstin'] as String? ?? '',
      pan: map['pan'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      address: map['address'] as String? ?? '',
      logoPath: map['logoPath'] as String?,
      invoicePrefix: map['invoicePrefix'] as String? ?? 'INV',
      nextInvoiceNumber: map['nextInvoiceNumber'] as int? ?? 1,
      defaultGstRate: (map['defaultGstRate'] as num?)?.toDouble() ?? 18,
      currency: map['currency'] as String? ?? 'INR',
      paymentTerms: map['paymentTerms'] as String? ?? 'Payment due within 30 days of invoice date.\nBank transfer preferred.',
    );
  }
}

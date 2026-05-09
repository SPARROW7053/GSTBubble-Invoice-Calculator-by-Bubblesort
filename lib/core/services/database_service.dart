import 'package:hive_flutter/hive_flutter.dart';
import '../models/invoice.dart';
import '../models/client.dart';

class DatabaseService {
  static Box? _settingsBox;
  static Box? _invoicesBox;
  static Box? _invoiceItemsBox;
  static Box? _clientsBox;

  Future<void> initialize() async {
    _settingsBox = await Hive.openBox('settings');
    _invoicesBox = await Hive.openBox('invoices');
    _invoiceItemsBox = await Hive.openBox('invoice_items');
    _clientsBox = await Hive.openBox('clients');
  }

  Box get settingsBox {
    if (_settingsBox == null) throw Exception('Settings box not initialized');
    return _settingsBox!;
  }

  Box get invoicesBox {
    if (_invoicesBox == null) throw Exception('Invoices box not initialized');
    return _invoicesBox!;
  }

  Box get invoiceItemsBox {
    if (_invoiceItemsBox == null) throw Exception('Invoice items box not initialized');
    return _invoiceItemsBox!;
  }

  Box get clientsBox {
    if (_clientsBox == null) throw Exception('Clients box not initialized');
    return _clientsBox!;
  }

  // ========== Business Profile ==========

  Future<void> saveBusinessProfile(BusinessProfile profile) async {
    await settingsBox.put('businessProfile', profile.toMap());
  }

  BusinessProfile getBusinessProfile() {
    final data = settingsBox.get('businessProfile');
    if (data == null) return BusinessProfile();
    return BusinessProfile.fromMap(Map<String, dynamic>.from(data as Map));
  }

  // ========== Invoices ==========

  Future<void> insertInvoice(Invoice invoice) async {
    // Store invoice data
    await invoicesBox.put(invoice.id, invoice.toMap());

    // Store items keyed by invoiceId
    final itemsList = invoice.items.map((item) {
      final map = item.toMap();
      map['invoiceId'] = invoice.id;
      return map;
    }).toList();
    await invoiceItemsBox.put(invoice.id, itemsList);
  }

  Future<void> updateInvoice(Invoice invoice) async {
    await insertInvoice(invoice); // put replaces existing
  }

  Future<void> deleteInvoice(String id) async {
    await invoicesBox.delete(id);
    await invoiceItemsBox.delete(id);
  }

  Future<List<Invoice>> getAllInvoices() async {
    final invoices = <Invoice>[];

    for (final key in invoicesBox.keys) {
      final data = invoicesBox.get(key);
      if (data == null) continue;

      final map = Map<String, dynamic>.from(data as Map);
      final itemsRaw = invoiceItemsBox.get(key);
      final items = <InvoiceItem>[];

      if (itemsRaw != null && itemsRaw is List) {
        for (final itemData in itemsRaw) {
          items.add(InvoiceItem.fromMap(Map<String, dynamic>.from(itemData as Map)));
        }
      }

      invoices.add(Invoice.fromMap(map, items));
    }

    // Sort by date descending
    invoices.sort((a, b) => b.invoiceDate.compareTo(a.invoiceDate));
    return invoices;
  }

  Future<Invoice?> getInvoice(String id) async {
    final data = invoicesBox.get(id);
    if (data == null) return null;

    final map = Map<String, dynamic>.from(data as Map);
    final itemsRaw = invoiceItemsBox.get(id);
    final items = <InvoiceItem>[];

    if (itemsRaw != null && itemsRaw is List) {
      for (final itemData in itemsRaw) {
        items.add(InvoiceItem.fromMap(Map<String, dynamic>.from(itemData as Map)));
      }
    }

    return Invoice.fromMap(map, items);
  }

  Future<void> updateInvoiceStatus(String id, InvoiceStatus status) async {
    final data = invoicesBox.get(id);
    if (data == null) return;

    final map = Map<String, dynamic>.from(data as Map);
    map['status'] = status.index;
    await invoicesBox.put(id, map);
  }

  // ========== Clients ==========

  Future<void> insertClient(Client client) async {
    await clientsBox.put(client.id, client.toMap());
  }

  Future<void> updateClient(Client client) async {
    await clientsBox.put(client.id, client.toMap());
  }

  Future<void> deleteClient(String id) async {
    await clientsBox.delete(id);
  }

  Future<List<Client>> getAllClients() async {
    final clients = <Client>[];
    for (final key in clientsBox.keys) {
      final data = clientsBox.get(key);
      if (data != null) {
        clients.add(Client.fromMap(Map<String, dynamic>.from(data as Map)));
      }
    }
    clients.sort((a, b) => a.name.compareTo(b.name));
    return clients;
  }

  // ========== Settings ==========

  Future<void> saveSetting(String key, dynamic value) async {
    await settingsBox.put(key, value);
  }

  dynamic getSetting(String key, {dynamic defaultValue}) {
    return settingsBox.get(key, defaultValue: defaultValue);
  }

  // ========== Invoice Counter ==========

  int getNextInvoiceNumber() {
    final profile = getBusinessProfile();
    return profile.nextInvoiceNumber;
  }

  Future<void> incrementInvoiceNumber() async {
    final profile = getBusinessProfile();
    profile.nextInvoiceNumber += 1;
    await saveBusinessProfile(profile);
  }
}

import 'package:flutter/material.dart';
import '../models/client.dart';
import '../services/database_service.dart';

class BusinessProvider extends ChangeNotifier {
  final DatabaseService _dbService;
  late BusinessProfile _profile;
  List<Client> _clients = [];
  bool _isLoading = false;

  BusinessProvider(this._dbService) {
    _profile = _dbService.getBusinessProfile();
    loadClients();
  }

  // Getters
  BusinessProfile get profile => _profile;
  List<Client> get clients => _clients;
  bool get isLoading => _isLoading;

  Future<void> loadClients() async {
    _isLoading = true;
    notifyListeners();

    _clients = await _dbService.getAllClients();

    _isLoading = false;
    notifyListeners();
  }

  void refreshProfile() {
    _profile = _dbService.getBusinessProfile();
    notifyListeners();
  }

  Future<void> saveProfile(BusinessProfile profile) async {
    await _dbService.saveBusinessProfile(profile);
    _profile = profile;
    notifyListeners();
  }

  Future<void> updateProfileField(String field, dynamic value) async {
    switch (field) {
      case 'businessName':
        _profile.businessName = value as String;
        break;
      case 'ownerName':
        _profile.ownerName = value as String;
        break;
      case 'gstin':
        _profile.gstin = value as String;
        break;
      case 'pan':
        _profile.pan = value as String;
        break;
      case 'phone':
        _profile.phone = value as String;
        break;
      case 'email':
        _profile.email = value as String;
        break;
      case 'address':
        _profile.address = value as String;
        break;
      case 'logoPath':
        _profile.logoPath = value as String?;
        break;
      case 'invoicePrefix':
        _profile.invoicePrefix = value as String;
        break;
      case 'defaultGstRate':
        _profile.defaultGstRate = value as double;
        break;
      case 'currency':
        _profile.currency = value as String;
        break;
      case 'paymentTerms':
        _profile.paymentTerms = value as String;
        break;
    }
    await _dbService.saveBusinessProfile(_profile);
    notifyListeners();
  }

  // Client operations
  Future<void> addClient(Client client) async {
    await _dbService.insertClient(client);
    await loadClients();
  }

  Future<void> updateClient(Client client) async {
    await _dbService.updateClient(client);
    await loadClients();
  }

  Future<void> deleteClient(String id) async {
    await _dbService.deleteClient(id);
    await loadClients();
  }

  Client? getClientById(String id) {
    try {
      return _clients.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}

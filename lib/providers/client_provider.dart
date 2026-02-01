import 'package:flutter/material.dart';
import '../models/client.dart';
import '../db/database_helper.dart';

class ClientProvider extends ChangeNotifier {
  List<Client> _clients = [];
  List<Client> get clients => _clients;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> loadClients() async {
    _clients = await _dbHelper.getClients();
    notifyListeners();
  }

  Future<void> addClient(Client client) async {
    await _dbHelper.insertClient(client);
    await loadClients();
  }

  Future<void> updateClient(Client client) async {
    await _dbHelper.updateClient(client);
    await loadClients();
  }

  Future<void> deleteClient(int id) async {
    await _dbHelper.deleteClient(id);
    await loadClients();
  }
}

import 'package:flutter/material.dart';
import '../../domain/entities/client.dart';
import '../../domain/repositories/i_client_repository.dart';
import '../../data/repositories/client_repository.dart';
import '../../core/config/app_config.dart';
import '../../core/services/logger_service.dart';

class ClientProvider extends ChangeNotifier {
  final IClientRepository _repository;
  List<Client> _clients = [];
  List<Client> get clients => _clients;

  ClientProvider(this._repository);

  Future<void> loadClients() async {
    _clients = await _repository.getClients();
    notifyListeners();
  }

  Future<void> addClient(Client client) async {
    if (AppConfig.isDemoMode && _clients.length >= 20) {
      const error =
          'Demo Limit Reached: Maximum 20 clients allowed in Demo Mode.';
      LoggerService.w(error);
      throw Exception(error);
    }
    await _repository.insertClient(client);
    await loadClients();
  }

  Future<void> updateClient(Client client) async {
    await _repository.updateClient(client);
    await loadClients();
  }

  Future<void> deleteClient(int id) async {
    await _repository.deleteClient(id);
    await loadClients();
  }

  Future<void> applyPayment(int clientId, double amount) async {
    await _repository.applyPayment(clientId, amount);
    await loadClients();
  }

  // UI Alias
  Future<void> applyPaymentToClientVentes(int clientId, double amount) =>
      applyPayment(clientId, amount);

  Future<double> getClientCredit(int clientId) async {
    return await _repository.getClientCredit(clientId);
  }

  Future<void> useClientCredit(int clientId, double amount) async {
    await _repository.useClientCredit(clientId, amount);
    await loadClients();
  }
}

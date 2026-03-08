import '../../domain/entities/client.dart';
import '../../domain/repositories/i_client_repository.dart';
import '../../db/database_helper.dart';
import '../models/client.dart' as model;

class ClientRepository implements IClientRepository {
  final DatabaseHelper _dbHelper;

  ClientRepository(this._dbHelper);

  @override
  Future<List<Client>> getClients() async {
    final models = await _dbHelper.getClients();
    return models
        .map(
          (m) => Client(
            id: m.id,
            name: m.name,
            phone: m.phone,
            address: m.address,
            credit: m.credit,
          ),
        )
        .toList();
  }

  @override
  Future<int> insertClient(Client client) async {
    final m = model.Client(
      id: client.id,
      name: client.name,
      phone: client.phone,
      address: client.address,
      credit: client.credit,
    );
    return await _dbHelper.insertClient(m);
  }

  @override
  Future<int> updateClient(Client client) async {
    final m = model.Client(
      id: client.id,
      name: client.name,
      phone: client.phone,
      address: client.address,
      credit: client.credit,
    );
    return await _dbHelper.updateClient(m);
  }

  @override
  Future<int> deleteClient(int id) async {
    return await _dbHelper.deleteClient(id);
  }

  @override
  Future<double> getClientCredit(int clientId) async {
    return await _dbHelper.getClientCredit(clientId);
  }

  @override
  Future<void> applyPayment(int clientId, double amount) async {
    await _dbHelper.applyPaymentToClientVentes(clientId, amount);
  }

  @override
  Future<void> useClientCredit(int clientId, double amount) async {
    await _dbHelper.useClientCredit(clientId, amount);
  }
}

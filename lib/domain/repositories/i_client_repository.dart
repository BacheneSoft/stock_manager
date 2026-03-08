import '../entities/client.dart';

/// Interface for managing [Client] data access.
///
/// Includes methods for tracking customer info and credit balances.
abstract class IClientRepository {
  Future<List<Client>> getClients();
  Future<int> insertClient(Client client);
  Future<int> updateClient(Client client);
  Future<int> deleteClient(int id);
  Future<double> getClientCredit(int clientId);
  Future<void> applyPayment(int clientId, double amount);
  Future<void> useClientCredit(int clientId, double amount);
}

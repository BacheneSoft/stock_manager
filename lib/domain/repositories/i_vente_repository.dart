import '../entities/vente.dart';
import '../entities/vente_article.dart';

/// Interface for managing [Vente] (Sale) data access.
///
/// Handles transaction history, statistics, and reporting.
abstract class IVenteRepository {
  Future<List<Vente>> getVentesByClient(int clientId);
  Future<int> insertVente(Vente vente);
  Future<void> insertVenteArticle(VenteArticle venteArticle);
  Future<List<VenteArticle>> getVenteArticles(int venteId);
  Future<void> updateVente(Vente vente);
  Future<void> deleteVente(int id);
  Future<void> deleteVenteArticles(int venteId);
  Future<void> handleOverpayment(int clientId, double amount);
}

import '../../domain/entities/vente.dart';
import '../../domain/entities/vente_article.dart';
import '../../domain/repositories/i_vente_repository.dart';
import '../../db/database_helper.dart';
import '../models/vente.dart' as model;
import '../models/vente_article.dart' as model_va;

class VenteRepository implements IVenteRepository {
  final DatabaseHelper _dbHelper;

  VenteRepository(this._dbHelper);

  @override
  Future<List<Vente>> getVentesByClient(int clientId) async {
    final models = await _dbHelper.getVentesByClient(clientId);
    return models
        .map(
          (m) => Vente(
            id: m.id,
            clientId: m.clientId,
            date: m.date,
            total: m.total,
            isPaid: m.isPaid,
            description: m.description,
            credit: m.credit,
          ),
        )
        .toList();
  }

  @override
  Future<int> insertVente(Vente vente) async {
    return await _dbHelper.insertVente(
      model.Vente(
        id: vente.id,
        clientId: vente.clientId,
        date: vente.date,
        total: vente.total,
        isPaid: vente.isPaid,
        description: vente.description,
        credit: vente.credit,
      ),
    );
  }

  @override
  Future<void> insertVenteArticle(VenteArticle va) async {
    await _dbHelper.insertVenteArticle(
      model_va.VenteArticle(
        id: va.id,
        venteId: va.venteId,
        articleId: va.articleId,
        quantity: va.quantity,
        price: va.price,
        costPrice: va.costPrice,
      ),
    );
  }

  @override
  Future<List<VenteArticle>> getVenteArticles(int venteId) async {
    final models = await _dbHelper.getVenteArticles(venteId);
    return models
        .map(
          (m) => VenteArticle(
            id: m.id,
            venteId: m.venteId,
            articleId: m.articleId,
            quantity: m.quantity,
            price: m.price,
            costPrice: m.costPrice,
          ),
        )
        .toList();
  }

  @override
  Future<void> updateVente(Vente vente) async {
    await _dbHelper.updateVente(
      model.Vente(
        id: vente.id,
        clientId: vente.clientId,
        date: vente.date,
        total: vente.total,
        isPaid: vente.isPaid,
        description: vente.description,
        credit: vente.credit,
      ),
    );
  }

  @override
  Future<void> deleteVente(int id) async {
    await _dbHelper.deleteVente(id);
  }

  @override
  Future<void> deleteVenteArticles(int venteId) async {
    await _dbHelper.deleteVenteArticles(venteId);
  }

  @override
  Future<void> handleOverpayment(int clientId, double amount) async {
    await _dbHelper.handleOverpayment(clientId, amount);
  }
}

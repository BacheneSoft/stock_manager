import 'package:flutter/material.dart';
import '../models/vente.dart';
import '../models/vente_article.dart';
import '../db/database_helper.dart';

class VenteProvider extends ChangeNotifier {
  List<Vente> _ventes = [];
  List<Vente> get ventes => _ventes;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> loadVentes(int clientId) async {
    _ventes = await _dbHelper.getVentesByClient(clientId);
    notifyListeners();
  }

  Future<void> addVente(Vente vente, List<VenteArticle> venteArticles) async {
    final venteId = await _dbHelper.insertVente(vente);
    for (var va in venteArticles) {
      await _dbHelper.insertVenteArticle(
        VenteArticle(
          venteId: venteId,
          articleId: va.articleId,
          quantity: va.quantity,
          price: va.price,
          costPrice: va.costPrice, // Include cost price for benefit tracking
        ),
      );
    }

    // Professional overpayment handling
    if (vente.credit < 0) {
      // Client paid more than total - handle overpayment
      await _dbHelper.handleOverpayment(vente.clientId, vente.credit.abs());
    }

    await loadVentes(vente.clientId);
  }

  // Professional method to handle credit usage in sales
  Future<void> useClientCreditInSale(int clientId, double creditAmount) async {
    await _dbHelper.useClientCredit(clientId, creditAmount);
  }

  Future<List<VenteArticle>> getVenteArticles(int venteId) async {
    return await _dbHelper.getVenteArticles(venteId);
  }

  Future<void> updateVente(Vente vente) async {
    await _dbHelper.updateVente(vente);
    await loadVentes(vente.clientId);
  }

  Future<void> deleteVente(int id, int clientId) async {
    await _dbHelper.deleteVente(id);
    await loadVentes(clientId);
  }
}

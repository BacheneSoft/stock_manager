import 'package:flutter/material.dart';
import '../../domain/entities/vente.dart';
import '../../domain/entities/vente_article.dart';
import '../../domain/repositories/i_vente_repository.dart';
import '../../core/config/app_config.dart';
import '../../core/services/logger_service.dart';

class VenteProvider extends ChangeNotifier {
  final IVenteRepository _repository;
  List<Vente> _ventes = [];
  List<Vente> get ventes => _ventes;

  VenteProvider(this._repository);

  Future<void> loadVentes(int clientId) async {
    _ventes = await _repository.getVentesByClient(clientId);
    notifyListeners();
  }

  Future<void> addVente(Vente vente, List<VenteArticle> venteArticles) async {
    if (AppConfig.isDemoMode) {
      // For simplicity in demo, we check total sales count or list length
      final allSales = await _repository.getVentesByClient(vente.clientId);
      if (allSales.length >= AppConfig.maxSaleLimit) {
        const error = 'Demo Limit Reached: Maximum ${AppConfig.maxSaleLimit} sales allowed in Demo Mode.';
        LoggerService.w(error);
        throw Exception(error);
      }
    }
    final venteId = await _repository.insertVente(vente);
    for (var va in venteArticles) {
      await _repository.insertVenteArticle(
        VenteArticle(
          venteId: venteId,
          articleId: va.articleId,
          quantity: va.quantity,
          price: va.price,
          costPrice: va.costPrice,
        ),
      );
    }

    if (vente.credit < 0) {
      await _repository.handleOverpayment(vente.clientId, vente.credit.abs());
    }

    await loadVentes(vente.clientId);
  }

  Future<List<VenteArticle>> getVenteArticles(int venteId) async {
    return await _repository.getVenteArticles(venteId);
  }

  Future<void> updateVente(Vente vente, List<VenteArticle> venteArticles) async {
    await _repository.updateVente(vente);
    // Remove old vente_articles and add new ones
    await _repository.deleteVenteArticles(vente.id!);
    for (final va in venteArticles) {
      await _repository.insertVenteArticle(va);
    }
    await loadVentes(vente.clientId);
  }

  Future<void> deleteVente(int id, int clientId) async {
    await _repository.deleteVente(id);
    await loadVentes(clientId);
  }
}


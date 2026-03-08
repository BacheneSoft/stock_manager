import 'package:flutter/material.dart';
import '../../domain/entities/article.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/repositories/i_article_repository.dart';
import '../../data/repositories/article_repository.dart';
import '../../core/services/logger_service.dart';
import '../../core/config/app_config.dart';

class ArticleProvider extends ChangeNotifier {
  final IArticleRepository _repository;
  List<Article> _articles = [];
  List<Article> get articles => _articles;

  ArticleProvider(this._repository);

  Future<void> loadArticles() async {
    _articles = await _repository.getArticles();
    notifyListeners();
  }

  Future<void> addArticle(Article article) async {
    if (AppConfig.isDemoMode && _articles.length >= AppConfig.maxArticleLimit) {
      const error =
          'Demo Limit Reached: Maximum ${AppConfig.maxArticleLimit} articles allowed in Demo Mode.';
      LoggerService.w(error);
      throw Exception(error);
    }
    try {
      await _repository.insertArticle(article);
      await loadArticles();
    } catch (e, stack) {
      LoggerService.e('Failed to add article: ${article.name}', e, stack);
      rethrow;
    }
  }

  Future<void> updateArticle(Article article) async {
    await _repository.updateArticle(article);
    await loadArticles();
  }

  Future<void> deleteArticle(int id) async {
    try {
      await _repository.deleteArticle(id);
      await loadArticles();
    } catch (e, stack) {
      LoggerService.e('Failed to delete article with ID: $id', e, stack);
      rethrow;
    }
  }

  Future<void> addPurchase(Purchase purchase) async {
    await _repository.addPurchase(purchase);
    // Usually no need to loadArticles here unless the list depends on latest purchase
    // but the UI might want a refresh.
  }

  Future<List<Purchase>> getPurchases() async {
    return await _repository.getPurchases();
  }
}

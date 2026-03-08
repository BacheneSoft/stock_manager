import '../../domain/entities/article.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/repositories/i_article_repository.dart';
import '../../db/database_helper.dart';
import '../models/article.dart' as model;
import '../models/purchase.dart' as model_p;
import '../../core/services/logger_service.dart';

class ArticleRepository implements IArticleRepository {
  final DatabaseHelper _dbHelper;

  ArticleRepository(this._dbHelper);

  @override
  Future<List<Article>> getArticles() async {
    LoggerService.i('Fetching all articles from database');
    final models = await _dbHelper.getArticles();
    return models
        .map(
          (m) => Article(
            id: m.id,
            name: m.name,
            provider: m.provider,
            buyPrice: m.buyPrice,
            sellPrice: m.sellPrice,
            quantity: m.quantity,
            categoryId: m.categoryId,
            purchaseDate: m.purchaseDate,
          ),
        )
        .toList();
  }

  @override
  Future<int> insertArticle(Article article) async {
    final m = model.Article(
      id: article.id,
      name: article.name,
      provider: article.provider,
      buyPrice: article.buyPrice,
      sellPrice: article.sellPrice,
      quantity: article.quantity,
      categoryId: article.categoryId,
      purchaseDate: article.purchaseDate,
    );
    LoggerService.i('Inserting new article: ${article.name}');
    return await _dbHelper.insertArticle(m);
  }

  @override
  Future<int> updateArticle(Article article) async {
    final m = model.Article(
      id: article.id,
      name: article.name,
      provider: article.provider,
      buyPrice: article.buyPrice,
      sellPrice: article.sellPrice,
      quantity: article.quantity,
      categoryId: article.categoryId,
      purchaseDate: article.purchaseDate,
    );
    return await _dbHelper.updateArticle(m);
  }

  @override
  Future<int> deleteArticle(int id) async {
    return await _dbHelper.deleteArticle(id);
  }

  @override
  Future<void> addPurchase(Purchase p) async {
    await _dbHelper.insertPurchase(
      model_p.Purchase(
        articleId: p.articleId,
        articleName: p.articleName,
        supplier: p.supplier,
        buyPrice: p.buyPrice,
        sellPrice: p.sellPrice,
        quantity: p.quantity,
        purchaseDate: p.purchaseDate,
      ),
    );
  }

  @override
  Future<List<Purchase>> getPurchases() async {
    final models = await _dbHelper.getPurchases();
    return models
        .map(
          (m) => Purchase(
            id: m.id,
            articleId: m.articleId,
            articleName: m.articleName,
            supplier: m.supplier,
            buyPrice: m.buyPrice,
            sellPrice: m.sellPrice,
            quantity: m.quantity,
            purchaseDate: m.purchaseDate,
          ),
        )
        .toList();
  }
}

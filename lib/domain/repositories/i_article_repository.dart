import '../entities/article.dart';
import '../entities/purchase.dart';

/// Interface for managing [Article] data access.
///
/// Defines the contract for fetching, saving, and deleting articles
/// independent of the underlying storage mechanism.
abstract class IArticleRepository {
  Future<List<Article>> getArticles();
  Future<int> insertArticle(Article article);
  Future<int> updateArticle(Article article);
  Future<int> deleteArticle(int id);
  Future<void> addPurchase(Purchase purchase);
  Future<List<Purchase>> getPurchases();
}

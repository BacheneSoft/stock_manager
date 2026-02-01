import 'package:flutter/material.dart';
import '../models/article.dart';
import '../db/database_helper.dart';

class ArticleProvider extends ChangeNotifier {
  List<Article> _articles = [];
  List<Article> get articles => _articles;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> loadArticles() async {
    _articles = await _dbHelper.getArticles();
    notifyListeners();
  }

  Future<void> addArticle(Article article) async {
    await _dbHelper.insertArticle(article);
    await loadArticles();
  }

  Future<void> updateArticle(Article article) async {
    await _dbHelper.updateArticle(article);
    await loadArticles();
  }

  Future<void> deleteArticle(int id) async {
    await _dbHelper.deleteArticle(id);
    await loadArticles();
  }

  Future<void> addArticleName(String name) async {
    final article = Article(
      name: name,
      provider: '',
      buyPrice: 0,
      sellPrice: 0,
      quantity: 0,
      categoryId: 0,
    );
    await addArticle(article);
  }
}

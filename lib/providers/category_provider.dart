import 'package:flutter/material.dart';
import '../models/category.dart';
import '../db/database_helper.dart';

class CategoryProvider extends ChangeNotifier {
  List<Category> _categories = [];
  List<Category> get categories => _categories;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> loadCategories() async {
    _categories = await _dbHelper.getCategories();
    notifyListeners();
  }

  Future<void> addCategory(Category category) async {
    await _dbHelper.insertCategory(category);
    await loadCategories();
  }
}

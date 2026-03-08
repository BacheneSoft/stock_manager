import 'package:flutter/material.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/i_category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final ICategoryRepository _repository;
  List<Category> _categories = [];

  CategoryProvider(this._repository);

  List<Category> get categories => _categories;

  Future<void> loadCategories() async {
    _categories = await _repository.getCategories();
    notifyListeners();
  }

  Future<void> addCategory(Category category) async {
    await _repository.insertCategory(category);
    await loadCategories();
  }
}

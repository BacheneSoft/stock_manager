import '../../domain/entities/category.dart';
import '../../domain/repositories/i_category_repository.dart';
import '../../db/database_helper.dart';
import '../models/category.dart' as model;

class CategoryRepository implements ICategoryRepository {
  final DatabaseHelper _dbHelper;

  CategoryRepository(this._dbHelper);

  @override
  Future<List<Category>> getCategories() async {
    final models = await _dbHelper.getCategories();
    return models.map((m) => Category(
      id: m.id,
      name: m.name,
    )).toList();
  }

  @override
  Future<int> insertCategory(Category category) async {
    final m = model.Category(
      id: category.id,
      name: category.name,
    );
    return await _dbHelper.insertCategory(m);
  }
}

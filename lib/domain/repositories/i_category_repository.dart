import '../entities/category.dart';

/// Interface for managing [Category] data access.
///
/// Provides methods for organizing articles into logical groups.
abstract class ICategoryRepository {
  Future<List<Category>> getCategories();
  Future<int> insertCategory(Category category);
}

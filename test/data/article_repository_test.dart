import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bachene_soft/data/repositories/article_repository.dart';
import 'package:bachene_soft/db/database_helper.dart';
import 'package:bachene_soft/data/models/article.dart' as model;
import 'package:bachene_soft/domain/entities/article.dart';

class MockDatabaseHelper extends Mock implements DatabaseHelper {}

class FakeArticle extends Fake implements model.Article {}

void main() {
  late ArticleRepository repository;
  late MockDatabaseHelper mockDbHelper;

  setUpAll(() {
    registerFallbackValue(FakeArticle());
  });

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    repository = ArticleRepository(mockDbHelper);
  });

  group('ArticleRepository', () {
    final tArticleModel = model.Article(
      id: 1,
      name: 'Test Article',
      provider: 'Test Provider',
      buyPrice: 10.0,
      sellPrice: 20.0,
      quantity: 5,
      categoryId: 1,
      purchaseDate: '2026-03-07',
    );

    final tArticleEntity = Article(
      id: 1,
      name: 'Test Article',
      provider: 'Test Provider',
      buyPrice: 10.0,
      sellPrice: 20.0,
      quantity: 5,
      categoryId: 1,
      purchaseDate: '2026-03-07',
    );

    test('getArticles should return a list of Article entities', () async {
      // arrange
      when(() => mockDbHelper.getArticles()).thenAnswer((_) async => [tArticleModel]);

      // act
      final result = await repository.getArticles();

      // assert
      expect(result, isA<List<Article>>());
      expect(result.first.name, tArticleEntity.name);
      verify(() => mockDbHelper.getArticles()).called(1);
    });

    test('insertArticle should call DatabaseHelper with correct model', () async {
      // arrange
      when(() => mockDbHelper.insertArticle(any())).thenAnswer((_) async => 1);

      // act
      await repository.insertArticle(tArticleEntity);

      // assert
      verify(() => mockDbHelper.insertArticle(any())).called(1);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:bachene_soft/domain/entities/article.dart';
import 'package:bachene_soft/domain/entities/client.dart';

void main() {
  group('Domain Entities', () {
    test('Article entity should be created correctly', () {
      final article = Article(
        id: 1,
        name: 'Test',
        provider: 'Prov',
        buyPrice: 10.0,
        sellPrice: 15.0,
        quantity: 1,
        categoryId: 1,
        purchaseDate: '2026-01-01',
      );

      expect(article.id, 1);
      expect(article.name, 'Test');
    });

    test('Client entity should be created correctly', () {
      final client = Client(
        id: 1,
        name: 'John Doe',
        phone: '123456',
        address: 'Addr',
        credit: 100.0,
      );

      expect(client.name, 'John Doe');
      expect(client.credit, 100.0);
    });

    test('Article.copyWith should return a new instance with updated values', () {
      final article = Article(
        name: 'Initial',
        provider: 'Prov',
        buyPrice: 10.0,
        sellPrice: 15.0,
        quantity: 1,
        purchaseDate: '2026-01-01',
        categoryId: 1,
      );

      final updated = article.copyWith(name: 'Updated');

      expect(updated.name, 'Updated');
      expect(updated.provider, article.provider);
    });
  });
}

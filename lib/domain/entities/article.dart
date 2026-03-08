/// Represents a stock article in the system.
///
/// Contains core business data for inventory management, including
/// identification, categorization, and pricing.
class Article {
  final int? id;
  final String name;
  final String provider;
  final double buyPrice;
  final double sellPrice;
  final int quantity;
  final int categoryId;
  final String? purchaseDate;

  Article({
    this.id,
    required this.name,
    required this.provider,
    required this.buyPrice,
    required this.sellPrice,
    required this.quantity,
    required this.categoryId,
    this.purchaseDate,
  });

  Article copyWith({
    int? id,
    String? name,
    String? provider,
    double? buyPrice,
    double? sellPrice,
    int? quantity,
    int? categoryId,
    String? purchaseDate,
  }) {
    return Article(
      id: id ?? this.id,
      name: name ?? this.name,
      provider: provider ?? this.provider,
      buyPrice: buyPrice ?? this.buyPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      quantity: quantity ?? this.quantity,
      categoryId: categoryId ?? this.categoryId,
      purchaseDate: purchaseDate ?? this.purchaseDate,
    );
  }
}

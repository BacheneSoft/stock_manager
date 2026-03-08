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

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'provider': provider,
    'buyPrice': buyPrice,
    'sellPrice': sellPrice,
    'quantity': quantity,
    'categoryId': categoryId,
    'purchaseDate': purchaseDate,
  };

  factory Article.fromMap(Map<String, dynamic> map) => Article(
    id: map['id'] as int?,
    name: map['name'] as String,
    provider: map['provider'] as String,
    buyPrice: (map['buyPrice'] as num).toDouble(),
    sellPrice: (map['sellPrice'] as num).toDouble(),
    quantity: map['quantity'] as int,
    categoryId: map['categoryId'] as int,
    purchaseDate: map['purchaseDate'] as String?,
  );
}

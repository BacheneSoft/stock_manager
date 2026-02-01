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
    id: map['id'],
    name: map['name'],
    provider: map['provider'],
    buyPrice: map['buyPrice'],
    sellPrice: map['sellPrice'],
    quantity: map['quantity'],
    categoryId: map['categoryId'],
    purchaseDate: map['purchaseDate'],
  );
}

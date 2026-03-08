class VenteArticle {
  final int? id;
  final int venteId;
  final int articleId;
  final int quantity;
  final double price;
  final double costPrice; // Buy price at time of sale for profit calculation

  VenteArticle({
    this.id,
    required this.venteId,
    required this.articleId,
    required this.quantity,
    required this.price,
    this.costPrice = 0,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'venteId': venteId,
    'articleId': articleId,
    'quantity': quantity,
    'price': price,
    'costPrice': costPrice,
  };

  factory VenteArticle.fromMap(Map<String, dynamic> map) => VenteArticle(
    id: map['id'] as int?,
    venteId: map['venteId'] as int,
    articleId: map['articleId'] as int,
    quantity: map['quantity'] as int,
    price: (map['price'] as num).toDouble(),
    costPrice: (map['costPrice'] as num?)?.toDouble() ?? 0,
  );
}

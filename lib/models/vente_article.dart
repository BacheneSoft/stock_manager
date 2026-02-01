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
    id: map['id'],
    venteId: map['venteId'],
    articleId: map['articleId'],
    quantity: map['quantity'],
    price: map['price'],
    costPrice: (map['costPrice'] as num?)?.toDouble() ?? 0,
  );
}

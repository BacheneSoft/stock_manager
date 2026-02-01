class Purchase {
  final int? id;
  final int articleId;
  final String articleName;
  final String supplier;
  final double buyPrice;
  final double sellPrice;
  final int quantity;
  final String purchaseDate;

  Purchase({
    this.id,
    required this.articleId,
    required this.articleName,
    required this.supplier,
    required this.buyPrice,
    required this.sellPrice,
    required this.quantity,
    required this.purchaseDate,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'articleId': articleId,
    'articleName': articleName,
    'supplier': supplier,
    'buyPrice': buyPrice,
    'sellPrice': sellPrice,
    'quantity': quantity,
    'purchaseDate': purchaseDate,
  };

  factory Purchase.fromMap(Map<String, dynamic> map) => Purchase(
    id: map['id'],
    articleId: map['articleId'],
    articleName: map['articleName'],
    supplier: map['supplier'],
    buyPrice: map['buyPrice'],
    sellPrice: map['sellPrice'],
    quantity: map['quantity'],
    purchaseDate: map['purchaseDate'],
  );
}

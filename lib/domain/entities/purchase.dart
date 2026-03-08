/// Represents a stock purchase from a supplier.
///
/// Tracks the acquisition of articles and associated costs.
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
}

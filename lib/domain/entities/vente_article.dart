/// Represents an itemized article within a [Vente].
///
/// Links an [Article] to a [Vente] with specific quantity and pricing at
/// the time of sale.
class VenteArticle {
  final int? id;
  final int venteId;
  final int articleId;
  final int quantity;
  final double price;
  final double costPrice;

  VenteArticle({
    this.id,
    required this.venteId,
    required this.articleId,
    required this.quantity,
    required this.price,
    required this.costPrice,
  });
}

/// Represents a sales transaction (Vente) in the system.
///
/// Captures the total amount, payment status, and associated client.
class Vente {
  final int? id;
  final int clientId;
  final String date;
  final double total;
  final bool isPaid;
  final String? description;
  final double credit;

  Vente({
    this.id,
    required this.clientId,
    required this.date,
    required this.total,
    required this.isPaid,
    this.description,
    required this.credit,
  });
}

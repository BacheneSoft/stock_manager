/// Represents a payment made for a sale or credit.
///
/// Tracks the amount, method, and date of a financial transaction.
class Payment {
  final int? id;
  final int? clientId; // Nullable for anonymous sales if needed, but usually linked
  final double amount;
  final String date;
  final String? note;

  Payment({
    this.id,
    this.clientId,
    required this.amount,
    required this.date,
    this.note,
  });


}


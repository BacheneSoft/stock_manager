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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'amount': amount,
      'date': date,
      'note': note,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      clientId: map['clientId'],
      amount: (map['amount'] as num).toDouble(),
      date: map['date'],
      note: map['note'],
    );
  }
}

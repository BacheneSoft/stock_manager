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
    this.isPaid = true,
    this.description,
    this.credit = 0,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'clientId': clientId,
    'date': date,
    'total': total,
    'isPaid': isPaid ? 1 : 0,
    'description': description,
    'credit': credit,
  };

  factory Vente.fromMap(Map<String, dynamic> map) => Vente(
    id: map['id'] as int?,
    clientId: map['clientId'] as int,
    date: map['date'] as String,
    total: (map['total'] as num).toDouble(),
    isPaid: (map['isPaid'] ?? 1) == 1,
    description: map['description'] as String?,
    credit: (map['credit'] as num?)?.toDouble() ?? 0,
  );
}

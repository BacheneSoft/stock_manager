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
    id: map['id'],
    clientId: map['clientId'],
    date: map['date'],
    total: map['total'],
    isPaid: (map['isPaid'] ?? 1) == 1,
    description: map['description'],
    credit: map['credit'] ?? 0,
  );
}

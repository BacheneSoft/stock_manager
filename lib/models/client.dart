class Client {
  final int? id;
  final String name;
  final String phone;
  final String? address;
  final double credit;

  Client({
    this.id,
    required this.name,
    required this.phone,
    this.address,
    this.credit = 0,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
    'address': address,
    'credit': credit,
  };

  factory Client.fromMap(Map<String, dynamic> map) => Client(
    id: map['id'],
    name: map['name'],
    phone: map['phone'],
    address: map['address'],
    credit: map['credit'] != null ? (map['credit'] as num).toDouble() : 0,
  );
}

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
    id: map['id'] as int?,
    name: map['name'] as String,
    phone: map['phone'] as String,
    address: map['address'] as String?,
    credit: (map['credit'] as num?)?.toDouble() ?? 0,
  );
}


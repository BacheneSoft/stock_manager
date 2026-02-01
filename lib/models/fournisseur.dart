class Fournisseur {
  final int? id;
  final String name;
  final String phone;
  final String? address;

  Fournisseur({this.id, required this.name, required this.phone, this.address});

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
    'address': address,
  };

  factory Fournisseur.fromMap(Map<String, dynamic> map) => Fournisseur(
    id: map['id'],
    name: map['name'],
    phone: map['phone'],
    address: map['address'],
  );

  Fournisseur copyWith({
    int? id,
    String? name,
    String? phone,
    String? address,
  }) {
    return Fournisseur(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }
}

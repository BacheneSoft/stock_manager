/// Represents a supplier/vendor for stock purchases.
///
/// Stores communication and address details for procurement tracking.
class Fournisseur {
  final int? id;
  final String name;
  final String phone;
  final String? address;

  Fournisseur({this.id, required this.name, required this.phone, this.address});


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


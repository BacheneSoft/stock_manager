/// Represents a client or customer in the system.
///
/// Tracks contact information and the current credit balance
/// for the customer.
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
}



class Cloture {
  final int? id;
  final String date;
  final double montant; // Amount entered by user
  final double calculatedCA; // System calculated Turnover
  final double calculatedEncaissement; // System calculated Collections
  final double calculatedBenefit; // System calculated Profit

  Cloture({
    this.id,
    required this.date,
    required this.montant,
    required this.calculatedCA,
    required this.calculatedEncaissement,
    this.calculatedBenefit = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'montant': montant,
      'calculated_ca': calculatedCA,
      'calculated_encaissement': calculatedEncaissement,
      'calculated_benefit': calculatedBenefit,
    };
  }

  factory Cloture.fromMap(Map<String, dynamic> map) {
    return Cloture(
      id: map['id'] as int?,
      date: map['date'] as String,
      montant: (map['montant'] as num).toDouble(),
      calculatedCA: (map['calculated_ca'] as num).toDouble(),
      calculatedEncaissement:
          (map['calculated_encaissement'] as num).toDouble(),
      calculatedBenefit: (map['calculated_benefit'] as num?)?.toDouble() ?? 0,
    );
  }
}

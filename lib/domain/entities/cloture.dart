/// Represents a daily or periodic closure (Cloture) of sales.
///
/// Summarizes financial data for a specific period.
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


}


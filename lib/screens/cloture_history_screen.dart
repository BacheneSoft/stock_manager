import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/cloture.dart';
import '../utils/formatters.dart';

class ClotureHistoryScreen extends StatefulWidget {
  const ClotureHistoryScreen({Key? key}) : super(key: key);

  @override
  _ClotureHistoryScreenState createState() => _ClotureHistoryScreenState();
}

class _ClotureHistoryScreenState extends State<ClotureHistoryScreen> {
  late Future<List<Cloture>> _cloturesFuture;

  @override
  void initState() {
    super.initState();
    _cloturesFuture = DatabaseHelper().getClotures();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des Clôtures'),
      ),
      body: FutureBuilder<List<Cloture>>(
        future: _cloturesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune clôture enregistrée.'));
          }

          final clotures = snapshot.data!;
          return ListView.builder(
            itemCount: clotures.length,
            itemBuilder: (context, index) {
              final cloture = clotures[index];
              final date = DateTime.parse(cloture.date);
              final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Divider(),
                      _buildRow('Montant Déclaré:', cloture.montant, Colors.orange),
                      _buildRow('Chiffre d\'affaire:', cloture.calculatedCA, Colors.blue),
                      _buildRow('Encaissement:', cloture.calculatedEncaissement, Colors.green),
                      _buildRow('Bénéfice:', cloture.calculatedBenefit, Colors.teal),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRow(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            Formatters.formatCurrency(value),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

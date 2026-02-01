import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../db/database_helper.dart';
import '../models/vente.dart';
import '../models/vente_article.dart';
import '../utils/formatters.dart';

class InventoryHistoryScreen extends StatefulWidget {
  const InventoryHistoryScreen({Key? key}) : super(key: key);

  @override
  _InventoryHistoryScreenState createState() => _InventoryHistoryScreenState();
}

class _InventoryHistoryScreenState extends State<InventoryHistoryScreen> {
  List<Vente> _adjustments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final db = DatabaseHelper();
      final database = await db.database;
      final maps = await database.query(
        'ventes',
        where: 'description = ?',
        whereArgs: ['Stock Rest Adjustment'],
        orderBy: 'date DESC',
      );
      setState(() {
        _adjustments = maps.map((e) => Vente.fromMap(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique des Ajustements', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: theme.colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _adjustments.isEmpty
              ? Center(
                  child: Text('Aucun historique trouvé.', 
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
                )
              : ListView.builder(
                  itemCount: _adjustments.length,
                  itemBuilder: (context, index) {
                    final vente = _adjustments[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text('Date: ${vente.date.substring(0, 16).replaceFirst('T', ' ')}', 
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        subtitle: Text('Total Vente: ${Formatters.formatCurrency(vente.total)} DA'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showAdjustmentDetails(vente),
                      ),
                    );
                  },
                ),
    );
  }

  void _showAdjustmentDetails(Vente vente) async {
    final db = DatabaseHelper();
    final articles = await db.getVenteArticles(vente.id!);
    
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Détails de l\'ajustement', 
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final va = articles[index];
                    return FutureBuilder<List<Map<String, dynamic>>>(
                      future: DatabaseHelper().database.then((db) => db.query('articles', where: 'id = ?', whereArgs: [va.articleId])),
                      builder: (context, snapshot) {
                        final name = snapshot.hasData && snapshot.data!.isNotEmpty 
                          ? snapshot.data!.first['name'] as String 
                          : 'Article #${va.articleId}';
                        return ListTile(
                          title: Text(name),
                          subtitle: Text('Quantité vendue: ${va.quantity}'),
                          trailing: Text('${Formatters.formatCurrency(va.quantity * va.price)} DA'),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

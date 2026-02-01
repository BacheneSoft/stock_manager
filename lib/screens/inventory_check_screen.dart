import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/article.dart';
import '../models/vente.dart';
import '../models/vente_article.dart';
import '../models/client.dart';
import '../providers/article_provider.dart';
import '../providers/vente_provider.dart';
import '../providers/client_provider.dart';
import '../db/database_helper.dart';
import '../utils/formatters.dart';
import 'inventory_history_screen.dart';

class InventoryCheckScreen extends StatefulWidget {
  const InventoryCheckScreen({Key? key}) : super(key: key);

  @override
  _InventoryCheckScreenState createState() => _InventoryCheckScreenState();
}

class _InventoryCheckScreenState extends State<InventoryCheckScreen> {
  final Map<int, int> _restQuantities = {}; // articleId -> rest quantity
  final Map<int, TextEditingController> _controllers = {};
  String _searchQuery = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    Provider.of<ArticleProvider>(context, listen: false).loadArticles();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _handleValider() async {
    final articleProvider = Provider.of<ArticleProvider>(context, listen: false);
    final venteProvider = Provider.of<VenteProvider>(context, listen: false);
    final clientProvider = Provider.of<ClientProvider>(context, listen: false);
    
    final articlesToAdjust = articleProvider.articles.where((a) {
      final rest = _restQuantities[a.id];
      return rest != null && rest < a.quantity;
    }).toList();

    if (articlesToAdjust.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun ajustement nécessaire.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final db = DatabaseHelper();
      
      // 1. Find or create special client
      final clients = await db.getClients();
      Client? inventoryClient = clients.firstWhere(
        (c) => c.name == 'Inventaire / Vente Manuelle',
        orElse: () => Client(name: 'Inventaire / Vente Manuelle', phone: '0000', credit: 0),
      );

      int clientId;
      if (inventoryClient.id == null) {
        clientId = await db.insertClient(inventoryClient);
      } else {
        clientId = inventoryClient.id!;
      }

      // 2. Create Vente
      double totalVente = 0;
      List<VenteArticle> venteArticles = [];

      for (var article in articlesToAdjust) {
        final currentQty = article.quantity;
        final restQty = _restQuantities[article.id]!;
        final qtySold = currentQty - restQty;
        
        totalVente += qtySold * article.sellPrice;
        
        venteArticles.add(VenteArticle(
          venteId: 0, // Will be set by provider
          articleId: article.id!,
          quantity: qtySold,
          price: article.sellPrice,
          costPrice: article.buyPrice,
        ));
      }

      final vente = Vente(
        clientId: clientId,
        date: DateTime.now().toIso8601String(),
        total: totalVente,
        isPaid: true,
        description: 'Stock Rest Adjustment',
        credit: 0,
      );

      await venteProvider.addVente(vente, venteArticles);

      // 3. Update Article quantities
      for (var article in articlesToAdjust) {
        final restQty = _restQuantities[article.id]!;
        await articleProvider.updateArticle(Article(
          id: article.id,
          name: article.name,
          provider: article.provider,
          buyPrice: article.buyPrice,
          sellPrice: article.sellPrice,
          quantity: restQty,
          categoryId: article.categoryId,
          purchaseDate: article.purchaseDate,
        ));
      }

      // 4. Success feedback
      if (mounted) {
        _showSuccessDialog(totalVente);
        setState(() {
          _restQuantities.clear();
          for (var c in _controllers.values) {
            c.clear();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSuccessDialog(double total) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajustement Réussi'),
        content: Text('Le stock a été mis à jour.\nTotal vente générée: ${Formatters.formatCurrency(total)} DA'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final articleProvider = Provider.of<ArticleProvider>(context);
    
    final filteredArticles = articleProvider.articles.where((a) {
      return a.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Rest - المخزون المتبقي', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: theme.colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InventoryHistoryScreen()),
              );
            },
            tooltip: 'Historique',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Rechercher un article...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredArticles.length,
              itemBuilder: (context, index) {
                final article = filteredArticles[index];
                if (!_controllers.containsKey(article.id)) {
                  _controllers[article.id!] = TextEditingController();
                }
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(article.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    subtitle: Text('En stock: ${article.quantity} | Prix: ${Formatters.formatCurrency(article.sellPrice)} DA'),
                    trailing: SizedBox(
                      width: 100,
                      child: TextField(
                        controller: _controllers[article.id],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Reste',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) {
                          final rest = int.tryParse(v);
                          if (rest != null && rest <= article.quantity) {
                            _restQuantities[article.id!] = rest;
                          } else {
                            _restQuantities.remove(article.id);
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _handleValider,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSaving 
                ? const CircularProgressIndicator(color: Colors.white)
                : Text('Valider l\'ajustement', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

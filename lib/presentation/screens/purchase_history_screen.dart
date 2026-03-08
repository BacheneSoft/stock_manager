import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/article.dart';
import '../../domain/entities/purchase.dart';
import '../providers/article_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/formatters.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  const PurchaseHistoryScreen({Key? key}) : super(key: key);

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  String _searchQuery = '';
  String _selectedSupplier = '';
  String _selectedDate = '';
  List<Purchase> _purchases = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPurchases();
  }

  Future<void> _loadPurchases() async {
    final provider = Provider.of<ArticleProvider>(context, listen: false);
    final purchases = await provider.getPurchases();
    setState(() {
      _purchases = purchases;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Historique des achats - سجل المشتريات',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFFF5F6FA),
        child: Column(
          children: [
            // Search and filter section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search bar
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Rechercher un article...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon:
                          _searchQuery.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                              : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Date filter
                  Consumer<ArticleProvider>(
                    builder: (context, provider, _) {
                      final dates =
                          provider.articles
                              .where((article) => article.purchaseDate != null)
                              .map((article) => article.purchaseDate!)
                              .toSet()
                              .toList()
                            ..sort(
                              (a, b) => b.compareTo(a),
                            ); // Sort newest first

                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Filtrer par date',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        value: _selectedDate.isEmpty ? null : _selectedDate,
                        items: [
                          const DropdownMenuItem<String>(
                            value: '',
                            child: Text('Toutes les dates'),
                          ),
                          ...dates.map(
                            (date) => DropdownMenuItem<String>(
                              value: date,
                              child: Text(date),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedDate = value ?? '';
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  // Supplier filter
                  Consumer<ArticleProvider>(
                    builder: (context, provider, _) {
                      final suppliers =
                          provider.articles
                              .where((article) => article.provider.isNotEmpty)
                              .map((article) => article.provider)
                              .toSet()
                              .toList()
                            ..sort();

                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Filtrer par fournisseur',
                          prefixIcon: const Icon(Icons.store),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        value:
                            _selectedSupplier.isEmpty
                                ? null
                                : _selectedSupplier,
                        items: [
                          const DropdownMenuItem<String>(
                            value: '',
                            child: Text('Tous les fournisseurs'),
                          ),
                          ...suppliers.map(
                            (supplier) => DropdownMenuItem<String>(
                              value: supplier,
                              child: Text(supplier),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedSupplier = value ?? '';
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            // Purchase summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Builder(
                builder: (context) {
                  final filteredPurchases = _getFilteredPurchases();

                  final totalSuppliers =
                      filteredPurchases.map((p) => p.supplier).toSet().length;
                  final totalArticles = filteredPurchases.length;
                  final totalValue = filteredPurchases.fold(
                    0.0,
                    (sum, p) => sum + (p.buyPrice * p.quantity),
                  );

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildSummaryItem(
                                'Fournisseurs',
                                totalSuppliers.toString(),
                                Icons.store,
                                Colors.blue,
                              ),
                              _buildSummaryItem(
                                'Articles',
                                totalArticles.toString(),
                                Icons.inventory_2_outlined,
                                Colors.orange,
                              ),
                              _buildSummaryItem(
                                'Valeur',
                                '${Formatters.formatCurrency(totalValue)} DA',
                                Icons.attach_money,
                                Colors.green,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _purchases.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 80,
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.7,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _searchQuery.isNotEmpty ||
                                      _selectedSupplier.isNotEmpty
                                  ? 'Aucun résultat'
                                  : 'Aucun historique d\'achat',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: _getFilteredPurchases().length,
                        itemBuilder: (context, index) {
                          final purchase = _getFilteredPurchases()[index];
                          final purchaseValue =
                              purchase.buyPrice * purchase.quantity;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          purchase.articleName,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: Colors.blue,
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          '${purchase.quantity} achetés',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.store,
                                                  size: 16,
                                                  color: Colors.grey[600],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  purchase.supplier,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.attach_money_outlined,
                                                  size: 16,
                                                  color: Colors.grey[600],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Prix d\'achat: ${Formatters.formatCurrency(purchase.buyPrice)} DA',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today,
                                                  size: 16,
                                                  color: Colors.grey[600],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Acheté le: ${purchase.purchaseDate}',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Valeur achat',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            '${Formatters.formatCurrency(purchaseValue)} DA',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  List<Purchase> _getFilteredPurchases() {
    return _purchases
        .where(
          (p) =>
              _searchQuery.isEmpty ||
              p.articleName.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .where(
          (p) => _selectedSupplier.isEmpty || p.supplier == _selectedSupplier,
        )
        .where((p) => _selectedDate.isEmpty || p.purchaseDate == _selectedDate)
        .toList();
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

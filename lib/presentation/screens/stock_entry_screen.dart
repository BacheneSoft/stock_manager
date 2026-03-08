import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/fournisseur_provider.dart';
import '../../presentation/providers/article_provider.dart';
import '../../domain/entities/fournisseur.dart';
import '../../domain/entities/article.dart';
import '../../domain/entities/purchase.dart';
import 'package:google_fonts/google_fonts.dart';
import 'check_stock_screen.dart';
import 'purchase_history_screen.dart';
import '../../utils/formatters.dart';

class StockEntryScreen extends StatefulWidget {
  const StockEntryScreen({Key? key}) : super(key: key);

  @override
  State<StockEntryScreen> createState() => _StockEntryScreenState();
}

class _StockEntryScreenState extends State<StockEntryScreen> {
  Fournisseur? _selectedFournisseur;
  final List<_StockEntryItem> _items = [];
  String _articleSearch = '';
  final _fournisseurFormKey = GlobalKey<FormState>();
  String _newFournisseurName = '';
  String _newFournisseurPhone = '';
  String _newFournisseurAddress = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<FournisseurProvider>(context, listen: false).loadFournisseurs();
    Provider.of<ArticleProvider>(context, listen: false).loadArticles();
  }

  void _addFournisseurDialog() async {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ajouter Fournisseur',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Form(
                    key: _fournisseurFormKey,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Nom',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator:
                              (v) =>
                                  v == null || v.isEmpty
                                      ? 'Champ requis'
                                      : null,
                          onSaved: (v) => _newFournisseurName = v!,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Téléphone',
                            prefixIcon: Icon(Icons.phone),
                          ),
                          keyboardType: TextInputType.phone,
                          onSaved: (v) => _newFournisseurPhone = v ?? '',
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Adresse',
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          onSaved: (v) => _newFournisseurAddress = v ?? '',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Annuler', style: GoogleFonts.poppins()),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: () async {
                          if (_fournisseurFormKey.currentState!.validate()) {
                            _fournisseurFormKey.currentState!.save();
                            final fournisseur = Fournisseur(
                              name: _newFournisseurName,
                              phone: _newFournisseurPhone,
                              address: _newFournisseurAddress,
                            );
                            await Provider.of<FournisseurProvider>(
                              context,
                              listen: false,
                            ).addFournisseur(fournisseur);
                            Navigator.pop(context);
                            setState(() {});
                          }
                        },
                        child: Text(
                          'Ajouter',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _addArticleToList(Article article) {
    setState(() {
      _items.add(_StockEntryItem(article: article));
    });
  }

  double get _total =>
      _items.fold(0, (sum, item) => sum + (item.buyPrice * item.quantity));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fournisseurProvider = Provider.of<FournisseurProvider>(context);
    final articleProvider = Provider.of<ArticleProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_selectedFournisseur != null) {
              setState(() {
                _selectedFournisseur = null;
                _items.clear();
                _articleSearch = '';
                _searchController.clear();
              });
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          'Entrée Stock',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFFF5F6FA),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText:
                    _selectedFournisseur == null
                        ? 'Rechercher un fournisseur'
                        : 'Rechercher un article pour l\'ajouter',
                prefixIcon: Icon(Icons.search),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _articleSearch = '';
                            });
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: _selectedFournisseur != null,
                fillColor:
                    _selectedFournisseur != null
                        ? theme.colorScheme.primary.withValues(alpha: 0.05)
                        : null,
              ),
              onChanged: (v) => setState(() => _articleSearch = v),
            ),
            const SizedBox(height: 12),
            if (_selectedFournisseur == null) ...[
              Text(
                'Sélectionnez un fournisseur',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              ...fournisseurProvider.fournisseurs
                  .where(
                    (f) =>
                        f.name.toLowerCase().contains(
                          _articleSearch.toLowerCase(),
                        ) ||
                        f.phone.toLowerCase().contains(
                          _articleSearch.toLowerCase(),
                        ) ||
                        (f.address != null &&
                            f.address!.toLowerCase().contains(
                              _articleSearch.toLowerCase(),
                            )),
                  )
                  .map((f) {
                    final isSelected = _selectedFournisseur?.id == f.id;
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side:
                            isSelected
                                ? BorderSide(
                                  color: theme.colorScheme.primary,
                                  width: 2,
                                )
                                : BorderSide.none,
                      ),
                      elevation: isSelected ? 8 : 4,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      color:
                          isSelected
                              ? theme.colorScheme.primary.withValues(
                                alpha: 0.08,
                              )
                              : Colors.white,
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.store, color: Colors.white),
                          backgroundColor: theme.colorScheme.primary,
                        ),
                        title: Text(
                          f.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              f.phone,
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                            if (f.address != null && f.address!.isNotEmpty)
                              Text(
                                f.address!,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: theme.colorScheme.primary,
                              ),
                              tooltip: 'Modifier',
                              onPressed: () async {
                                final nameController = TextEditingController(
                                  text: f.name,
                                );
                                final phoneController = TextEditingController(
                                  text: f.phone,
                                );
                                final addressController = TextEditingController(
                                  text: f.address ?? '',
                                );
                                final result = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        title: Text(
                                          'Modifier Fournisseur',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller: nameController,
                                              decoration: InputDecoration(
                                                labelText: 'Nom',
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            TextField(
                                              controller: phoneController,
                                              decoration: InputDecoration(
                                                labelText: 'Téléphone',
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            TextField(
                                              controller: addressController,
                                              decoration: InputDecoration(
                                                labelText: 'Adresse',
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                            child: Text(
                                              'Annuler',
                                              style: GoogleFonts.poppins(),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              final updatedFournisseur = f
                                                  .copyWith(
                                                    name:
                                                        nameController.text
                                                            .trim(),
                                                    phone:
                                                        phoneController.text
                                                            .trim(),
                                                    address:
                                                        addressController.text
                                                            .trim(),
                                                  );
                                              await fournisseurProvider
                                                  .updateFournisseur(
                                                    updatedFournisseur,
                                                  );
                                              Navigator.pop(context, true);
                                            },
                                            child: Text(
                                              'Enregistrer',
                                              style: GoogleFonts.poppins(),
                                            ),
                                          ),
                                        ],
                                      ),
                                );
                                if (result == true) setState(() {});
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: theme.colorScheme.error,
                              ),
                              tooltip: 'Supprimer',
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: Text(
                                          'Supprimer le fournisseur',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        content: Text(
                                          'Êtes-vous sûr de vouloir supprimer ce fournisseur ?',
                                          style: GoogleFonts.poppins(),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                            child: Text(
                                              'Annuler',
                                              style: GoogleFonts.poppins(),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                            child: Text(
                                              'Supprimer',
                                              style: GoogleFonts.poppins(
                                                color: theme.colorScheme.error,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                );
                                if (confirm == true) {
                                  await fournisseurProvider.deleteFournisseur(
                                    f.id!,
                                  );
                                  setState(() {});
                                }
                              },
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: theme.colorScheme.primary,
                              ),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            _selectedFournisseur = f;
                            _searchController.clear();
                            _articleSearch = '';
                          });
                        },
                      ),
                    );
                  })
                  .toList(),
              const SizedBox(height: 16),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fournisseur: ${_selectedFournisseur!.name}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  TextButton(
                    onPressed:
                        () => setState(() => _selectedFournisseur = null),
                    child: Text('Changer', style: GoogleFonts.poppins()),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_articleSearch.isNotEmpty) ...[
                Text(
                  'Articles trouvés',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                ...articleProvider.articles
                    .where(
                      (a) => a.name.toLowerCase().contains(
                        _articleSearch.toLowerCase(),
                      ),
                    )
                    .map(
                      (article) => Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(
                            article.name,
                            style: GoogleFonts.poppins(),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () => _addArticleToList(article),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ] else ...[
                Text(
                  'Recherchez un article pour l\'ajouter au stock',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (_articleSearch.isNotEmpty &&
                  articleProvider.articles
                      .where(
                        (a) => a.name.toLowerCase().contains(
                          _articleSearch.toLowerCase(),
                        ),
                      )
                      .isEmpty) ...[
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Aucun article trouvé avec "$_articleSearch"',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 16),
              Text(
                'Articles sélectionnés:',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: theme.colorScheme.primary,
                ),
              ),
              ..._items.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value;
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.article.name,
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                        SizedBox(width: 8),
                        SizedBox(
                          width: 60,
                          child: TextFormField(
                            initialValue:
                                item.quantity == 0
                                    ? '0'
                                    : item.quantity.toString(),
                            decoration: InputDecoration(labelText: 'Qté'),
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              setState(() {
                                item.quantity = int.tryParse(v) ?? 0;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        SizedBox(
                          width: 80,
                          child: TextFormField(
                            initialValue:
                                item.buyPrice == 0
                                    ? '0'
                                    : item.buyPrice.toString(),
                            decoration: InputDecoration(labelText: 'Achat'),
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              setState(() {
                                item.buyPrice = double.tryParse(v) ?? 0;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        SizedBox(
                          width: 80,
                          child: TextFormField(
                            initialValue:
                                item.sellPrice == 0
                                    ? '0'
                                    : item.sellPrice.toString(),
                            decoration: InputDecoration(labelText: 'Vente'),
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              setState(() {
                                item.sellPrice = double.tryParse(v) ?? 0;
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => setState(() => _items.removeAt(idx)),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 8),
              Text(
                'Total: ${Formatters.formatCurrency(_total)}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_items.any((item) => item.quantity <= 0)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Veuillez entrer une quantité supérieure à zéro pour chaque article.',
                        ),
                      ),
                    );
                    return;
                  }
                  final articleProvider = Provider.of<ArticleProvider>(
                    context,
                    listen: false,
                  );
                  for (final item in _items) {
                    // Update article with new total quantity and latest prices
                    final updatedArticle = Article(
                      id: item.article.id,
                      name: item.article.name,
                      provider: _selectedFournisseur?.name ?? '',
                      buyPrice: item.buyPrice,
                      sellPrice: item.sellPrice,
                      quantity: (item.article.quantity + item.quantity),
                      categoryId: item.article.categoryId,
                      purchaseDate: DateTime.now().toIso8601String().substring(
                        0,
                        10,
                      ),
                    );
                    await articleProvider.updateArticle(updatedArticle);

                    // Record the purchase in the purchases table
                    final purchase = Purchase(
                      articleId: item.article.id!,
                      articleName: item.article.name,
                      supplier: _selectedFournisseur?.name ?? '',
                      buyPrice: item.buyPrice,
                      sellPrice: item.sellPrice,
                      quantity: item.quantity,
                      purchaseDate: DateTime.now().toIso8601String().substring(
                        0,
                        10,
                      ),
                    );
                    await articleProvider.addPurchase(purchase);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Stock enregistré avec succès!')),
                  );
                  setState(() {
                    _items.clear();
                    _selectedFournisseur = null;
                  });
                },
                child: Text(
                  'Enregistrer',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),

      floatingActionButton:
          _selectedFournisseur == null
              ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton.extended(
                    heroTag: "check_stock_button",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CheckStockScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.analytics_outlined),
                    label: const Text('Stock'),
                    tooltip: 'Check Stock - فحص المخزون',
                    backgroundColor: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton.extended(
                        heroTag: "add_fournisseur_button",
                        onPressed: _addFournisseurDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter Fournisseur'),
                        tooltip: 'Ajouter Fournisseur',
                      ),
                      const SizedBox(width: 16),
                      FloatingActionButton.extended(
                        heroTag: "purchase_history_button",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const PurchaseHistoryScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.history),
                        label: const Text('Historique des Achats'),
                        tooltip: 'Historique des Achats',
                        backgroundColor: Colors.purple,
                      ),
                    ],
                  ),
                ],
              )
              : null,
    );
  }
}

class _StockEntryItem {
  final Article article;
  int quantity;
  double buyPrice;
  double sellPrice;

  _StockEntryItem({
    required this.article,
    this.quantity = 0,
    this.buyPrice = 0,
    this.sellPrice = 0,
  });
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/article.dart';
import '../../domain/entities/category.dart';
import '../../presentation/providers/article_provider.dart';
import '../../presentation/providers/category_provider.dart';
import 'add_category_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class AddArticleScreen extends StatefulWidget {
  final Article? article;
  const AddArticleScreen({Key? key, this.article}) : super(key: key);

  @override
  State<AddArticleScreen> createState() => _AddArticleScreenState();
}

class _AddArticleScreenState extends State<AddArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _provider = '';
  double _buyPrice = 0;
  double _sellPrice = 0;
  int _quantity = 0;
  int? _categoryId;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    Provider.of<CategoryProvider>(context, listen: false).loadCategories();
    // Prefill fields if editing
    if (widget.article != null) {
      _name = widget.article!.name;
      _provider = widget.article!.provider;
      _buyPrice = widget.article!.buyPrice;
      _sellPrice = widget.article!.sellPrice;
      _quantity = widget.article!.quantity;
      _categoryId = widget.article!.categoryId;
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.article == null ? 'Ajouter Article' : 'Modifier Article',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Consumer<CategoryProvider>(
                  builder: (context, catProvider, _) {
                    return Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            initialValue: _initialized ? _name : null,
                            decoration: InputDecoration(
                              labelText: 'Nom de l\'article - اسم المادة',
                              prefixIcon: const Icon(Icons.label_outline),
                            ),
                            style: GoogleFonts.poppins(),
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Champ requis'
                                        : null,
                            onSaved: (value) => _name = value!,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: _initialized ? _provider : null,
                            decoration: InputDecoration(
                              labelText: 'Fournisseur - المورّد',
                              prefixIcon: const Icon(Icons.store_outlined),
                            ),
                            style: GoogleFonts.poppins(),
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Champ requis'
                                        : null,
                            onSaved: (value) => _provider = value!,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue:
                                _initialized ? _buyPrice.toString() : null,
                            decoration: InputDecoration(
                              labelText: 'Prix d\'achat - سعر الشراء',
                              prefixIcon: const Icon(
                                Icons.attach_money_outlined,
                              ),
                            ),
                            style: GoogleFonts.poppins(),
                            keyboardType: TextInputType.number,
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Champ requis'
                                        : null,
                            onSaved:
                                (value) =>
                                    _buyPrice = double.tryParse(value!) ?? 0,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue:
                                _initialized ? _sellPrice.toString() : null,
                            decoration: InputDecoration(
                              labelText: 'Prix de vente - سعر البيع',
                              prefixIcon: const Icon(
                                Icons.price_change_outlined,
                              ),
                            ),
                            style: GoogleFonts.poppins(),
                            keyboardType: TextInputType.number,
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Champ requis'
                                        : null,
                            onSaved:
                                (value) =>
                                    _sellPrice = double.tryParse(value!) ?? 0,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue:
                                _initialized ? _quantity.toString() : null,
                            decoration: InputDecoration(
                              labelText: 'Quantité - الكمية',
                              prefixIcon: const Icon(
                                Icons.inventory_2_outlined,
                              ),
                            ),
                            style: GoogleFonts.poppins(),
                            keyboardType: TextInputType.number,
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Champ requis'
                                        : null,
                            onSaved:
                                (value) =>
                                    _quantity = int.tryParse(value!) ?? 0,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int>(
                            value: _initialized ? _categoryId : null,
                            decoration: InputDecoration(
                              labelText: 'Catégorie - الفئة',
                              prefixIcon: const Icon(Icons.category_outlined),
                            ),
                            items:
                                catProvider.categories
                                    .map(
                                      (cat) => DropdownMenuItem(
                                        value: cat.id,
                                        child: Text(
                                          cat.name,
                                          style: GoogleFonts.poppins(),
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (value) => setState(() => _categoryId = value),
                            validator:
                                (value) =>
                                    value == null
                                        ? 'Sélectionnez une catégorie - اختر فئة'
                                        : null,
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const AddCategoryScreen(),
                                ),
                              );
                              // Reload categories after adding
                              await Provider.of<CategoryProvider>(
                                context,
                                listen: false,
                              ).loadCategories();
                            },
                            icon: const Icon(Icons.add),
                            label: Text(
                              'Ajouter une catégorie - إضافة فئة',
                              style: GoogleFonts.poppins(),
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: Icon(
                                widget.article == null
                                    ? Icons.add_circle_outline
                                    : Icons.save_alt_rounded,
                                color: Colors.white,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                textStyle: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  if (widget.article == null) {
                                    final article = Article(
                                      name: _name,
                                      provider: _provider,
                                      buyPrice: _buyPrice,
                                      sellPrice: _sellPrice,
                                      quantity: _quantity,
                                      categoryId: _categoryId!,
                                    );
                                    await Provider.of<ArticleProvider>(
                                      context,
                                      listen: false,
                                    ).addArticle(article);
                                  } else {
                                    final updated = Article(
                                      id: widget.article!.id,
                                      name: _name,
                                      provider: _provider,
                                      buyPrice: _buyPrice,
                                      sellPrice: _sellPrice,
                                      quantity: _quantity,
                                      categoryId: _categoryId!,
                                    );
                                    await Provider.of<ArticleProvider>(
                                      context,
                                      listen: false,
                                    ).updateArticle(updated);
                                  }
                                  Navigator.of(
                                    context,
                                  ).popUntil((route) => route.isFirst);
                                }
                              },
                              label: Text(
                                widget.article == null
                                    ? 'Ajouter - إضافة'
                                    : 'Enregistrer - حفظ',
                                style: GoogleFonts.poppins(
                                  color:
                                      Colors
                                          .white, // Ensure text is always white for contrast
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


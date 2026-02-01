import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/client.dart';
import '../models/article.dart';
import '../models/vente.dart';
import '../models/vente_article.dart';
import '../providers/article_provider.dart';
import '../providers/vente_provider.dart';
import '../providers/client_provider.dart';
import '../db/database_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/formatters.dart';

class AddVenteScreen extends StatefulWidget {
  final Client client;
  final Vente? vente;
  final List<VenteArticle>? venteArticles;
  const AddVenteScreen({
    Key? key,
    required this.client,
    this.vente,
    this.venteArticles,
  }) : super(key: key);

  @override
  State<AddVenteScreen> createState() => _AddVenteScreenState();
}

class _AddVenteScreenState extends State<AddVenteScreen> {
  final Map<int, int> _selectedQuantities = {}; // articleId -> quantity
  final Map<int, TextEditingController> _quantityControllers =
      {}; // articleId -> controller
  bool _isPaid = true;
  String? _description;
  double? _amountPaid;
  final _formKey = GlobalKey<FormState>();
  bool _initialized = false;
  String _articleSearch = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ensure articles are loaded
    Future.microtask(() {
      Provider.of<ArticleProvider>(context, listen: false).loadArticles();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized && widget.vente != null && widget.venteArticles != null) {
      // Prefill fields for editing
      _isPaid = widget.vente!.isPaid;
      _description = widget.vente!.description;
      _amountPaid =
          widget.vente!.isPaid
              ? widget.vente!.total
              : (widget.vente!.total - widget.vente!.credit);
      for (final va in widget.venteArticles!) {
        _selectedQuantities[va.articleId] = va.quantity;
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    // Dispose all quantity controllers
    for (final controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final articleProvider = Provider.of<ArticleProvider>(context);
    final venteProvider = Provider.of<VenteProvider>(context, listen: false);
    final allArticles =
        articleProvider.articles
            .where((a) => a.quantity > 0 || _selectedQuantities[a.id] != null)
            .toList();

    // Filter articles based on search
    final filteredArticles =
        _articleSearch.isEmpty
            ? <Article>[]
            : allArticles
                .where(
                  (a) => a.name.toLowerCase().contains(
                    _articleSearch.toLowerCase(),
                  ),
                )
                .toList();

    double total = 0;
    for (var article in allArticles) {
      final qty = _selectedQuantities[article.id] ?? 0;
      total += qty * article.sellPrice;
    }
    // Professional credit calculation - allows overpayment (negative credit)
    double credit = _isPaid ? 0 : (total - (_amountPaid ?? 0));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          widget.vente == null
              ? 'Nouvelle Vente - عملية بيع جديدة'
              : 'Modifier Vente - تعديل البيع',
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
                child:
                    allArticles.isEmpty
                        ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun article en stock. - لا توجد مواد في المخزون.',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        )
                        : Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Rechercher et sélectionner les articles - البحث عن المواد واختيارها',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Search bar for articles
                              TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  labelText:
                                      'Rechercher un article - البحث عن مادة',
                                  hintText: 'Tapez le nom de l\'article...',
                                  prefixIcon: const Icon(Icons.search),
                                  suffixIcon:
                                      _searchController.text.isNotEmpty
                                          ? IconButton(
                                            icon: const Icon(Icons.clear),
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
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _articleSearch = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                              // Search results
                              if (_articleSearch.isNotEmpty) ...[
                                Text(
                                  'Résultats de recherche:',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...filteredArticles.map((article) {
                                  final qty =
                                      _selectedQuantities[article.id!] ?? 0;
                                  // Setup controller for this article
                                  if (!_quantityControllers.containsKey(
                                    article.id!,
                                  )) {
                                    _quantityControllers[article
                                        .id!] = TextEditingController(
                                      text: qty.toString(),
                                    );
                                  } else if (_quantityControllers[article.id!]!
                                          .text !=
                                      qty.toString()) {
                                    _quantityControllers[article.id!]!.text =
                                        qty.toString();
                                  }
                                  final controller =
                                      _quantityControllers[article.id!]!;
                                  return Card(
                                    color:
                                        qty > 0
                                            ? theme.colorScheme.primary
                                                .withOpacity(0.08)
                                            : Colors.white,
                                    elevation: qty > 0 ? 4 : 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.shopping_bag_outlined,
                                        color: theme.colorScheme.primary,
                                      ),
                                      title: Text(
                                        article.name,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Stock: ${article.quantity} | Prix: ${Formatters.formatCurrency(article.sellPrice)} DA',
                                        style: GoogleFonts.poppins(
                                          color: Colors.black54,
                                        ),
                                      ),
                                      trailing: IntrinsicWidth(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.remove_circle_outline,
                                              ),
                                              color: theme.colorScheme.primary,
                                              onPressed: () {
                                                setState(() {
                                                  final current =
                                                      _selectedQuantities[article
                                                          .id!] ??
                                                      0;
                                                  if (current > 0) {
                                                    _selectedQuantities[article
                                                            .id!] =
                                                        current - 1;
                                                    _quantityControllers[article
                                                            .id!]!
                                                        .text = (current - 1)
                                                            .toString();
                                                  }
                                                });
                                              },
                                            ),
                                            Flexible(
                                              child: SizedBox(
                                                width: 40,
                                                child: TextField(
                                                  controller: controller,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color:
                                                        theme
                                                            .colorScheme
                                                            .primary,
                                                  ),
                                                  decoration:
                                                      const InputDecoration(
                                                        border:
                                                            InputBorder.none,
                                                        isDense: true,
                                                        contentPadding:
                                                            EdgeInsets.symmetric(
                                                              vertical: 8,
                                                            ),
                                                      ),
                                                  onChanged: (value) {
                                                    final newQty =
                                                        int.tryParse(value) ??
                                                        0;
                                                    if (newQty >= 0 &&
                                                        newQty <=
                                                            article.quantity) {
                                                      setState(() {
                                                        _selectedQuantities[article
                                                                .id!] =
                                                            newQty;
                                                      });
                                                    } else if (value
                                                        .isNotEmpty) {
                                                      // Clamp to valid range
                                                      final clamped =
                                                          newQty < 0
                                                              ? 0
                                                              : article
                                                                  .quantity;
                                                      controller.text =
                                                          clamped.toString();
                                                      controller.selection =
                                                          TextSelection.fromPosition(
                                                            TextPosition(
                                                              offset:
                                                                  controller
                                                                      .text
                                                                      .length,
                                                            ),
                                                          );
                                                      setState(() {
                                                        _selectedQuantities[article
                                                                .id!] =
                                                            clamped;
                                                      });
                                                    }
                                                  },
                                                  inputFormatters:
                                                      [], // Optionally add FilteringTextInputFormatter.digitsOnly
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.add_circle_outline,
                                              ),
                                              color: theme.colorScheme.primary,
                                              onPressed: () {
                                                setState(() {
                                                  final current =
                                                      _selectedQuantities[article
                                                          .id!] ??
                                                      0;
                                                  if (current <
                                                      article.quantity) {
                                                    _selectedQuantities[article
                                                            .id!] =
                                                        current + 1;
                                                    _quantityControllers[article
                                                            .id!]!
                                                        .text = (current + 1)
                                                            .toString();
                                                  }
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                if (filteredArticles.isEmpty) ...[
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.08),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            color: theme.colorScheme.primary,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'Aucun article trouvé avec "$_articleSearch"',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w500,
                                                color:
                                                    theme.colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ] else ...[
                                Text(
                                  'Tapez dans la barre de recherche pour trouver des articles',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              // Selected articles summary
                              if (_selectedQuantities.values.any(
                                (qty) => qty > 0,
                              )) ...[
                                Text(
                                  'Articles sélectionnés:',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...allArticles
                                    .where(
                                      (article) =>
                                          (_selectedQuantities[article.id] ??
                                              0) >
                                          0,
                                    )
                                    .map((article) {
                                      final qty =
                                          _selectedQuantities[article.id] ?? 0;
                                      return Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.05),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      article.name,
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                    ),
                                                    Text(
                                                      '${qty} × ${Formatters.formatCurrency(article.sellPrice)} DA = ${Formatters.formatCurrency(qty * article.sellPrice)} DA',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.black54,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.remove_circle_outline,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _selectedQuantities[article
                                                            .id!] =
                                                        0;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    })
                                    .toList(),
                              ],
                              const SizedBox(height: 24),
                              // Client credit balance display
                              FutureBuilder<double>(
                                future: DatabaseHelper().getClientCredit(
                                  widget.client.id!,
                                ),
                                builder: (context, snapshot) {
                                  final clientCredit = snapshot.data ?? 0.0;
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color:
                                          clientCredit > 0
                                              ? Colors.orange.withOpacity(0.1)
                                              : Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color:
                                            clientCredit > 0
                                                ? Colors.orange.withOpacity(0.3)
                                                : Colors.green.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          clientCredit > 0
                                              ? Icons.account_balance_wallet
                                              : Icons.account_balance,
                                          color:
                                              clientCredit > 0
                                                  ? Colors.orange
                                                  : Colors.green,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                clientCredit > 0
                                                    ? 'Crédit client - رصيد العميل'
                                                    : 'Solde positif - رصيد إيجابي',
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      clientCredit > 0
                                                          ? Colors.orange
                                                          : Colors.green,
                                                ),
                                              ),
                                              Text(
                                                '${Formatters.formatCurrency(clientCredit.abs())} DA',
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color:
                                                      clientCredit > 0
                                                          ? Colors.orange
                                                          : Colors.green,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(
                                    Icons.payments_outlined,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Payé :',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Switch(
                                    value: _isPaid,
                                    activeColor: theme.colorScheme.primary,
                                    onChanged: (val) {
                                      setState(() {
                                        _isPaid = val;
                                        if (_isPaid) _amountPaid = null;
                                      });
                                    },
                                  ),
                                  Text(
                                    _isPaid ? 'Oui' : 'Non',
                                    style: GoogleFonts.poppins(
                                      color:
                                          _isPaid ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              if (!_isPaid)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextFormField(
                                        decoration: InputDecoration(
                                          labelText:
                                              'Montant payé - المبلغ المدفوع',
                                          hintText: '0 DA',
                                          prefixIcon: const Icon(
                                            Icons.attach_money_outlined,
                                          ),
                                        ),
                                        style: GoogleFonts.poppins(),
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        initialValue:
                                            _amountPaid?.toString() ?? '',
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Veuillez entrer le montant payé';
                                          }
                                          final paid = double.tryParse(value);
                                          if (paid == null) {
                                            return 'Montant invalide';
                                          }
                                          if (paid < 0) {
                                            return 'Le montant ne peut pas être négatif';
                                          }
                                          return null;
                                        },
                                        onChanged: (val) {
                                          setState(() {
                                            _amountPaid =
                                                double.tryParse(val) ?? 0;
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      // Professional credit/overpayment display
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color:
                                              credit > 0
                                                  ? Colors.red.withOpacity(0.1)
                                                  : Colors.green.withOpacity(
                                                    0.1,
                                                  ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color:
                                                credit > 0
                                                    ? Colors.red.withOpacity(
                                                      0.3,
                                                    )
                                                    : Colors.green.withOpacity(
                                                      0.3,
                                                    ),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              credit > 0
                                                  ? Icons.account_balance_wallet
                                                  : Icons.account_balance,
                                              color:
                                                  credit > 0
                                                      ? Colors.red
                                                      : Colors.green,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    credit > 0
                                                        ? 'Crédit restant - رصيد متبقي'
                                                        : 'Surplus payé - فائض مدفوع',
                                                    style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          credit > 0
                                                              ? Colors.red
                                                              : Colors.green,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${Formatters.formatCurrency(credit.abs())} DA',
                                                    style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                      color:
                                                          credit > 0
                                                              ? Colors.red
                                                              : Colors.green,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (credit < 0) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                color: Colors.blue,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  'Le surplus sera ajouté au crédit du client pour les prochaines achats',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color: Colors.blue.shade700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Description (optionnel)',
                                  prefixIcon: const Icon(
                                    Icons.note_alt_outlined,
                                  ),
                                ),
                                style: GoogleFonts.poppins(),
                                initialValue: _description,
                                onChanged: (val) => _description = val,
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total:',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    '${Formatters.formatCurrency(total)} DA',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: Icon(
                                    widget.vente == null
                                        ? Icons.check_circle_outline
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
                                  onPressed:
                                      total > 0
                                          ? () async {
                                            if (!_isPaid &&
                                                !_formKey.currentState!
                                                    .validate()) {
                                              return;
                                            }

                                            // --- PROFESSIONAL ADVANCE USAGE LOGIC ---
                                            double venteCredit = credit;
                                            bool paidByAdvance = false;
                                            if (widget.vente == null &&
                                                !_isPaid) {
                                              // Only for new vente and not paid
                                              final clientAdvance =
                                                  await DatabaseHelper()
                                                      .getClientCredit(
                                                        widget.client.id!,
                                                      );
                                              if (clientAdvance < 0) {
                                                final advanceAbs =
                                                    clientAdvance.abs();
                                                if (advanceAbs >= total) {
                                                  // Advance covers the whole vente
                                                  venteCredit = 0;
                                                  // Mark as paid
                                                  _isPaid = true;
                                                  await DatabaseHelper()
                                                      .useClientCredit(
                                                        widget.client.id!,
                                                        total,
                                                      );
                                                  paidByAdvance = true;
                                                } else {
                                                  // Advance covers part of the vente
                                                  venteCredit =
                                                      total - advanceAbs;
                                                  await DatabaseHelper()
                                                      .useClientCredit(
                                                        widget.client.id!,
                                                        advanceAbs,
                                                      );
                                                }
                                              }
                                            }
                                            // --- END ADVANCE USAGE LOGIC ---

                                            final vente = Vente(
                                              id: widget.vente?.id,
                                              clientId: widget.client.id!,
                                              date:
                                                  widget.vente?.date ??
                                                  DateTime.now()
                                                      .toIso8601String(),
                                              total: total,
                                              isPaid: _isPaid,
                                              description: _description,
                                              credit: venteCredit,
                                            );
                                            final venteArticles =
                                                <VenteArticle>[];
                                            for (var entry
                                                in _selectedQuantities
                                                    .entries) {
                                              if (entry.value > 0) {
                                                final article = allArticles
                                                    .firstWhere(
                                                      (a) => a.id == entry.key,
                                                    );
                                                venteArticles.add(
                                                  VenteArticle(
                                                    venteId:
                                                        widget.vente?.id ?? 0,
                                                    articleId: article.id!,
                                                    quantity: entry.value,
                                                    price: article.sellPrice,
                                                    costPrice: article.buyPrice, // Store cost for benefit tracking
                                                  ),
                                                );
                                              }
                                            }
                                            if (widget.vente == null) {
                                              // Add new vente
                                              for (var entry
                                                  in _selectedQuantities
                                                      .entries) {
                                                if (entry.value > 0) {
                                                  final article = allArticles
                                                      .firstWhere(
                                                        (a) =>
                                                            a.id == entry.key,
                                                      );
                                                  await articleProvider
                                                      .updateArticle(
                                                        Article(
                                                          id: article.id,
                                                          name: article.name,
                                                          provider:
                                                              article.provider,
                                                          buyPrice:
                                                              article.buyPrice,
                                                          sellPrice:
                                                              article.sellPrice,
                                                          quantity:
                                                              article.quantity -
                                                              entry.value,
                                                          categoryId:
                                                              article
                                                                  .categoryId,
                                                        ),
                                                      );
                                                }
                                              }
                                              await venteProvider.addVente(
                                                vente,
                                                venteArticles,
                                              );
                                              // Always reload client credit after adding vente
                                              await Provider.of<ClientProvider>(
                                                context,
                                                listen: false,
                                              ).loadClients();
                                              setState(() {});
                                            } else {
                                              // Edit vente: update vente and vente_articles
                                              await venteProvider.updateVente(
                                                vente,
                                              );
                                              // Remove old vente_articles and add new ones
                                              final db = DatabaseHelper();
                                              final database =
                                                  await db.database;
                                              await database.delete(
                                                'vente_articles',
                                                where: 'venteId = ?',
                                                whereArgs: [widget.vente!.id],
                                              );
                                              for (final va in venteArticles) {
                                                await db.insertVenteArticle(va);
                                              }

                                              // Refresh client data to show updated credit
                                              await Provider.of<ClientProvider>(
                                                context,
                                                listen: false,
                                              ).loadClients();
                                            }
                                            Navigator.pop(context);
                                          }
                                          : null,
                                  label: Text(
                                    widget.vente == null
                                        ? 'Valider la vente'
                                        : 'Enregistrer les modifications',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

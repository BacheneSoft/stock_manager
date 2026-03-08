import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/article_provider.dart';
import '../../domain/entities/article.dart';
import 'add_article_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../presentation/providers/category_provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Stock Manager',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.primaryColor, theme.colorScheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo or illustration
              Hero(
                tag: 'logo',
                child: Image.asset('assets/modern_logo.png', height: 120),
              ),
              SizedBox(height: 32),
              Text(
                'Bienvenue!',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 48),
              AnimatedButton(
                icon: Icons.inventory_2_rounded,
                label: 'Gérer le Stock',
                onTap: () => Navigator.pushNamed(context, '/stock'),
                color: theme.primaryColorLight,
              ),
              SizedBox(height: 24),
              AnimatedButton(
                icon: Icons.people_alt_rounded,
                label: 'Clients & Ventes',
                onTap: () => Navigator.pushNamed(context, '/clients'),
                color: theme.colorScheme.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const AnimatedButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              SizedBox(width: 16),
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 20, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StockListScreen extends StatefulWidget {
  const StockListScreen({Key? key}) : super(key: key);

  @override
  State<StockListScreen> createState() => _StockListScreenState();
}

class _StockListScreenState extends State<StockListScreen>
    with SingleTickerProviderStateMixin {
  bool _selectionMode = false;
  final Set<int> _selectedArticleIds = {};
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    Provider.of<ArticleProvider>(context, listen: false).loadArticles();
    Provider.of<CategoryProvider>(context, listen: false).loadCategories();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelectionMode() {
    setState(() {
      _selectionMode = !_selectionMode;
      if (!_selectionMode) {
        _selectedArticleIds.clear();
      }
    });
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
      _searchController.text = _searchQuery;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _onArticleTap(int articleId) {
    if (_selectionMode) {
      setState(() {
        if (_selectedArticleIds.contains(articleId)) {
          _selectedArticleIds.remove(articleId);
        } else {
          _selectedArticleIds.add(articleId);
        }
      });
    } else {
      // TODO: Edit article
    }
  }

  Future<void> _deleteSelectedArticles(BuildContext context) async {
    if (_selectedArticleIds.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Supprimer les articles'),
            content: Text(
              'Êtes-vous sûr de vouloir supprimer les articles sélectionnés (${_selectedArticleIds.length}) ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );
    if (confirm == true) {
      final provider = Provider.of<ArticleProvider>(context, listen: false);
      for (final id in _selectedArticleIds) {
        await provider.deleteArticle(id);
      }
      setState(() {
        _selectionMode = false;
        _selectedArticleIds.clear();
      });
    }
  }

  void _showFilterSheet() async {
    final categories =
        Provider.of<CategoryProvider>(context, listen: false).categories;
    int? tempCategoryId = _selectedCategoryId;
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filtrer par catégorie',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: tempCategoryId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('Toutes les catégories'),
                  ),
                  ...categories.map(
                    (cat) => DropdownMenuItem<int>(
                      value: cat.id,
                      child: Text(cat.name),
                    ),
                  ),
                ],
                onChanged: (val) {
                  tempCategoryId = val;
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategoryId = tempCategoryId;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Appliquer'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _clearFilter() {
    setState(() {
      _selectedCategoryId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading:
            _selectionMode
                ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _toggleSelectionMode,
                )
                : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Rechercher...',
                    hintStyle: GoogleFonts.poppins(color: Colors.black54),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                )
                : Text(
                  'Stock',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search_rounded),
              tooltip: 'Rechercher',
              onPressed: _startSearch,
            ),
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              tooltip: 'Annuler la recherche',
              onPressed: _stopSearch,
            ),
          if (_selectedCategoryId != null)
            IconButton(
              icon: const Icon(Icons.filter_alt_off_rounded),
              tooltip: 'Effacer le filtre',
              onPressed: _clearFilter,
            )
          else
            IconButton(
              icon: const Icon(Icons.filter_alt_rounded),
              tooltip: 'Filtrer',
              onPressed: _showFilterSheet,
            ),
          if (_selectionMode)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Supprimer',
              onPressed:
                  _selectedArticleIds.isEmpty
                      ? null
                      : () => _deleteSelectedArticles(context),
            )
          else
            IconButton(
              icon: const Icon(Icons.check_box_outlined),
              tooltip: 'Mode sélection',
              onPressed: _toggleSelectionMode,
            ),
        ],
      ),
      body: Container(
        color: const Color(0xFFF7F8FA),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Consumer<ArticleProvider>(
                  builder: (context, provider, _) {
                    // Filter articles by search and category
                    List<Article> filteredArticles = provider.articles;
                    if (_selectedCategoryId != null) {
                      filteredArticles =
                          filteredArticles
                              .where((a) => a.categoryId == _selectedCategoryId)
                              .toList();
                    }
                    if (_isSearching && _searchQuery.isNotEmpty) {
                      final query = _searchQuery.toLowerCase();
                      filteredArticles =
                          filteredArticles.where((article) {
                            return article.name.toLowerCase().contains(query) ||
                                article.provider.toLowerCase().contains(query);
                          }).toList();
                    }

                    if (filteredArticles.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_rounded,
                            size: 64,
                            color: theme.colorScheme.primary.withValues(alpha: 0.7),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isSearching && _searchQuery.isNotEmpty
                                ? 'Aucun résultat'
                                : 'Aucun article en stock',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isSearching && _searchQuery.isNotEmpty
                                ? 'Essayez un autre mot-clé.'
                                : 'Ajoutez des articles pour commencer.',
                            style: GoogleFonts.poppins(color: Colors.black54),
                          ),
                        ],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Articles en stock',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.separated(
                            itemCount: filteredArticles.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final article = filteredArticles[index];
                              final selected = _selectedArticleIds.contains(
                                article.id,
                              );
                              return Card(
                                color:
                                    selected
                                        ? theme.colorScheme.primary.withOpacity(
                                          0.08,
                                        )
                                        : Colors.white,
                                elevation: selected ? 4 : 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side:
                                      selected
                                          ? BorderSide(
                                            color: theme.colorScheme.primary,
                                            width: 2,
                                          )
                                          : BorderSide.none,
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: theme.colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    child: Icon(
                                      Icons.widgets_rounded,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  title: Text(
                                    article.name,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Fournisseur: ${article.provider}\nQté: ${article.quantity}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  trailing:
                                      _selectionMode
                                          ? Checkbox(
                                            value: selected,
                                            onChanged: (checked) {
                                              _onArticleTap(article.id!);
                                            },
                                          )
                                          : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${article.sellPrice.toStringAsFixed(2)} DA',
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      theme.colorScheme.primary,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Icon(
                                                Icons.chevron_right,
                                                color:
                                                    theme.colorScheme.primary,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                  selected: selected,
                                  onTap: () async {
                                    if (_selectionMode) {
                                      _onArticleTap(article.id!);
                                    } else {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => AddArticleScreen(
                                                article: article,
                                              ),
                                        ),
                                      );
                                      Provider.of<ArticleProvider>(
                                        context,
                                        listen: false,
                                      ).loadArticles();
                                    }
                                  },
                                  onLongPress:
                                      !_selectionMode
                                          ? () {
                                            setState(() {
                                              _selectionMode = true;
                                              _selectedArticleIds.add(
                                                article.id!,
                                              );
                                            });
                                          }
                                          : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton:
          !_selectionMode
              ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddArticleScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Ajouter'),
                tooltip: 'Ajouter Article',
              )
              : null,
    );
  }
}

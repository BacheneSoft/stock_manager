import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/article.dart';
import '../../presentation/providers/article_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_article_name_screen.dart';

class ArticlesListScreen extends StatefulWidget {
  const ArticlesListScreen({Key? key}) : super(key: key);

  @override
  State<ArticlesListScreen> createState() => _ArticlesListScreenState();
}

class _ArticlesListScreenState extends State<ArticlesListScreen> {
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<ArticleProvider>(context, listen: false).loadArticles();
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

  void _editArticle(Article article) {
    final controller = TextEditingController(text: article.name);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Modifier Article', style: GoogleFonts.poppins()),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(labelText: 'Nom de l\'article'),
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Annuler', style: GoogleFonts.poppins()),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (controller.text.trim().isNotEmpty) {
                    final updatedArticle = Article(
                      id: article.id,
                      name: controller.text.trim(),
                      provider: article.provider,
                      buyPrice: article.buyPrice,
                      sellPrice: article.sellPrice,
                      quantity: article.quantity,
                      categoryId: article.categoryId,
                    );
                    await Provider.of<ArticleProvider>(
                      context,
                      listen: false,
                    ).updateArticle(updatedArticle);
                    Navigator.pop(context);
                  }
                },
                child: Text('Modifier', style: GoogleFonts.poppins()),
              ),
            ],
          ),
    );
  }

  void _deleteArticle(Article article) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Supprimer Article', style: GoogleFonts.poppins()),
            content: Text(
              'Êtes-vous sûr de vouloir supprimer "${article.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Annuler', style: GoogleFonts.poppins()),
              ),
              ElevatedButton(
                onPressed: () async {
                  await Provider.of<ArticleProvider>(
                    context,
                    listen: false,
                  ).deleteArticle(article.id!);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Supprimer', style: GoogleFonts.poppins()),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
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
                    hintText: 'Rechercher un article...',
                    hintStyle: GoogleFonts.poppins(color: Colors.black54),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                )
                : Hero(
                  tag: 'app_title',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      'Articles',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search_rounded),
              tooltip: 'Rechercher',
              onPressed: () {
                setState(() {
                  _isSearching = true;
                  _searchController.text = _searchQuery;
                });
              },
            ),
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              tooltip: 'Annuler la recherche',
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
            ),
        ],
      ),
      body: Container(
        color: const Color(0xFFF5F6FA),
        child: Consumer<ArticleProvider>(
          builder: (context, articleProvider, child) {
            final filteredArticles =
                articleProvider.articles
                    .where(
                      (article) => article.name.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                    )
                    .toList();
            if (filteredArticles.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.widgets_rounded,
                      size: 80,
                      color: theme.colorScheme.primary.withOpacity(0.7),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isSearching && _searchQuery.isNotEmpty
                          ? 'Aucun résultat'
                          : 'Aucun article',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isSearching && _searchQuery.isNotEmpty
                          ? 'Essayez un autre mot-clé.'
                          : 'Ajoutez des articles pour commencer.',
                      style: GoogleFonts.poppins(color: Colors.black54),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              itemCount: filteredArticles.length,
              itemBuilder: (context, index) {
                final article = filteredArticles[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withOpacity(
                        0.1,
                      ),
                      child: Icon(
                        Icons.widgets_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      article.name,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editArticle(article),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteArticle(article),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddArticleNameScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
        tooltip: 'Ajouter Article',
      ),
    );
  }
}

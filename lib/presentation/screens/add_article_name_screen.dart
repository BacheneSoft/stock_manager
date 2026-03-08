import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/article.dart';
import '../../presentation/providers/article_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'articles_list_screen.dart';

class AddArticleNameScreen extends StatefulWidget {
  const AddArticleNameScreen({Key? key}) : super(key: key);

  @override
  State<AddArticleNameScreen> createState() => _AddArticleNameScreenState();
}

class _AddArticleNameScreenState extends State<AddArticleNameScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        //backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Ajouter un Article',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        color: const Color(0xFFF5F6FA),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
          children: [
            Text(
              'Nom de l\'article - اسم المادة',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nom de l\'article - اسم المادة',
                  prefixIcon: const Icon(Icons.label_outline),
                ),
                style: GoogleFonts.poppins(),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Champ requis' : null,
                onSaved: (value) => _name = value!,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  await Provider.of<ArticleProvider>(
                    context,
                    listen: false,
                  ).addArticle(
                    Article(
                      name: _name,
                      provider: '', // Default or handled by repo
                      buyPrice: 0.0,
                      sellPrice: 0.0,
                      quantity: 0,
                      categoryId: 0, // Default or handled by repo
                    ),
                  );
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Article ajouté!')));
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text(
                'Ajouter',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

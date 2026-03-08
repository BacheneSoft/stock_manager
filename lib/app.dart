import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'presentation/providers/article_provider.dart';
import 'presentation/providers/category_provider.dart';
import 'presentation/providers/client_provider.dart';
import 'presentation/providers/fournisseur_provider.dart';
import 'presentation/providers/vente_provider.dart';
import 'presentation/screens/activation_screen.dart';
import 'presentation/screens/pin_lock_screen.dart';
import 'db/database_helper.dart';
import 'data/repositories/article_repository.dart';
import 'data/repositories/client_repository.dart';
import 'data/repositories/vente_repository.dart';
import 'data/repositories/fournisseur_repository.dart';
import 'data/repositories/category_repository.dart';

class StockManagerApp extends StatelessWidget {
  final bool isActivated;

  const StockManagerApp({Key? key, required this.isActivated})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dbHelper = DatabaseHelper();
    final articleRepo = ArticleRepository(dbHelper);
    final clientRepo = ClientRepository(dbHelper);
    final venteRepo = VenteRepository(dbHelper);
    final fournisseurRepo = FournisseurRepository(dbHelper);
    final categoryRepo = CategoryRepository(dbHelper);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ArticleProvider(articleRepo)),
        ChangeNotifierProvider(create: (_) => CategoryProvider(categoryRepo)),
        ChangeNotifierProvider(create: (_) => ClientProvider(clientRepo)),
        ChangeNotifierProvider(create: (_) => VenteProvider(venteRepo)),
        ChangeNotifierProvider(
          create: (_) => FournisseurProvider(fournisseurRepo),
        ),
      ],
      child: MaterialApp(
        title: 'Stock Manager',
        theme: ThemeData(
          colorScheme: AppTheme.colorScheme,
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
          scaffoldBackgroundColor: AppTheme.colorScheme.background,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: AppTheme.colorScheme.primary),
            titleTextStyle: GoogleFonts.poppins(
              color: AppTheme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        home: isActivated ? const PinLockWrapper() : const ActivationScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

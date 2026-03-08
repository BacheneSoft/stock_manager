import 'package:bachene_soft/utils/permission_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'stock_list_screen.dart';
import 'clients_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:external_path/external_path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'add_article_name_screen.dart';
import 'stock_entry_screen.dart';
import 'articles_list_screen.dart';
import 'purchase_history_screen.dart';
import '../../db/database_helper.dart';
import '../../data/models/cloture.dart';
import '../../utils/formatters.dart';
import 'cloture_history_screen.dart';
import 'benefit_report_screen.dart';
import 'inventory_check_screen.dart';
import '../../core/config/app_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _turnover = 0.0;
  double _collections = 0.0;
  double _benefit = 0.0; // Cumulative benefit
  String? _lastClotureDate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final db = DatabaseHelper();
    _lastClotureDate = await db.getLastClotureDate();
    _turnover = await db.getTurnoverSince(_lastClotureDate);
    _collections = await db.getCollectionsSince(_lastClotureDate);
    _benefit = await db.getTotalBenefit(); // Load cumulative benefit
    setState(() => _isLoading = false);
  }

  Future<void> _showClotureDialog() async {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clôture de la caisse'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Chiffre d\'affaire: ${Formatters.formatCurrency(_turnover)}',
                ),
                Text(
                  'Encaissement: ${Formatters.formatCurrency(_collections)}',
                ),
                Text(
                  'Bénéfice cumulé: ${Formatters.formatCurrency(_benefit)}',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Montant en caisse',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(amountController.text);
                  if (amount != null) {
                    await _performCloture(amount);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Valider'),
              ),
            ],
          ),
    );
  }

  Future<void> _performCloture(double amount) async {
    final db = DatabaseHelper();
    final cloture = Cloture(
      date: DateTime.now().toIso8601String(),
      montant: amount,
      calculatedCA: _turnover,
      calculatedEncaissement: _collections,
      calculatedBenefit: _benefit, // Save cumulative benefit
    );
    await db.insertCloture(cloture);
    await db.resetBenefit(); // Reset benefit after saving to cloture
    await _loadData(); // Reset counters
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Clôture effectuée avec succès')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF141E46),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Hero(
          tag: 'app_title',
          child: Material(
            color: Colors.transparent,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Stock Manager - مدير المخزون',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (AppConfig.isDemoMode)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'DEMO',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: 'Historique des clôtures',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ClotureHistoryScreen(),
                ),
              );
            },
          ),
          FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              final prefs = snapshot.data!;
              final hasPin = prefs.getString('app_pin') != null;
              return IconButton(
                icon: Icon(
                  hasPin ? Icons.lock_rounded : Icons.pin_outlined,
                  color: Colors.white,
                ),
                tooltip:
                    hasPin
                        ? 'Changer le code PIN - تغيير رمز PIN'
                        : 'Définir un code PIN - تعيين رمز PIN',
                onPressed: () async {
                  if (!hasPin) {
                    // Set new PIN (no current PIN)
                    final controller = TextEditingController();
                    final result = await showDialog<String>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: Text(
                            'Définir un code PIN - تعيين رمز PIN',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            maxLength: 6,
                            decoration: InputDecoration(
                              labelText:
                                  'Code PIN (4-6 chiffres) - يجب أن يحتوي رمز PIN على 4 إلى 6 أرقام.',
                              prefixIcon: const Icon(Icons.pin_outlined),
                            ),
                            style: GoogleFonts.poppins(),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Annuler',
                                style: GoogleFonts.poppins(),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final pin = controller.text.trim();
                                if (pin.length < 4 ||
                                    pin.length > 6 ||
                                    int.tryParse(pin) == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Le code PIN doit contenir 4 à 6 chiffres. - يجب أن يحتوي رمز PIN على 4 إلى 6 أرقام.',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      backgroundColor: theme.colorScheme.error,
                                    ),
                                  );
                                  return;
                                }
                                Navigator.pop(context, pin);
                              },
                              child: Text(
                                'Valider',
                                style: GoogleFonts.poppins(),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                    if (result != null && result.isNotEmpty) {
                      await prefs.setString('app_pin', result);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Code PIN enregistré. - تم حفظ رمز PIN.',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: theme.colorScheme.primary,
                        ),
                      );
                    }
                  } else {
                    // Change PIN (require current PIN)
                    final currentPinController = TextEditingController();
                    final newPinController = TextEditingController();
                    String? errorText;
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: Text(
                                'Changer le code PIN - تغيير رمز PIN',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: currentPinController,
                                    keyboardType: TextInputType.number,
                                    obscureText: true,
                                    maxLength: 6,
                                    decoration: InputDecoration(
                                      labelText: 'PIN actuel - رمز PIN الحالي',
                                      prefixIcon: const Icon(
                                        Icons.lock_outline,
                                      ),
                                      errorText: errorText,
                                    ),
                                    style: GoogleFonts.poppins(),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: newPinController,
                                    keyboardType: TextInputType.number,
                                    obscureText: true,
                                    maxLength: 6,
                                    decoration: InputDecoration(
                                      labelText:
                                          'Nouveau PIN (4-6 chiffres) - رمز PIN الجديد (4-6 أرقام)',
                                      prefixIcon: const Icon(
                                        Icons.pin_outlined,
                                      ),
                                    ),
                                    style: GoogleFonts.poppins(),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'Annuler',
                                    style: GoogleFonts.poppins(),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final currentPin =
                                        currentPinController.text.trim();
                                    final savedPin = prefs.getString('app_pin');
                                    if (currentPin != savedPin) {
                                      setState(
                                        () =>
                                            errorText =
                                                'PIN actuel incorrect - رمز PIN الحالي غير صحيح',
                                      );
                                      return;
                                    }
                                    await prefs.remove('app_pin');
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Code PIN supprimé. - تم حذف رمز PIN.',
                                          style: GoogleFonts.poppins(),
                                        ),
                                        backgroundColor:
                                            theme.colorScheme.primary,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Supprimer le code PIN',
                                    style: GoogleFonts.poppins(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final currentPin =
                                        currentPinController.text.trim();
                                    final newPin = newPinController.text.trim();
                                    final savedPin = prefs.getString('app_pin');
                                    if (currentPin != savedPin) {
                                      setState(
                                        () =>
                                            errorText = 'PIN actuel incorrect',
                                      );
                                      return;
                                    }
                                    if (newPin.length < 4 ||
                                        newPin.length > 6 ||
                                        int.tryParse(newPin) == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Le nouveau PIN doit contenir 4 à 6 chiffres. - يجب أن يحتوي رمز PIN الجديد على 4 إلى 6 أرقام.',
                                            style: GoogleFonts.poppins(),
                                          ),
                                          backgroundColor:
                                              theme.colorScheme.error,
                                        ),
                                      );
                                      return;
                                    }
                                    await prefs.setString('app_pin', newPin);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Code PIN modifié. - تم تغيير رمز PIN.',
                                          style: GoogleFonts.poppins(),
                                        ),
                                        backgroundColor:
                                            theme.colorScheme.primary,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Valider',
                                    style: GoogleFonts.poppins(),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.article_outlined,
                                color: Color(0xFF141E46),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[350],
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
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const ArticlesListScreen(),
                                  ),
                                ).then((_) => _loadData());
                              },
                              label: Hero(
                                tag: 'btn_articles',
                                child: Material(
                                  color: Colors.transparent,
                                  child: Text(
                                    'Articles - المواد',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF141E46),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.inventory_2_outlined,
                                color: const Color(0xFF141E46),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[350],
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
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const StockEntryScreen(),
                                  ),
                                ).then((_) => _loadData());
                              },
                              label: Text(
                                'Stock - المخزون',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF141E46),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.fact_check_outlined,
                                color: const Color(0xFF141E46),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFF3E0),
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
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const InventoryCheckScreen(),
                                  ),
                                ).then((_) => _loadData());
                              },
                              label: Text(
                                'Stock Rest - المخزون المتبقي',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF141E46),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.point_of_sale_rounded,
                                color: Color(0xFF141E46),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD9F4E9),
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
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const ClientsListScreen(),
                                  ),
                                ).then((_) => _loadData());
                              },
                              label: Hero(
                                tag: 'btn_vente',
                                child: Material(
                                  color: Colors.transparent,
                                  child: Text(
                                    'Vente - المبيعات',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF141E46),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(
                                Icons.backup_outlined,
                                color: Color(0xFF141E46),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[350],
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () async {
                                final parentContext = context;
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: Text(
                                          'Exporter la base de données',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        content: Text(
                                          'Choisissez une méthode d\'exportation :',
                                          style: GoogleFonts.poppins(),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              try {
                                                final hasPerm =
                                                    await requestStoragePermission(
                                                      parentContext,
                                                    );
                                                if (!hasPerm) {
                                                  ScaffoldMessenger.of(
                                                    parentContext,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Storage permission denied. - تم رفض إذن التخزين.',
                                                        style:
                                                            GoogleFonts.poppins(),
                                                      ),
                                                      backgroundColor:
                                                          theme
                                                              .colorScheme
                                                              .error,
                                                    ),
                                                  );
                                                  return;
                                                }
                                                final dbPath =
                                                    await getDatabasesPath();
                                                final dbBytes =
                                                    await File(
                                                      p.join(
                                                        dbPath,
                                                        'stock_manager.db',
                                                      ),
                                                    ).readAsBytes();
                                                String? selectedDirectory =
                                                    await FilePicker.platform
                                                        .getDirectoryPath();
                                                if (selectedDirectory != null) {
                                                  final backupFile = File(
                                                    p.join(
                                                      selectedDirectory,
                                                      'stock_manager_backup.db',
                                                    ),
                                                  );
                                                  await backupFile.writeAsBytes(
                                                    dbBytes,
                                                    flush: true,
                                                  );
                                                  ScaffoldMessenger.of(
                                                    parentContext,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Backup saved to: ${backupFile.path}',
                                                        style:
                                                            GoogleFonts.poppins(),
                                                      ),
                                                      backgroundColor:
                                                          theme
                                                              .colorScheme
                                                              .primary,
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                ScaffoldMessenger.of(
                                                  parentContext,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Export error: $e - خطأ في التصدير: $e',
                                                      style:
                                                          GoogleFonts.poppins(),
                                                    ),
                                                    backgroundColor:
                                                        theme.colorScheme.error,
                                                  ),
                                                );
                                              }
                                            },
                                            child: Text(
                                              'Enregistrer sur l\'appareil',
                                              style: GoogleFonts.poppins(),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              try {
                                                final hasPerm =
                                                    await requestStoragePermission(
                                                      parentContext,
                                                    );
                                                if (!hasPerm) {
                                                  ScaffoldMessenger.of(
                                                    parentContext,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Storage permission denied. - تم رفض إذن التخزين.',
                                                        style:
                                                            GoogleFonts.poppins(),
                                                      ),
                                                      backgroundColor:
                                                          theme
                                                              .colorScheme
                                                              .error,
                                                    ),
                                                  );
                                                  return;
                                                }
                                                final dbPath =
                                                    await getDatabasesPath();
                                                final dbFile = File(
                                                  p.join(
                                                    dbPath,
                                                    'stock_manager.db',
                                                  ),
                                                );
                                                if (!await dbFile.exists()) {
                                                  if (!parentContext.mounted)
                                                    return;
                                                  ScaffoldMessenger.of(
                                                    parentContext,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Database file not found.',
                                                        style:
                                                            GoogleFonts.poppins(),
                                                      ),
                                                      backgroundColor:
                                                          theme
                                                              .colorScheme
                                                              .error,
                                                    ),
                                                  );
                                                  return;
                                                }
                                                await Share.shareXFiles(
                                                  [XFile(dbFile.path)],
                                                  subject:
                                                      'Stock Manager Backup',
                                                );
                                              } catch (e) {
                                                if (!parentContext.mounted)
                                                  return;
                                                ScaffoldMessenger.of(
                                                  parentContext,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Export error: $e - خطأ في التصدير: $e',
                                                      style:
                                                          GoogleFonts.poppins(),
                                                    ),
                                                    backgroundColor:
                                                        theme.colorScheme.error,
                                                  ),
                                                );
                                              }
                                            },
                                            child: Text(
                                              'Envoyer par email ou app',
                                              style: GoogleFonts.poppins(),
                                            ),
                                          ),
                                        ],
                                      ),
                                );
                              },
                              label: Text(
                                'Exporter',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF141E46),
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(
                                Icons.restore_outlined,
                                color: Color(0xFF141E46),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD9F4E9),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () async {
                                try {
                                  final result = await FilePicker.platform
                                      .pickFiles(type: FileType.any);
                                  if (result == null ||
                                      result.files.single.path == null)
                                    return;
                                  final pickedFile = File(
                                    result.files.single.path!,
                                  );
                                  final dbPath = await getDatabasesPath();
                                  final dbFile = File(
                                    p.join(dbPath, 'stock_manager.db'),
                                  );
                                  await dbFile.writeAsBytes(
                                    await pickedFile.readAsBytes(),
                                    flush: true,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Base de données restaurée avec succès. - تم استعادة قاعدة البيانات بنجاح.',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                    ),
                                  );
                                  // Reload data after restore
                                  _loadData();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Erreur lors de la restauration : $e - خطأ أثناء الاستعادة: $e',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      backgroundColor: theme.colorScheme.error,
                                    ),
                                  );
                                }
                              },
                              label: Text(
                                'Importer',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF141E46),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Chiffre d\'affaire',
                        _turnover,
                        const Color(0xFF141E46),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Encaissement',
                        _collections,
                        const Color(0xFF141E46),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Benefit Card with navigation to report
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BenefitReportScreen(),
                      ),
                    ).then((_) => _loadData());
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            color: Colors.green[700],
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bénéfice Total - الربح الإجمالي',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  Formatters.formatCurrency(_benefit),
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: _showClotureDialog,
          icon: const Icon(Icons.lock_clock),
          label: const Text('Clôture de la caisse'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: const Color(0xFF141E46),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, double value, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              Formatters.formatCurrency(value),
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

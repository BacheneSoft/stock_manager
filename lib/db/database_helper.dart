import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../data/models/article.dart';
import '../../data/models/category.dart';
import '../../data/models/client.dart';
import '../../data/models/vente.dart';
import '../../data/models/vente_article.dart';
import '../../data/models/fournisseur.dart';
import '../../data/models/purchase.dart';
import '../../data/models/cloture.dart';
import '../../data/models/payment.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'stock_manager.db');
    return await openDatabase(
      path,
      version: 8, // Bump version for benefit tracking
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE articles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        provider TEXT NOT NULL,
        buyPrice REAL NOT NULL,
        sellPrice REAL NOT NULL,
        quantity INTEGER NOT NULL,
        categoryId INTEGER NOT NULL,
        purchaseDate TEXT,
        FOREIGN KEY (categoryId) REFERENCES categories(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        address TEXT,
        credit REAL NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE ventes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        clientId INTEGER NOT NULL,
        date TEXT NOT NULL,
        total REAL NOT NULL,
        isPaid INTEGER NOT NULL DEFAULT 1,
        description TEXT,
        credit REAL NOT NULL DEFAULT 0,
        FOREIGN KEY (clientId) REFERENCES clients(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE vente_articles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        venteId INTEGER NOT NULL,
        articleId INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        costPrice REAL NOT NULL DEFAULT 0,
        FOREIGN KEY (venteId) REFERENCES ventes(id),
        FOREIGN KEY (articleId) REFERENCES articles(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE fournisseurs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        address TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE purchases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        articleId INTEGER NOT NULL,
        articleName TEXT NOT NULL,
        supplier TEXT NOT NULL,
        buyPrice REAL NOT NULL,
        sellPrice REAL NOT NULL,
        quantity INTEGER NOT NULL,
        purchaseDate TEXT NOT NULL,
        FOREIGN KEY (articleId) REFERENCES articles(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        clientId INTEGER,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        note TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE cloture (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        montant REAL NOT NULL,
        calculated_ca REAL NOT NULL,
        calculated_encaissement REAL NOT NULL,
        calculated_benefit REAL NOT NULL DEFAULT 0
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add phone and address to clients
      await db.execute(
        "ALTER TABLE clients ADD COLUMN phone TEXT NOT NULL DEFAULT ''",
      );
      await db.execute("ALTER TABLE clients ADD COLUMN address TEXT");
      // Add isPaid, description, credit to ventes
      await db.execute(
        "ALTER TABLE ventes ADD COLUMN isPaid INTEGER NOT NULL DEFAULT 1",
      );
      await db.execute("ALTER TABLE ventes ADD COLUMN description TEXT");
      await db.execute(
        "ALTER TABLE ventes ADD COLUMN credit REAL NOT NULL DEFAULT 0",
      );
    }
    if (oldVersion < 3) {
      // Add credit column to clients if not exists
      await db.execute(
        "ALTER TABLE clients ADD COLUMN credit REAL NOT NULL DEFAULT 0",
      );
    }
    if (oldVersion < 4) {
      // Ensure credit column exists in clients table
      try {
        await db.execute(
          "ALTER TABLE clients ADD COLUMN credit REAL NOT NULL DEFAULT 0",
        );
      } catch (e) {
        // Column might already exist, ignore error
      }
    }
    if (oldVersion < 5) {
      // Add purchase date column to articles table
      try {
        await db.execute("ALTER TABLE articles ADD COLUMN purchaseDate TEXT");
      } catch (e) {
        // Column might already exist, ignore error
      }
    }
    if (oldVersion < 6) {
      // Create purchases table
      await db.execute('''
        CREATE TABLE purchases (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          articleId INTEGER NOT NULL,
          articleName TEXT NOT NULL,
          supplier TEXT NOT NULL,
          buyPrice REAL NOT NULL,
          sellPrice REAL NOT NULL,
          quantity INTEGER NOT NULL,
          purchaseDate TEXT NOT NULL,
          FOREIGN KEY (articleId) REFERENCES articles(id)
        )
      ''');
    }
    // Removed extra brace
    if (oldVersion < 7) {
      await db.execute('''
        CREATE TABLE payments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          clientId INTEGER,
          amount REAL NOT NULL,
          date TEXT NOT NULL,
          note TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE cloture (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          montant REAL NOT NULL,
          calculated_ca REAL NOT NULL,
          calculated_encaissement REAL NOT NULL
        )
      ''');
    }
    if (oldVersion < 8) {
      // Add costPrice column to vente_articles for benefit tracking
      try {
        await db.execute(
          "ALTER TABLE vente_articles ADD COLUMN costPrice REAL NOT NULL DEFAULT 0",
        );
      } catch (e) {
        // Column might already exist, ignore error
      }
      // Add calculated_benefit column to cloture
      try {
        await db.execute(
          "ALTER TABLE cloture ADD COLUMN calculated_benefit REAL NOT NULL DEFAULT 0",
        );
      } catch (e) {
        // Column might already exist, ignore error
      }
    }
  }

  // Category CRUD
  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<Category>> getCategories() async {
    final db = await database;
    final maps = await db.query('categories');
    return maps.map((e) => Category.fromMap(e)).toList();
  }

  // Article CRUD
  Future<int> insertArticle(Article article) async {
    final db = await database;
    return await db.insert('articles', article.toMap());
  }

  Future<List<Article>> getArticles() async {
    final db = await database;
    final maps = await db.query('articles');
    return maps.map((e) => Article.fromMap(e)).toList();
  }

  Future<int> updateArticle(Article article) async {
    final db = await database;
    return await db.update(
      'articles',
      article.toMap(),
      where: 'id = ?',
      whereArgs: [article.id],
    );
  }

  Future<int> deleteArticle(int id) async {
    final db = await database;
    return await db.delete('articles', where: 'id = ?', whereArgs: [id]);
  }

  // Client CRUD
  Future<int> insertClient(Client client) async {
    final db = await database;
    return await db.insert('clients', client.toMap());
  }

  Future<List<Client>> getClients() async {
    final db = await database;
    final maps = await db.query('clients');
    List<Client> clients = maps.map((e) => Client.fromMap(e)).toList();
    // Attach calculated credit to each client
    for (int i = 0; i < clients.length; i++) {
      final calculatedCredit = await getClientCredit(clients[i].id!);
      clients[i] = Client(
        id: clients[i].id,
        name: clients[i].name,
        phone: clients[i].phone,
        address: clients[i].address,
        credit: calculatedCredit,
      );
    }
    return clients;
  }

  Future<int> updateClient(Client client) async {
    final db = await database;
    return await db.update(
      'clients',
      client.toMap(),
      where: 'id = ?',
      whereArgs: [client.id],
    );
  }

  Future<int> deleteClient(int id) async {
    final db = await database;
    return await db.delete('clients', where: 'id = ?', whereArgs: [id]);
  }

  // Vente CRUD
  Future<int> insertVente(Vente vente) async {
    final db = await database;
    final id = await db.insert('ventes', vente.toMap());
    
    // Calculate paid amount
    final paidAmount = vente.total - vente.credit;
    if (paidAmount > 0) {
      await insertPayment(Payment(
        clientId: vente.clientId,
        amount: paidAmount,
        date: vente.date,
        note: 'Vente #$id',
      ));
    }
    return id;
  }

  Future<List<Vente>> getVentesByClient(int clientId) async {
    final db = await database;
    final maps = await db.query(
      'ventes',
      where: 'clientId = ?',
      whereArgs: [clientId],
    );
    return maps.map((e) => Vente.fromMap(e)).toList();
  }

  Future<int> updateVente(Vente vente) async {
    final db = await database;
    return await db.update(
      'ventes',
      vente.toMap(),
      where: 'id = ?',
      whereArgs: [vente.id],
    );
  }

  Future<int> deleteVente(int id) async {
    final db = await database;
    // Also delete vente_articles for this vente
    await db.delete('vente_articles', where: 'venteId = ?', whereArgs: [id]);
    return await db.delete('ventes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteVenteArticles(int venteId) async {
    final db = await database;
    await db.delete(
      'vente_articles',
      where: 'venteId = ?',
      whereArgs: [venteId],
    );
  }

  // VenteArticle CRUD
  Future<int> insertVenteArticle(VenteArticle venteArticle) async {
    final db = await database;
    return await db.insert('vente_articles', venteArticle.toMap());
  }

  Future<List<VenteArticle>> getVenteArticles(int venteId) async {
    final db = await database;
    final maps = await db.query(
      'vente_articles',
      where: 'venteId = ?',
      whereArgs: [venteId],
    );
    return maps.map((e) => VenteArticle.fromMap(e)).toList();
  }

  // Fournisseur CRUD
  Future<int> insertFournisseur(Fournisseur fournisseur) async {
    final db = await database;
    return await db.insert('fournisseurs', fournisseur.toMap());
  }

  Future<List<Fournisseur>> getFournisseurs() async {
    final db = await database;
    final maps = await db.query('fournisseurs');
    return maps.map((e) => Fournisseur.fromMap(e)).toList();
  }

  Future<int> updateFournisseur(Fournisseur fournisseur) async {
    final db = await database;
    return await db.update(
      'fournisseurs',
      fournisseur.toMap(),
      where: 'id = ?',
      whereArgs: [fournisseur.id],
    );
  }

  Future<int> deleteFournisseur(int id) async {
    final db = await database;
    return await db.delete('fournisseurs', where: 'id = ?', whereArgs: [id]);
  }

  // Purchase CRUD
  Future<int> insertPurchase(Purchase purchase) async {
    final db = await database;
    return await db.insert('purchases', purchase.toMap());
  }

  Future<List<Purchase>> getPurchases() async {
    final db = await database;
    final maps = await db.query('purchases', orderBy: 'purchaseDate DESC');
    return maps.map((e) => Purchase.fromMap(e)).toList();
  }

  Future<List<Purchase>> getPurchasesByArticle(int articleId) async {
    final db = await database;
    final maps = await db.query(
      'purchases',
      where: 'articleId = ?',
      whereArgs: [articleId],
      orderBy: 'purchaseDate DESC',
    );
    return maps.map((e) => Purchase.fromMap(e)).toList();
  }

  Future<List<Purchase>> getPurchasesBySupplier(String supplier) async {
    final db = await database;
    final maps = await db.query(
      'purchases',
      where: 'supplier = ?',
      whereArgs: [supplier],
      orderBy: 'purchaseDate DESC',
    );
    return maps.map((e) => Purchase.fromMap(e)).toList();
  }

  // Distribute a payment across all unpaid ventes for a client
  // Distribute a payment across all unpaid ventes for a client
  Future<void> applyPaymentToClientVentes(int clientId, double payment) async {
    final db = await database;
    
    // Log the payment
    await insertPayment(Payment(
      clientId: clientId,
      amount: payment,
      date: DateTime.now().toIso8601String(),
      note: 'Paiement dette',
    ));

    // Get all unpaid ventes for the client, ordered by date
    final ventes = await db.query(
      'ventes',
      where: 'clientId = ? AND credit > 0',
      whereArgs: [clientId],
      orderBy: 'date ASC',
    );
    double remaining = payment;
    for (final v in ventes) {
      if (remaining <= 0) break;
      final currentCredit = (v['credit'] as num).toDouble();
      final id = v['id'] as int;
      if (currentCredit <= remaining) {
        // Pay off this vente
        await db.update(
          'ventes',
          {'credit': 0.0, 'isPaid': 1},
          where: 'id = ?',
          whereArgs: [id],
        );
        remaining -= currentCredit;
      } else {
        // Partially pay this vente
        await db.update(
          'ventes',
          {'credit': currentCredit - remaining},
          where: 'id = ?',
          whereArgs: [id],
        );
        remaining = 0;
      }
    }

    // If there are no unpaid ventes or payment is more than debt, store as negative credit (advance)
    if (remaining > 0) {
      await updateClientCreditBalance(clientId, -remaining);
    }
  }

  // Utility: Get total credit for a client
  Future<double> getClientCredit(int clientId) async {
    final db = await database;

    // Get debt from unpaid ventes (positive credit)
    final ventesResult = await db.rawQuery(
      'SELECT SUM(credit) as totalCredit FROM ventes WHERE clientId = ? AND isPaid = 0',
      [clientId],
    );
    final debtFromVentes =
        (ventesResult.first['totalCredit'] as num?)?.toDouble() ?? 0.0;

    // Get advance from clients table (negative credit)
    final clientResult = await db.query(
      'clients',
      columns: ['credit'],
      where: 'id = ?',
      whereArgs: [clientId],
    );
    final advanceFromClient =
        clientResult.isNotEmpty
            ? (clientResult.first['credit'] as num?)?.toDouble() ?? 0.0
            : 0.0;

    // Total credit = debt from ventes + advance from client
    // Positive result = client owes money (credit restant)
    // Negative result = client has positive balance (solde positif)
    // Example: 100 debt + (-300) advance = -200 (positive balance)
    return debtFromVentes + advanceFromClient;
  }

  // Professional method to update client credit balance
  Future<void> updateClientCreditBalance(
    int clientId,
    double creditChange,
  ) async {
    final db = await database;

    // Get current client credit from clients table
    final clientResult = await db.query(
      'clients',
      columns: ['credit'],
      where: 'id = ?',
      whereArgs: [clientId],
    );

    if (clientResult.isNotEmpty) {
      final currentCredit =
          (clientResult.first['credit'] as num?)?.toDouble() ?? 0.0;
      final newCredit = currentCredit + creditChange;

      // Update client's credit balance
      await db.update(
        'clients',
        {'credit': newCredit},
        where: 'id = ?',
        whereArgs: [clientId],
      );
    }
  }

  // Professional method to handle overpayment scenarios
  Future<void> handleOverpayment(int clientId, double overpaymentAmount) async {
    if (overpaymentAmount > 0) {
      // Client paid more than total - store as negative credit (positive balance)
      // Since advance is stored as negative credit, we subtract the amount to make it more negative
      await updateClientCreditBalance(clientId, -overpaymentAmount);
    }
  }

  // Professional method to handle credit usage in sales
  Future<void> useClientCredit(int clientId, double creditAmount) async {
    if (creditAmount > 0) {
      // Client is using their positive balance - reduce their credit
      // Since advance is stored as negative credit, we add the amount to make it less negative
      await updateClientCreditBalance(clientId, creditAmount);
    }
  }

  // Payment CRUD
  Future<int> insertPayment(Payment payment) async {
    final db = await database;
    return await db.insert('payments', payment.toMap());
  }

  Future<List<Payment>> getPayments() async {
    final db = await database;
    final maps = await db.query('payments', orderBy: 'date DESC');
    return maps.map((e) => Payment.fromMap(e)).toList();
  }

  // Cloture CRUD
  Future<int> insertCloture(Cloture cloture) async {
    final db = await database;
    return await db.insert('cloture', cloture.toMap());
  }

  Future<List<Cloture>> getClotures() async {
    final db = await database;
    final maps = await db.query('cloture', orderBy: 'date DESC');
    return maps.map((e) => Cloture.fromMap(e)).toList();
  }

  Future<String?> getLastClotureDate() async {
    final db = await database;
    final result = await db.query(
      'cloture',
      orderBy: 'date DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first['date'] as String;
    }
    return null;
  }

  // Statistics for Main Screen
  Future<double> getTurnoverSince(String? date) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (date != null) {
      whereClause = 'WHERE date > ?';
      whereArgs = [date];
    }

    final result = await db.rawQuery(
      'SELECT SUM(total) as total FROM ventes $whereClause',
      whereArgs,
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getCollectionsSince(String? date) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (date != null) {
      whereClause = 'WHERE date > ?';
      whereArgs = [date];
    }

    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM payments $whereClause',
      whereArgs,
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Benefit/Profit Calculation
  // Calculate total cumulative benefit (all-time, no reset after cloture)
  Future<double> getTotalBenefit() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM((price - costPrice) * quantity) as totalBenefit 
      FROM vente_articles 
      WHERE costPrice > 0
    ''');
    return (result.first['totalBenefit'] as num?)?.toDouble() ?? 0.0;
  }

  // Reset benefit by setting costPrice to 0 for all vente_articles
  // This is called during clôture to reset the benefit counter
  Future<void> resetBenefit() async {
    final db = await database;
    await db.update(
      'vente_articles',
      {'costPrice': 0.0},
      where: 'costPrice > 0',
    );
  }

  // Get benefit breakdown by article
  Future<List<Map<String, dynamic>>> getBenefitByArticle() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        a.id,
        a.name,
        SUM(va.quantity) as totalQtySold,
        AVG(va.costPrice) as avgCostPrice,
        AVG(va.price) as avgSellPrice,
        SUM((va.price - va.costPrice) * va.quantity) as totalBenefit
      FROM vente_articles va
      INNER JOIN articles a ON va.articleId = a.id
      WHERE va.costPrice > 0
      GROUP BY va.articleId
      ORDER BY totalBenefit DESC
    ''');
    return result;
  }

  // Utility: Close DB
  Future close() async {
    final db = await database;
    db.close();
  }
}


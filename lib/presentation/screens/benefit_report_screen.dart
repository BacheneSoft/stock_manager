import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../db/database_helper.dart';
import '../../utils/formatters.dart';

class BenefitReportScreen extends StatefulWidget {
  const BenefitReportScreen({Key? key}) : super(key: key);

  @override
  State<BenefitReportScreen> createState() => _BenefitReportScreenState();
}

class _BenefitReportScreenState extends State<BenefitReportScreen> {
  late Future<List<Map<String, dynamic>>> _benefitByArticleFuture;
  late Future<double> _totalBenefitFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final db = DatabaseHelper();
    _benefitByArticleFuture = db.getBenefitByArticle();
    _totalBenefitFuture = db.getTotalBenefit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF141E46),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Rapport des Bénéfices',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _loadData());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Total Benefit Card
                FutureBuilder<double>(
                  future: _totalBenefitFuture,
                  builder: (context, snapshot) {
                    final totalBenefit = snapshot.data ?? 0.0;
                    return Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              Colors.green[700]!,
                              Colors.green[500]!,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: Colors.white,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Bénéfice Total Cumulé',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              'الربح الإجمالي التراكمي',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${Formatters.formatCurrency(totalBenefit)} DA',
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Section Title
                Text(
                  'Bénéfice par Article - الربح لكل منتج',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF141E46),
                  ),
                ),
                const SizedBox(height: 12),
                // Benefit by Article List
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _benefitByArticleFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            'Erreur: ${snapshot.error}',
                            style: GoogleFonts.poppins(color: Colors.red),
                          ),
                        ),
                      );
                    }
                    final articles = snapshot.data ?? [];
                    if (articles.isEmpty) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucune vente avec suivi de bénéfice',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Les nouvelles ventes apparaîtront ici avec le bénéfice calculé',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: articles.length,
                      itemBuilder: (context, index) {
                        final article = articles[index];
                        final name = article['name'] as String? ?? 'Article';
                        final totalQtySold = (article['totalQtySold'] as num?)?.toInt() ?? 0;
                        final avgCostPrice = (article['avgCostPrice'] as num?)?.toDouble() ?? 0;
                        final avgSellPrice = (article['avgSellPrice'] as num?)?.toDouble() ?? 0;
                        final totalBenefit = (article['totalBenefit'] as num?)?.toDouble() ?? 0;
                        final margin = avgSellPrice > 0 
                            ? ((avgSellPrice - avgCostPrice) / avgSellPrice * 100) 
                            : 0;
                        
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.inventory_2_outlined,
                                      color: const Color(0xFF141E46),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF141E46),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green[50],
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.green[200]!,
                                        ),
                                      ),
                                      child: Text(
                                        '+${Formatters.formatCurrency(totalBenefit)} DA',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(height: 1),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildInfoColumn(
                                      'Qté Vendue',
                                      totalQtySold.toString(),
                                      Icons.shopping_cart_outlined,
                                    ),
                                    _buildInfoColumn(
                                      'Prix Achat Moy.',
                                      '${Formatters.formatCurrency(avgCostPrice)} DA',
                                      Icons.arrow_downward,
                                      color: Colors.red[400],
                                    ),
                                    _buildInfoColumn(
                                      'Prix Vente Moy.',
                                      '${Formatters.formatCurrency(avgSellPrice)} DA',
                                      Icons.arrow_upward,
                                      color: Colors.green[400],
                                    ),
                                    _buildInfoColumn(
                                      'Marge',
                                      '${margin.toStringAsFixed(1)}%',
                                      Icons.percent,
                                      color: Colors.blue[400],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? Colors.grey[600], size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF141E46),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}


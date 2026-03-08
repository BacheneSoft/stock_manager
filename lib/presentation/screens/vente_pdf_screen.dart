///lib/screens/vente_pdf_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../../domain/entities/vente.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/vente_article.dart';
import '../../domain/entities/article.dart';
import '../../presentation/providers/article_provider.dart';
import '../../presentation/providers/vente_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/formatters.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'package:external_path/external_path.dart';
import '../../utils/receipt_printer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class VentePdfScreen extends StatefulWidget {
  final Vente vente;
  final Client client;
  const VentePdfScreen({Key? key, required this.vente, required this.client})
    : super(key: key);

  @override
  State<VentePdfScreen> createState() => _VentePdfScreenState();
}

class _VentePdfScreenState extends State<VentePdfScreen> {
  String? pdfPath;
  bool loading = true;
  List<VenteArticle>? venteArticles;
  List<Article>? allArticles;

  final BlueThermalPrinter _bt = BlueThermalPrinter.instance;
  List<BluetoothDevice> _pairedDevices = [];

  @override
  void initState() {
    super.initState();
    _generatePdf();
    _loadPairedPrinters();
  }

  Future<void> _generatePdf() async {
    venteArticles = await Provider.of<VenteProvider>(
      context,
      listen: false,
    ).getVenteArticles(widget.vente.id!);
    allArticles = Provider.of<ArticleProvider>(context, listen: false).articles;
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          58 * PdfPageFormat.mm,
          double.infinity,
          marginAll: 2 * PdfPageFormat.mm,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Bon Pour',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Client: ${widget.client.name}'),
              pw.Text(
                'Date: ${widget.vente.date.length > 10 ? widget.vente.date.substring(0, 10) : widget.vente.date}',
              ),
              pw.Text('Payé: ${widget.vente.isPaid ? "Oui" : "Non"}'),
              if (!widget.vente.isPaid) ...[
                pw.Text(
                  'Montant payé: ${Formatters.formatCurrency(widget.vente.total - widget.vente.credit)} DA',
                  style: pw.TextStyle(color: PdfColors.green),
                ),
                pw.Text(
                  'Crédit restant: ${Formatters.formatCurrency(widget.vente.credit)} DA',
                  style: pw.TextStyle(color: PdfColors.red),
                ),
              ],
              pw.SizedBox(height: 8),
              pw.Text(
                'Articles:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text(
                          'Article',
                          style: pw.TextStyle(fontSize: 8),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text('Qté', style: pw.TextStyle(fontSize: 8)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text(
                          'Prix',
                          style: pw.TextStyle(fontSize: 8),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text(
                          'Total',
                          style: pw.TextStyle(fontSize: 8),
                        ),
                      ),
                    ],
                  ),
                  ...?venteArticles?.map((va) {
                    final article = allArticles?.firstWhere(
                      (a) => a.id == va.articleId,
                    );
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                            article?.name ?? '',
                            style: pw.TextStyle(fontSize: 8),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                            '${va.quantity}',
                            style: pw.TextStyle(fontSize: 8),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                            '${Formatters.formatCurrency(va.price)}',
                            style: pw.TextStyle(fontSize: 8),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                            '${Formatters.formatCurrency(va.price * va.quantity)}',
                            style: pw.TextStyle(fontSize: 8),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Total: ${Formatters.formatCurrency(widget.vente.total)} DA',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/vente_${widget.vente.id}.pdf');
    await file.writeAsBytes(await pdf.save());
    setState(() {
      pdfPath = file.path;
      loading = false;
    });
  }

  Future<void> requestBluetoothPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.locationWhenInUse,
    ].request();
  }

  Future<void> _loadPairedPrinters() async {
    final devices = await _bt.getBondedDevices();
    setState(() => _pairedDevices = devices);
  }

  void _showBluetoothPrintDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Sélectionner une imprimante'),
            content: SizedBox(
              width: 300,
              height: 200,
              child:
                  _pairedDevices.isEmpty
                      ? Center(child: Text('Aucune imprimante appairée.'))
                      : ListView.builder(
                        itemCount: _pairedDevices.length,
                        itemBuilder: (_, i) {
                          final device = _pairedDevices[i];
                          return ListTile(
                            title: Text(device.name ?? 'Imprimante'),
                            subtitle: Text(device.address!),
                            onTap: () async {
                              Navigator.of(context).pop();
                              // prepare items
                              final items =
                                  venteArticles!.map((va) {
                                    final article = allArticles!.firstWhere(
                                      (a) => a.id == va.articleId,
                                    );
                                    return {
                                      'name': article.name,
                                      'qty': va.quantity,
                                      'price': va.price,
                                      'total': va.price * va.quantity,
                                    };
                                  }).toList();
                              final ticket = ReceiptPrinter.buildTicket(
                                clientName: widget.client.name,
                                date:
                                    widget.vente.date.length > 10
                                        ? widget.vente.date.substring(0, 10)
                                        : widget.vente.date,
                                isPaid: widget.vente.isPaid,
                                credit: widget.vente.credit,
                                items: items,
                                total: widget.vente.total,
                              );
                              try {
                                await ReceiptPrinter.printTextReceipt(
                                  ticket,
                                  device,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Impression envoyée.'),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erreur impression: $e'),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
            ),
          ),
    );
  }

  Future<void> _generateAndSaveCsv() async {
    try {
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }
        // Also check for manageExternalStorage for Android 11+ if needed
        // but often basic storage or just writing to public dir works depending on config.
        // We'll stick to basic storage request for now.
      }

      // 1. Generate CSV Content
      final buffer = StringBuffer();
      // Add Header
      buffer.writeln('Article, Quantite, Prix Unitaire, Total');

      // Add Rows
      if (venteArticles != null && allArticles != null) {
        for (var va in venteArticles!) {
          final article = allArticles!.firstWhere(
            (a) => a.id == va.articleId,
            orElse:
                () => Article(
                  id: -1,
                  name: 'Inconnu',
                  provider: 'Inconnu',
                  buyPrice: 0,
                  sellPrice: 0,
                  quantity: 0,
                  categoryId: 0,
                ),
          );
          // Escape fields if necessary (simple version)
          final name = article.name.replaceAll(',', ' ');
          buffer.writeln(
            '$name,${va.quantity},${va.price},${va.price * va.quantity}',
          );
        }
      }

      // Add Footer/Summary
      buffer.writeln('----------------');
      buffer.writeln('Total : ${widget.vente.total}');
      buffer.writeln('Paye : ${widget.vente.isPaid ? "Oui" : "Non"}');
      if (!widget.vente.isPaid) {
        buffer.writeln(
          'Montant paye : ${widget.vente.total - widget.vente.credit}',
        );
        buffer.writeln('Credit restant : ${widget.vente.credit}');
      }

      final csvContent = buffer.toString();

      // 2. Save File
      Directory? downloadsDir;
      String? downloadsPath;
      if (Platform.isAndroid) {
        downloadsPath = await ExternalPath.getExternalStoragePublicDirectory(
          'Download',
        );
        downloadsDir = Directory(downloadsPath);
      } else {
        try {
          downloadsDir = await getDownloadsDirectory();
        } catch (e) {
          downloadsDir = null;
        }
      }

      if (downloadsDir == null) {
        throw Exception('Impossible de trouver le dossier Téléchargements');
      }

      final fileName = 'vente_${widget.vente.id}.csv';
      final path = '${downloadsDir.path}/$fileName';
      final file = File(path);
      await file.writeAsString(csvContent);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'CSV enregistré dans Téléchargements :\n$fileName',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors de l\'export CSV : $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
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
        title: Text(
          'Bon Pour',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions:
            pdfPath != null && !loading
                ? [
                  IconButton(
                    icon: const Icon(
                      Icons.download_rounded,
                      color: Colors.white,
                    ),
                    tooltip: 'Enregistrer dans Téléchargements',
                    onPressed: () async {
                      try {
                        Directory? downloadsDir;
                        String? downloadsPath;
                        if (Platform.isAndroid) {
                          downloadsPath =
                              await ExternalPath.getExternalStoragePublicDirectory(
                                'Download',
                              );
                          downloadsDir = Directory(downloadsPath);
                        } else {
                          try {
                            downloadsDir = await getDownloadsDirectory();
                          } catch (e) {
                            downloadsDir = null;
                          }
                        }
                        if (downloadsDir == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Impossible de trouver le dossier Téléchargements. PDF enregistré dans le dossier temporaire.',
                                style: GoogleFonts.poppins(),
                              ),
                              backgroundColor: theme.colorScheme.error,
                            ),
                          );
                          return;
                        }
                        final fileName = 'vente_${widget.vente.id}.pdf';
                        final newPath = '${downloadsDir.path}/$fileName';
                        final file = File(pdfPath!);
                        await file.copy(newPath);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'PDF enregistré dans Téléchargements :\n$fileName',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: theme.colorScheme.primary,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Erreur lors de l\'enregistrement : $e',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: theme.colorScheme.error,
                          ),
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_rounded, color: Colors.white),
                    tooltip: 'Partager',
                    onPressed: () async {
                      if (pdfPath != null) {
                        await Share.shareXFiles([
                          XFile(pdfPath!, name: 'Bon_de_vente.pdf'),
                        ], text: 'Bon de Vente PDF');
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.print_rounded, color: Colors.white),
                    tooltip: 'Imprimer le bon',
                    onPressed: _showBluetoothPrintDialog,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.table_chart_rounded,
                      color: Colors.white,
                    ),
                    tooltip: 'Exporter en CSV',
                    onPressed: _generateAndSaveCsv,
                  ),
                ]
                : null,
      ),
      body: Center(
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
                  loading
                      ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 24),
                          Text(
                            'Génération du PDF...',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      )
                      : pdfPath == null
                      ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Erreur lors de la génération du PDF.',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                      : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          height: 500,
                          child: PDFView(filePath: pdfPath),
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }
}

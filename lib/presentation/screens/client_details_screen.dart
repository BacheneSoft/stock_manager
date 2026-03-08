import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/vente.dart';
import '../../presentation/providers/vente_provider.dart';
import 'add_vente_screen.dart';
import 'vente_pdf_screen.dart';
import 'add_client_screen.dart';
import '../../presentation/providers/client_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/formatters.dart';

class ClientDetailsScreen extends StatefulWidget {
  final Client client;
  const ClientDetailsScreen({Key? key, required this.client}) : super(key: key);

  @override
  State<ClientDetailsScreen> createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends State<ClientDetailsScreen> {
  DateTime? _selectedDate;
  String? _paidFilter; // 'all', 'paid', 'unpaid'

  @override
  void initState() {
    super.initState();
    Provider.of<VenteProvider>(
      context,
      listen: false,
    ).loadVentes(widget.client.id!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<double>(
      future: Provider.of<ClientProvider>(context, listen: false).getClientCredit(widget.client.id!),
      builder: (context, creditSnapshot) {
        final currentCredit = creditSnapshot.data ?? widget.client.credit;
        final client = Provider.of<ClientProvider>(context).clients.firstWhere(
          (c) => c.id == widget.client.id,
          orElse:
              () => Client(
                id: widget.client.id,
                name: widget.client.name,
                phone: widget.client.phone,
                address: widget.client.address,
                credit: currentCredit,
              ),
        );

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              client.name,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Modifier',
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => AddClientScreen(client: widget.client),
                    ),
                  );
                  if (result == true) {
                    setState(() {});
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: 'Supprimer',
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Supprimer le client'),
                          content: const Text(
                            'Êtes-vous sûr de vouloir supprimer ce client ?',
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
                    await Provider.of<ClientProvider>(
                      context,
                      listen: false,
                    ).deleteClient(widget.client.id!);
                    if (mounted) Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
          body: Container(
            color: const Color(0xFFF5F6FA),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: theme.colorScheme.primary
                                  .withOpacity(0.1),
                              child: Text(
                                client.name.isNotEmpty
                                    ? client.name[0].toUpperCase()
                                    : '?',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                  fontSize: 28,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    client.name,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.phone,
                                        size: 18,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        client.phone,
                                        style: GoogleFonts.poppins(
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (client.address != null &&
                                      client.address!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 18,
                                            color: theme.colorScheme.primary,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              client.address!,
                                              style: GoogleFonts.poppins(
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color:
                                            client.credit > 0
                                                ? Colors.red.withOpacity(0.1)
                                                : Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color:
                                              client.credit > 0
                                                  ? Colors.red.withOpacity(0.3)
                                                  : Colors.green.withOpacity(
                                                    0.3,
                                                  ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            client.credit > 0
                                                ? Icons.account_balance_wallet
                                                : Icons.account_balance,
                                            size: 20,
                                            color:
                                                client.credit > 0
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
                                                  client.credit > 0
                                                      ? 'Crédit restant - رصيد متبقي'
                                                      : 'Solde positif - رصيد إيجابي',
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                    color:
                                                        client.credit > 0
                                                            ? Colors.red
                                                            : Colors.green,
                                                  ),
                                                ),
                                                Text(
                                                  '${Formatters.formatCurrency(client.credit.abs())} DA',
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color:
                                                        client.credit > 0
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
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.payments_outlined),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            theme.colorScheme.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      onPressed: () async {
                                        final controller =
                                            TextEditingController();
                                        final result = await showDialog<double>(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              title: Text(
                                                'Recevoir un paiement',
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              content: TextField(
                                                controller: controller,
                                                keyboardType:
                                                    TextInputType.numberWithOptions(
                                                      decimal: true,
                                                    ),
                                                decoration: InputDecoration(
                                                  labelText: 'Montant reçu',
                                                  prefixIcon: const Icon(
                                                    Icons.attach_money_outlined,
                                                  ),
                                                ),
                                                style: GoogleFonts.poppins(),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                  child: Text(
                                                    'Annuler',
                                                    style:
                                                        GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    final value =
                                                        double.tryParse(
                                                          controller.text
                                                              .trim(),
                                                        );
                                                    if (value == null ||
                                                        value <= 0) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'Montant invalide',
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
                                                    Navigator.pop(
                                                      context,
                                                      value,
                                                    );
                                                  },
                                                  child: Text(
                                                    'Valider',
                                                    style:
                                                        GoogleFonts.poppins(),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        if (result != null && result > 0) {
                                          await Provider.of<ClientProvider>(context, listen: false).applyPaymentToClientVentes(
                                            client.id!,
                                            result,
                                          );
                                          // Reload client and ventes data
                                          if (mounted) {
                                            // Reload ventes for this client
                                            await Provider.of<VenteProvider>(
                                              context,
                                              listen: false,
                                            ).loadVentes(client.id!);
                                            // Reload client list (and thus credit)
                                            await Provider.of<ClientProvider>(
                                              context,
                                              listen: false,
                                            ).loadClients();
                                            setState(() {});
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Paiement appliqué avec succès.',
                                                  style: GoogleFonts.poppins(),
                                                ),
                                                backgroundColor:
                                                    theme.colorScheme.primary,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      label: Text(
                                        'Recevoir un paiement',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() {
                                  _selectedDate = picked;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Date',
                                prefixIcon: Icon(Icons.date_range),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                isDense: true,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    _selectedDate == null
                                        ? 'Toutes'
                                        : '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
                                  ),
                                  if (_selectedDate != null)
                                    IconButton(
                                      icon: Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        setState(() {
                                          _selectedDate = null;
                                        });
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<String?>(
                          value: _paidFilter,
                          hint: Text('Statut'),
                          items: [
                            DropdownMenuItem(value: null, child: Text('Tous')),
                            DropdownMenuItem(
                              value: 'paid',
                              child: Text('Payé'),
                            ),
                            DropdownMenuItem(
                              value: 'unpaid',
                              child: Text('Non payé'),
                            ),
                          ],
                          onChanged: (val) {
                            setState(() {
                              _paidFilter = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8,
                    ),
                    child: Text(
                      'Ventes',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 400, // Fixed height for the ventes list
                    child: Consumer<VenteProvider>(
                      builder: (context, provider, _) {
                        final filteredVentes =
                            provider.ventes.where((vente) {
                              final matchesDate =
                                  _selectedDate == null ||
                                  vente.date.startsWith(
                                      '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}');
                              final matchesPaid =
                                  _paidFilter == null ||
                                  (_paidFilter == 'paid' && vente.isPaid) ||
                                  (_paidFilter == 'unpaid' && !vente.isPaid);
                              return matchesDate && matchesPaid;
                            }).toList();
                        if (filteredVentes.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long_rounded,
                                  size: 80,
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.7,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Aucune vente.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Ajoutez une vente pour ce client.',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: filteredVentes.length,
                          itemBuilder: (context, index) {
                            final vente = filteredVentes[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              elevation: 4,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                leading: Icon(
                                  vente.isPaid
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color:
                                      vente.isPaid ? Colors.green : Colors.red,
                                  size: 32,
                                ),
                                title: Text(
                                  'Vente du ${vente.date.length > 10 ? vente.date.substring(0, 10) : vente.date}',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total: ${Formatters.formatCurrency(vente.total)} DA',
                                      style: GoogleFonts.poppins(
                                        color: Colors.black87,
                                      ),
                                    ),
                                    if (!vente.isPaid)
                                      Text(
                                        'Crédit: ${Formatters.formatCurrency(vente.credit)} DA',
                                        style: GoogleFonts.poppins(
                                          color: Colors.red,
                                        ),
                                      ),
                                    if (vente.description != null &&
                                        vente.description!.isNotEmpty)
                                      Text(
                                        'Note: ${vente.description!}',
                                        style: GoogleFonts.poppins(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.black54,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.picture_as_pdf),
                                      tooltip: 'Voir bon de vente',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => VentePdfScreen(
                                                  vente: vente,
                                                  client: widget.client,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      tooltip: 'Modifier',
                                      onPressed: () async {
                                        final venteArticles =
                                            await Provider.of<VenteProvider>(
                                              context,
                                              listen: false,
                                            ).getVenteArticles(vente.id!);
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => AddVenteScreen(
                                                  client: widget.client,
                                                  vente: vente,
                                                  venteArticles: venteArticles,
                                                ),
                                          ),
                                        );
                                        // Reload ventes after editing
                                        await Provider.of<VenteProvider>(
                                          context,
                                          listen: false,
                                        ).loadVentes(widget.client.id!);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      tooltip: 'Supprimer',
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder:
                                              (context) => AlertDialog(
                                                title: const Text(
                                                  'Supprimer la vente',
                                                ),
                                                content: const Text(
                                                  'Êtes-vous sûr de vouloir supprimer cette vente ?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          context,
                                                          false,
                                                        ),
                                                    child: const Text(
                                                      'Annuler',
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          context,
                                                          true,
                                                        ),
                                                    child: const Text(
                                                      'Supprimer',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        );
                                        if (confirm == true) {
                                          await Provider.of<VenteProvider>(
                                            context,
                                            listen: false,
                                          ).deleteVente(
                                            vente.id!,
                                            widget.client.id!,
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  // TODO: Show vente details
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddVenteScreen(client: client),
                ),
              );
              // Reload ventes and client credit after adding a vente
              await Provider.of<VenteProvider>(
                context,
                listen: false,
              ).loadVentes(client.id!);
              await Provider.of<ClientProvider>(
                context,
                listen: false,
              ).loadClients();
              // Force refresh the client data to ensure credit is updated
              setState(() {});
            },
            icon: const Icon(Icons.add),
            label: const Text('Ajouter Vente'),
            tooltip: 'Ajouter Vente',
          ),
        );
      },
    );
  }
}


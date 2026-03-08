import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/client.dart';
import '../providers/client_provider.dart';
import 'add_client_screen.dart';
import 'client_details_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../db/database_helper.dart';

class ClientsListScreen extends StatefulWidget {
  const ClientsListScreen({Key? key}) : super(key: key);

  @override
  State<ClientsListScreen> createState() => _ClientsListScreenState();
}

class _ClientsListScreenState extends State<ClientsListScreen> {
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Add filter state
  String _filter = 'all'; // 'all', 'with_credit', 'without_credit'

  // Cache for client credits
  Map<int, double> _clientCredits = {};
  bool _loadingCredits = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  @override
  void initState() {
    super.initState();
    Provider.of<ClientProvider>(context, listen: false).loadClients();
    _fetchClientCredits();
  }

  Future<void> _fetchClientCredits() async {
    setState(() {
      _loadingCredits = true;
    });
    final db = DatabaseHelper();
    final provider = Provider.of<ClientProvider>(context, listen: false);
    Map<int, double> credits = {};
    for (final client in provider.clients) {
      credits[client.id!] = await db.getClientCredit(client.id!);
    }
    setState(() {
      _clientCredits = credits;
      _loadingCredits = false;
    });
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
                    hintText: 'Rechercher un client...',
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
                        'Clients',
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
              onPressed: _startSearch,
            ),
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              tooltip: 'Annuler la recherche',
              onPressed: _stopSearch,
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_alt_rounded),
            tooltip: 'Filtrer',
            onSelected: (value) {
              setState(() {
                _filter = value;
              });
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(value: 'all', child: Text('Tous les clients')),
                  PopupMenuItem(
                    value: 'with_credit',
                    child: Text('Clients avec crédit'),
                  ),
                  PopupMenuItem(
                    value: 'without_credit',
                    child: Text('Clients sans crédit'),
                  ),
                ],
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFF5F6FA),
        child: Consumer<ClientProvider>(
          builder: (context, provider, _) {
            if (_loadingCredits) {
              return const Center(child: CircularProgressIndicator());
            }
            // Filter clients if searching and/or by credit
            List<Client> filteredClients =
                _isSearching && _searchQuery.isNotEmpty
                    ? provider.clients.where((client) {
                      final query = _searchQuery.toLowerCase();
                      return client.name.toLowerCase().contains(query) ||
                          client.phone.toLowerCase().contains(query);
                    }).toList()
                    : provider.clients;

            // Apply credit filter using client.credit
            if (_filter == 'with_credit') {
              filteredClients =
                  filteredClients.where((c) => c.credit > 0).toList();
            } else if (_filter == 'without_credit') {
              filteredClients =
                  filteredClients.where((c) => c.credit == 0).toList();
            }

            if (filteredClients.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_alt_rounded,
                      size: 80,
                      color: theme.colorScheme.primary.withOpacity(0.7),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isSearching && _searchQuery.isNotEmpty
                          ? 'Aucun résultat'
                          : 'Aucun client',
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
                          : 'Ajoutez des clients pour commencer.',
                      style: GoogleFonts.poppins(color: Colors.black54),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              itemCount: filteredClients.length,
              itemBuilder: (context, index) {
                final client = filteredClients[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 10,
                  ),
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
                      child: Text(
                        client.name.isNotEmpty
                            ? client.name[0].toUpperCase()
                            : '?',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    title: Text(
                      client.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      'Téléphone: ${client.phone}${client.address != null && client.address!.isNotEmpty ? '\nAdresse: ${client.address}' : ''}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ClientDetailsScreen(client: client),
                        ),
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Modifier',
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => AddClientScreen(
                                      key: UniqueKey(),
                                      client: client,
                                    ),
                              ),
                            );
                            if (result == true) {
                              Provider.of<ClientProvider>(
                                context,
                                listen: false,
                              ).loadClients();
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
                                        onPressed:
                                            () => Navigator.pop(context, false),
                                        child: const Text('Annuler'),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, true),
                                        child: const Text('Supprimer'),
                                      ),
                                    ],
                                  ),
                            );
                            if (confirm == true) {
                              await Provider.of<ClientProvider>(
                                context,
                                listen: false,
                              ).deleteClient(client.id!);
                            }
                          },
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
            MaterialPageRoute(builder: (context) => const AddClientScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
        tooltip: 'Ajouter Client',
      ),
    );
  }
}


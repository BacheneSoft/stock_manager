import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/client.dart';
import '../providers/client_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class AddClientScreen extends StatefulWidget {
  final Client? client;
  const AddClientScreen({Key? key, this.client}) : super(key: key);

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _phone;
  String? _address;

  @override
  void initState() {
    super.initState();
    _name = widget.client?.name ?? '';
    _phone = widget.client?.phone ?? '';
    _address = widget.client?.address;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.client == null ? 'Ajouter Client' : 'Modifier Client',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        initialValue: _name,
                        decoration: InputDecoration(
                          labelText: 'Nom du client',
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                        ),
                        style: GoogleFonts.poppins(),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Champ requis'
                                    : null,
                        onSaved: (value) => _name = value!,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _phone,
                        decoration: InputDecoration(
                          labelText: 'Téléphone',
                          prefixIcon: const Icon(Icons.phone_rounded),
                        ),
                        style: GoogleFonts.poppins(),
                        keyboardType: TextInputType.phone,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Champ requis'
                                    : null,
                        onSaved: (value) => _phone = value!,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _address,
                        decoration: InputDecoration(
                          labelText: 'Adresse (optionnel)',
                          prefixIcon: const Icon(Icons.location_on_outlined),
                        ),
                        style: GoogleFonts.poppins(),
                        onSaved: (value) => _address = value,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: Icon(
                            widget.client == null
                                ? Icons.person_add_alt_1_rounded
                                : Icons.save_alt_rounded,
                          ),
                          label: Text(
                            widget.client == null ? 'Ajouter' : 'Enregistrer',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: GoogleFonts.poppins(fontSize: 18),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              if (widget.client == null) {
                                final client = Client(
                                  name: _name,
                                  phone: _phone,
                                  address: _address,
                                );
                                await Provider.of<ClientProvider>(
                                  context,
                                  listen: false,
                                ).addClient(client);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Client ajouté avec succès!',
                                      style: GoogleFonts.poppins(),
                                    ),
                                  ),
                                );
                              } else {
                                final updated = Client(
                                  id: widget.client!.id,
                                  name: _name,
                                  phone: _phone,
                                  address: _address,
                                );
                                await Provider.of<ClientProvider>(
                                  context,
                                  listen: false,
                                ).updateClient(updated);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Client modifié avec succès!',
                                      style: GoogleFonts.poppins(),
                                    ),
                                  ),
                                );
                              }
                              Navigator.pop(context, true);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

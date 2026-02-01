import 'package:flutter/material.dart';
import '../models/fournisseur.dart';
import '../db/database_helper.dart';

class FournisseurProvider with ChangeNotifier {
  List<Fournisseur> _fournisseurs = [];

  List<Fournisseur> get fournisseurs => _fournisseurs;

  Future<void> loadFournisseurs() async {
    _fournisseurs = await DatabaseHelper().getFournisseurs();
    notifyListeners();
  }

  Future<void> addFournisseur(Fournisseur fournisseur) async {
    await DatabaseHelper().insertFournisseur(fournisseur);
    await loadFournisseurs();
  }

  Future<void> updateFournisseur(Fournisseur fournisseur) async {
    await DatabaseHelper().updateFournisseur(fournisseur);
    await loadFournisseurs();
  }

  Future<void> deleteFournisseur(int id) async {
    await DatabaseHelper().deleteFournisseur(id);
    await loadFournisseurs();
  }
}

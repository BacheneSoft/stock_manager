import 'package:flutter/material.dart';
import '../../domain/entities/fournisseur.dart';
import '../../domain/repositories/i_fournisseur_repository.dart';

class FournisseurProvider with ChangeNotifier {
  final IFournisseurRepository _repository;
  List<Fournisseur> _fournisseurs = [];

  FournisseurProvider(this._repository);

  List<Fournisseur> get fournisseurs => _fournisseurs;

  Future<void> loadFournisseurs() async {
    _fournisseurs = await _repository.getFournisseurs();
    notifyListeners();
  }

  Future<void> addFournisseur(Fournisseur fournisseur) async {
    await _repository.insertFournisseur(fournisseur);
    await loadFournisseurs();
  }

  Future<void> updateFournisseur(Fournisseur fournisseur) async {
    await _repository.updateFournisseur(fournisseur);
    await loadFournisseurs();
  }

  Future<void> deleteFournisseur(int id) async {
    await _repository.deleteFournisseur(id);
    await loadFournisseurs();
  }
}

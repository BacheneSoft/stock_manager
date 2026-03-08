import '../../domain/entities/fournisseur.dart';
import '../../domain/repositories/i_fournisseur_repository.dart';
import '../../db/database_helper.dart';
import '../models/fournisseur.dart' as model;

class FournisseurRepository implements IFournisseurRepository {
  final DatabaseHelper _dbHelper;

  FournisseurRepository(this._dbHelper);

  @override
  Future<List<Fournisseur>> getFournisseurs() async {
    final models = await _dbHelper.getFournisseurs();
    return models
        .map(
          (m) => Fournisseur(
            id: m.id,
            name: m.name,
            phone: m.phone,
            address: m.address,
          ),
        )
        .toList();
  }

  @override
  Future<int> insertFournisseur(Fournisseur fournisseur) async {
    final m = model.Fournisseur(
      id: fournisseur.id,
      name: fournisseur.name,
      phone: fournisseur.phone,
      address: fournisseur.address,
    );
    return await _dbHelper.insertFournisseur(m);
  }

  @override
  Future<int> updateFournisseur(Fournisseur fournisseur) async {
    final m = model.Fournisseur(
      id: fournisseur.id,
      name: fournisseur.name,
      phone: fournisseur.phone,
      address: fournisseur.address,
    );
    return await _dbHelper.updateFournisseur(m);
  }

  @override
  Future<int> deleteFournisseur(int id) async {
    return await _dbHelper.deleteFournisseur(id);
  }
}

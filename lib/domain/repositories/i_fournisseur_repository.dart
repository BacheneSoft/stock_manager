import '../entities/fournisseur.dart';

/// Interface for managing [Fournisseur] data access.
///
/// Handles procurement-related data operations for suppliers.
abstract class IFournisseurRepository {
  Future<List<Fournisseur>> getFournisseurs();
  Future<int> insertFournisseur(Fournisseur fournisseur);
  Future<int> updateFournisseur(Fournisseur fournisseur);
  Future<int> deleteFournisseur(int id);
}

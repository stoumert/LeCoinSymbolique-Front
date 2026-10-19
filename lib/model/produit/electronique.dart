
import 'package:le_coin_symbolique_front/model/produit/type_produit.dart';

import '../produit.dart';

class ProduitElectronique extends Produit {
  final String? type;
  final String? marque;
  final String? modele;
  final String? taille;

  ProduitElectronique({
    super.etat,
    required super.annee,
    this.type,
    this.modele,
    this.marque,
    this.taille,
  }) : super(type_produit: TypeProduit.ELECTRONIQUE);

  factory ProduitElectronique.fromJson(Map<String, dynamic> json) {
    print(json['taille']);
    return ProduitElectronique(
      etat: json['etat'] ?? '',
      annee: json['annee'] ?? 0,
      type: json['type'] ?? '',
      modele: json['modele'] ?? '',
      marque: json['marque'] ?? '',
      taille: json['taille'] ??'',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type_produit': typeProduitToString(type_produit),
      'etat': etat,
      'annee': annee,
      'type': type,
      'modele': modele,
      'marque': marque,
      'taille': taille,
    };
  }
}
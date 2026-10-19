import 'package:le_coin_symbolique_front/model/produit/type_produit.dart';

import '../produit.dart';

class ProduitMeuble extends Produit {
  final String? type;
  final String? matiere;
  final String? couleur;
  final String? dimensions;

  ProduitMeuble({
    String? etat,
    required int annee,
    this.matiere,
    this.dimensions,
    this.couleur,
    this.type,
  }) : super(type_produit: TypeProduit.MEUBLE,etat: etat, annee: annee);

  factory ProduitMeuble.fromJson(Map<String, dynamic> json) {
    return ProduitMeuble(
      etat: json['etat'],
      annee: json['annee'],
      matiere: json['matiere'],
      dimensions: json['dimensions'],
      couleur: json['couleur'],
      type: json['type'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type_produit': typeProduitToString(type_produit),
      'etat': etat,
      'annee': annee,
      'matiere': matiere,
      'dimensions': dimensions,
      'couleur': couleur,
      'type': type,
    };
  }
}
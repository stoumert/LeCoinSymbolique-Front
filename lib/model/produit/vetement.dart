import 'package:le_coin_symbolique_front/model/produit/type_produit.dart';

import '../produit.dart';

class ProduitVetement extends Produit {
  final String? taille;
  final String? couleur;
  final String? genre;
  final String? type;
  final String? marque;

  ProduitVetement({
    String? etat,
    required int annee,
    this.taille,
    this.couleur,
    this.genre,
    this.type,
    this.marque,
  }) : super(type_produit: TypeProduit.VETEMENT, etat: etat, annee: annee);

  factory ProduitVetement.fromJson(Map<String, dynamic> json) {
    return ProduitVetement(
      etat: json['etat'],
      annee: json['annee'],
      taille: json['taille'],
      couleur: json['couleur'],
      genre: json['genre'],
      type: json['type'],
      marque: json['marque'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type_produit': typeProduitToString(type_produit),
      'etat': etat,
      'annee': annee,
      'taille': taille,
      'couleur': couleur,
      'genre': genre,
      'type': type,
      'marque': marque,
    };
  }
}
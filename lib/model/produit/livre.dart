
import 'package:le_coin_symbolique_front/model/produit/type_produit.dart';

import '../produit.dart';

class ProduitLivre extends Produit {
  final String? auteur;
  final String? editeur;
  final int? anneePublication;
  final String? titreLivre;

  ProduitLivre({
    super.etat,
    required super.annee,
    this.auteur,
    this.editeur,
    this.titreLivre,
    this.anneePublication,
  }) : super(type_produit: TypeProduit.LIVRE);

  factory ProduitLivre.fromJson(Map<String, dynamic> json) {
    return ProduitLivre(
      etat: json['etat'],
      annee: json['annee'],
      auteur: json['auteur'],
      editeur: json['editeur'],
      titreLivre: json['titreLivre'],
      anneePublication: json['anneePublication'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type_produit': typeProduitToString(type_produit),
      'etat': etat,
      'annee': annee,
      'auteur': auteur,
      'editeur': editeur,
      'anneePublication': anneePublication,
      'titreLivre': titreLivre,
    };
  }
}
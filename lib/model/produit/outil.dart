
import 'package:le_coin_symbolique_front/model/produit/type_produit.dart';

import '../produit.dart';

class ProduitOutil extends Produit {
  final String? type;
  final String? puissance;
  final String? marque;
  final String? modele;

  ProduitOutil({
    String? etat,
    required int annee,
    this.type,
    this.puissance,
    this.marque,
    this.modele,
  }) : super(type_produit: TypeProduit.OUTIL, etat: etat, annee: annee);

  factory ProduitOutil.fromJson(Map<String, dynamic> json) {
    return ProduitOutil(
      etat: json['etat'],
      annee: json['annee'],
      type: json['type'],
      puissance: json['puissance'],
      marque: json['marque'],
      modele: json['modele'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type_produit': typeProduitToString(type_produit),
      'etat': etat,
      'annee': annee,
      'type': type,
      'puissance': puissance,
      'marque': marque,
      'modele': modele,
    };
  }
}
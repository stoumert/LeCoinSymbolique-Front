
import 'package:le_coin_symbolique_front/model/produit/type_produit.dart';

import '../produit.dart';

class ProduitJeuVideo extends Produit {
  final String? titreJeu;
  final String? editeur;
  final String? plateforme;

  ProduitJeuVideo({
    String? etat,
    required int annee,
    this.titreJeu,
    this.editeur,
    this.plateforme,
  }) : super(type_produit: TypeProduit.JEUVIDEO, etat: etat, annee: annee);

  factory ProduitJeuVideo.fromJson(Map<String, dynamic> json) {
    return ProduitJeuVideo(
      etat: json['etat'],
      annee: json['annee'],
      plateforme: json['plateforme'],
      editeur: json['editeur'],
      titreJeu: json['titreJeu'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type_produit': typeProduitToString(type_produit),
      'etat': etat,
      'modele': annee,
      'plateforme': plateforme,
      'editeur': editeur,
      'titreJeu': titreJeu,
    };
  }
}
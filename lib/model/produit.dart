
import 'package:le_coin_symbolique_front/model/produit/electronique.dart';
import 'package:le_coin_symbolique_front/model/produit/jeu_video.dart';
import 'package:le_coin_symbolique_front/model/produit/livre.dart';
import 'package:le_coin_symbolique_front/model/produit/meuble.dart';
import 'package:le_coin_symbolique_front/model/produit/outil.dart';
import 'package:le_coin_symbolique_front/model/produit/type_produit.dart';
import 'package:le_coin_symbolique_front/model/produit/vetement.dart';

abstract class Produit {
  final TypeProduit type_produit;
  final String? etat;
  final int annee;

  Produit({required this.type_produit, this.etat, required this.annee});

  factory Produit.fromJson(Map<String, dynamic> json) {
    final type = stringToTypeProduit(json['type_produit']);

    switch (type) {
      case TypeProduit.ELECTRONIQUE:
        return ProduitElectronique.fromJson(json);
      case TypeProduit.MEUBLE:
        return ProduitMeuble.fromJson(json);
      case TypeProduit.OUTIL:
        return ProduitOutil.fromJson(json);
      case TypeProduit.VETEMENT:
        return ProduitVetement.fromJson(json);
      case TypeProduit.LIVRE:
        return ProduitLivre.fromJson(json);
      case TypeProduit.JEUVIDEO:
        return ProduitJeuVideo.fromJson(json);
      default:
        throw Exception('Type de produit inconnu: ${json['type']}');
    }
  }

  Map<String, dynamic> toJson();
}
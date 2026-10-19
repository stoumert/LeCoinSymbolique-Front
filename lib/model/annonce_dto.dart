import 'package:le_coin_symbolique_front/model/annonce_image.dart';
import 'package:le_coin_symbolique_front/model/client_dto.dart';
import 'package:le_coin_symbolique_front/model/produit.dart';

class AnnonceDTO {
  final int? id;
  final String title;
  final String description;
  final double price;
  final String status;
  final DateTime createdAt;
  final ClientDTO? client;
  final Produit produit;
  final String? phoneNumber;
  final List<AnnonceImage>? imageUrls;

  AnnonceDTO({
    this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.status,
    required this.createdAt,
    required this.client,
    required this.produit,
    this.phoneNumber,
    this.imageUrls,
  });

  factory AnnonceDTO.fromJson(Map<String, dynamic> json) {
    return AnnonceDTO(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      client: ClientDTO.fromJson(json['client']),
      produit: Produit.fromJson(json['produit']),
      phoneNumber: json['phoneNumber'],
      imageUrls: (json['images'] as List<dynamic>?)
          ?.map((img) => AnnonceImage.fromJson(img))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'produit': produit.toJson(),
      'phoneNumber': phoneNumber,
      if (imageUrls != null) 'imageUrls': imageUrls,
    };
  }

  AnnonceDTO copyWith({
    int? id,
    String? title,
    String? description,
    double? price,
    String? status,
    DateTime? createdAt,
    ClientDTO? client,
    Produit? produit,
    String? phoneNumber,
    List<AnnonceImage>? imageUrls,
  }) {
    return AnnonceDTO(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      client: client ?? this.client,
      produit: produit ?? this.produit,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }
}
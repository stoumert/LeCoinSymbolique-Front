import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:le_coin_symbolique_front/service/auth_http_client.dart';
import 'package:le_coin_symbolique_front/service/location_service.dart';
import 'package:http_parser/http_parser.dart';

import '../model/annonce_dto.dart';


class AnnonceService {
  final client = AuthHttpClient();
  final String baseUrl = 'http://localhost:8080/api';
  final LocationService locationService = LocationService();


  Future<List<dynamic>> searchAnnonces({
    String? title,
    String? typeProduit,
    double? minPrice,
    double? maxPrice,
    String? adresse,
    double? longitude,
    double? latitude,
    double? radiusKm,
    int page = 0,
    int size = 20,
    String sortedBy = 'createdAt',
    String sortedDir = 'desc',
  }) async {
    try {
      final position = await locationService.getCurrentLocation();
      final Map<String, String> params = {
        'page': page.toString(),
        'size': size.toString(),
        'sortedBy': sortedBy,
        'sortedDir': sortedDir,
      };

      if (title != null && title.isNotEmpty) params['title'] = title;
      if (typeProduit != null && typeProduit.isNotEmpty && typeProduit != 'Toutes catégories') {
        params['typeProduit'] = typeProduit;
      }
      if (minPrice != null) params['minPrice'] = minPrice.toString();
      if (maxPrice != null) params['maxPrice'] = maxPrice.toString();
      if (adresse != null && adresse.isNotEmpty){
        params['adresse'] = adresse;
        params['radiusKm'] = radiusKm.toString();
      }
      if (adresse == null && radiusKm != null) {
        params['longitude'] = position.longitude.toString();
        params['latitude'] = position.latitude.toString();
        params['radiusKm'] = radiusKm.toString();
      }

      final uri = Uri.parse("$baseUrl/annonce/search").replace(queryParameters: params);
      final response = await client.get(uri, headers: {"Content-Type": "application/json"});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['content'];
      } else {
        throw Exception('Erreur de recherche : ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      debugPrint("Erreur searchAnnonces: $e");
      rethrow;
    }
  }
  Future<bool> createAnnonce({
    required AnnonceDTO annonce,
    List<File>? images,
  }) async {
    try {
      final annonceJson = jsonEncode(annonce.toJson());
      final annoncePart = http.MultipartFile.fromString(
        'annonce',
        annonceJson,
        contentType: MediaType('application', 'json'),
      );
      List<http.MultipartFile>? multipartFiles;
      if (images != null && images.isNotEmpty) {
        multipartFiles = await Future.wait(images.map((image) async {
          final fileStream = http.ByteStream(image.openRead());
          final length = await image.length();

          return http.MultipartFile(
            'images',
            fileStream,
            length,
            filename: image.path.split('/').last,
            contentType: MediaType('image', 'jpeg'),
          );
        }));
      }

      final streamedResponse = await client.multipartRequest(
        'POST',
        Uri.parse("$baseUrl/annonce/create"),
        files: [annoncePart, if (multipartFiles != null) ...multipartFiles],

      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Erreur création annonce: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur createAnnonce: $e");
      rethrow;
    }
  }

  Future<List<AnnonceDTO>> getAnnonceByUserId(
      int userId,
      int page, {
        int size = 10,
        String sortBy = 'createdAt',
        String sortDir = 'desc',
      }) async {
    final url = Uri.parse('$baseUrl/annonce/getByUserId/$userId').replace(
      queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
        'sortedBy': sortBy,
        'sortedDir': sortDir,
      },
    );

    final response = await client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['content'] as List)
          .map((json) => AnnonceDTO.fromJson(json))
          .toList();
    } else {
      throw Exception(
        'Failed to load annonces: ${response.statusCode}\n${response.body}',
      );
    }
  }

  Future<bool> deleteAnnonce(int id) async {
    final url = Uri.parse('$baseUrl/annonce/delete/$id');
    final response = await client.delete(
      url,
    );
    if(response.statusCode ==200){
      return true;
    }else{
      return false;
    }
  }

  Future<bool> update({
    required int id,
    String? description,
    String? title,
    double? price,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/annonce/update');
      final response = await client.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "id": id,
            "description": description,
            "title": title,
            "price": price,
          })
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Erreur lors de la mise à jour : $e");
      throw Exception("Échec de la mise à jour de l'annonce : $e");
    }
  }
}

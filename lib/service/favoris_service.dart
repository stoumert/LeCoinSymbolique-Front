import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'auth_http_client.dart';

class FavorisService {
  final client = AuthHttpClient();
  final String baseUrl = 'http://localhost:8080/api';
  final storage = FlutterSecureStorage();

  Future<List<dynamic>> getFavoris() async {
    final response = await client.get(Uri.parse('$baseUrl/favoris'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['content'];

    } else {
      throw Exception('Erreur lors de la récupération des favoris');
    }
  }

  Future<void> addFavori(int annonceId) async {
    final response = await client.post(
      Uri.parse('$baseUrl/favoris/$annonceId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Erreur lors de l\'ajout du favori');
    }
  }

  Future<void> removeFavori(int annonceId) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/favoris/$annonceId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la suppression du favori');
    }
  }

  Future<bool> isFavori(int annonceId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/favoris/$annonceId'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) == true;
    } else {
      return false;
    }
  }
}

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:le_coin_symbolique_front/service/auth_http_client.dart';

class ImageService {
  final AuthHttpClient _authHttpClient;
  final String _baseUrl;

  ImageService({String? baseUrl})
      : _authHttpClient = AuthHttpClient(),
        _baseUrl = baseUrl ?? 'http://localhost:8080/api/images';

  Future<ImageProvider> getImageProvider(String imagePath) async {
    final response = await _authHttpClient.get(
      Uri.parse('$_baseUrl$imagePath'),
    );
    if (response.statusCode == 200) {
      final contentType = response.headers['content-type'];

      if (contentType == null || !contentType.startsWith('image/')) {
        throw Exception('Réponse non-image: $contentType');
      }

      if (response.bodyBytes.isEmpty) {
        throw Exception('Données image vides');
      }

      return MemoryImage(Uint8List.fromList(response.bodyBytes));
    } else {
      throw Exception('HTTP ${response.statusCode}');
    }
  }

}
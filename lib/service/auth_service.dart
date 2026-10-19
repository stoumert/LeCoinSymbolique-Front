// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:le_coin_symbolique_front/service/auth_http_client.dart';
import '../model/client_dto.dart';

class AuthService {
  final storage = FlutterSecureStorage();
  final String baseUrl = "http://localhost:8080/api";
  final client = AuthHttpClient();

  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/connexion"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final token = body["bearer"];
      final refreshToken = body["refreshToken"];

      if (token != null && refreshToken != null) {
        await storage.write(key: "token", value: token);
        await storage.write(key: "refreshToken", value: refreshToken);
        await storage.write(key: "username", value: username);

        final userProfile = await getMyProfile();
        await storage.write(key: "userProfile", value: jsonEncode(userProfile?.toJson()));
        print("Token enregistré : $token");
        return true;
      }
    }

    return false;
  }


  Future<bool> register(String username, String password, String email,
      String fullName, String adresse, String phoneNumber) async {
    final response = await http.post(
      Uri.parse("$baseUrl/inscription"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
        "email": email,
        "fullName": fullName,
        "phoneNumber":phoneNumber,
        "location": adresse
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
  Future<bool> verifyCode(String username, String code) async {
    final response = await http.post(
      Uri.parse("$baseUrl/activation"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "validation_code": code}),
    );

    return response.statusCode == 200;
  }
  Future<bool> logout()async{
    final uri = Uri.parse("$baseUrl/deconnexion");
    final response = await client.post(uri);
    return response.statusCode == 200;
  }

  Future<bool> mot_de_passe_oublie(String email) async{
    final response = await http.post(
      Uri.parse("$baseUrl/password-oublier"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email.toLowerCase()})
    );
    return response.statusCode ==200;
  }
  Future<bool> newPassword(String code, String newPassword, String email) async{
    final response = await http.post(
      Uri.parse("$baseUrl/password-modification"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "new_password": newPassword,
        "validation_code": code
      })
    );
    return response.statusCode == 200;
  }

  Future<ClientDTO?> getMyProfile() async {
    final token = await storage.read(key: "token");
    if (token == null) return null;

    final response = await http.get(
      Uri.parse("$baseUrl/me"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return ClientDTO.fromJson(jsonData);
    }
    return null;
  }
  Future<String?> getToken() => storage.read(key: "token");
}

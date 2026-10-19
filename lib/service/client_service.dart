
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:le_coin_symbolique_front/service/auth_http_client.dart';

import '../model/client_dto.dart';

class ClientService{

  FlutterSecureStorage storage = FlutterSecureStorage();
  final client = AuthHttpClient();
  final String baseUrl = 'http://localhost:8080/api';

  Future<ClientDTO?> getCurrentUser() async {
    final userJson = await storage.read(key: "userProfile");
    return ClientDTO.fromJson(jsonDecode(userJson!));
  }

  Future<void> updateUser(
      String? fullAdresse,
      String? phoneNumber,
      )async{
    try{
      final userJson = await storage.read(key: "userProfile");
      final currentUser = jsonDecode(userJson!);
      final id = currentUser['id'];
      await client.post(
          Uri.parse("$baseUrl/update"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "id": id,
            "location": fullAdresse,
            "phoneNumber": phoneNumber,
          })
      );
    }catch(e){
      e.toString();
    }

  }

  Future<void> updatePassword(
      String currentPassword,
      String newPassword
      )async{
    try{
      await client.post(
          Uri.parse("$baseUrl/update/password"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "current_password": currentPassword,
            "new_password": newPassword,
          })
      );
    }catch(e){
      e.toString();
    }

  }

}
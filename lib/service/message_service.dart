import 'dart:convert';
import 'package:http/http.dart';
import 'package:le_coin_symbolique_front/model/conversation_dto.dart';

import '../model/conversation_preview.dart';
import '../model/message_dto.dart';
import 'auth_http_client.dart';


class MessageService {
  final client = AuthHttpClient();
  final String baseUrl = 'http://localhost:8080/api';

  Future<List<ConversationPreview>> getAllConversations() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/messages/conversation/all'),
      );

      return _parseConversationPreviews(response);
    } catch (e) {
      throw Exception('Erreur lors du chargement des conversations: ${e.toString()}');
    }
  }

  Future<bool> sendMessage(int interlocuteurId, String content, int? annonceId) async {
    try {
      final queryParams = <String, String>{};
      if (annonceId != null) {
        queryParams['annonceId'] = annonceId.toString();
      }

      final response = await client.post(
        Uri.parse('$baseUrl/messages/send/$interlocuteurId').replace(
          queryParameters: queryParams,
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'content': content,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi: ${e.toString()}');
    }
  }

  List<ConversationPreview> _parseConversationPreviews(Response response) {
    if (response.statusCode != 200) {
      throw Exception('Erreur ${response.statusCode}: ${response.body}');
    }

    try {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ConversationPreview.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Format de réponse invalide: $e');
    }
  }


  Future<ConversationDTO> getConversationDetail(int conversationId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/messages/conversation/$conversationId'),
      );

      if (response.statusCode == 200) {
        final dynamic jsonData = jsonDecode(response.body);

        // Vérification cruciale
        if (jsonData == null) {
          throw Exception('La réponse est nulle pour la conversation $conversationId');
        }

        return ConversationDTO.fromJson(jsonData as Map<String, dynamic>);
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la conversion en ConversationDTO: $e');
    }
  }

  Future<List<MessageDTO>> getMessages(int conversationId) async {
    final detail = await getConversationDetail(conversationId);
    return detail.messages.content;
  }

}
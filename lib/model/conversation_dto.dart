import 'package:le_coin_symbolique_front/model/annonce_dto.dart';
import 'package:le_coin_symbolique_front/model/client_dto.dart';
import 'package:le_coin_symbolique_front/model/pagination.dart';


class ConversationDTO {
  final ClientDTO client1;
  final ClientDTO client2;
  final List<AnnonceDTO> annonces;
  final PaginatedMessages messages;

  ConversationDTO({required this.client1, required this.client2, required this.annonces,required this.messages});
  factory ConversationDTO.fromJson(Map<String, dynamic> json) {
    return ConversationDTO(
      client1: ClientDTO.fromJson(json['client1']),
      client2: ClientDTO.fromJson(json['client2']),
      annonces: (json['annonces'] as List)
          .map((e) => AnnonceDTO.fromJson(e))
          .toList(),
      messages: PaginatedMessages.fromJson(json['messages']),
    );
  }
}
import 'client_dto.dart';
import 'message_dto.dart';

class ConversationPreview {
  final ClientDTO interlocuteur;
  final MessageDTO lastMessage;

  ConversationPreview({required this.interlocuteur, required this.lastMessage});

  factory ConversationPreview.fromJson(Map<String, dynamic> json) {
    return ConversationPreview(
      interlocuteur: ClientDTO.fromJson(json['interlocuteur']),
      lastMessage: MessageDTO.fromJson(json['lastMessage']),
    );
  }
}

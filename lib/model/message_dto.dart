import 'client_dto.dart';

class MessageDTO {
  final String content;
  final ClientDTO sender;
  final DateTime sentAt;
  final String status;

  MessageDTO({
    required this.content,
    required this.sender,
    required this.sentAt,
    required this.status,
  });

  factory MessageDTO.fromJson(Map<String, dynamic> json) {
    return MessageDTO(
      content: json['content'],
      sender: ClientDTO.fromJson(json['sender']),
      sentAt: DateTime.parse(json['sentAt']),
      status: json['status'],
    );
  }
}

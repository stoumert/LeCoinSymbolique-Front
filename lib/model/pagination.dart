import 'message_dto.dart';

class PaginatedMessages {
  final List<MessageDTO> content;
  final int totalElements;

  PaginatedMessages({
    required this.content,
    required this.totalElements,
  });

  factory PaginatedMessages.fromJson(Map<String, dynamic> json) {
    return PaginatedMessages(
      content: (json['content'] as List)
          .map((e) => MessageDTO.fromJson(e))
          .toList(),
      totalElements: json['totalElements'],
    );
  }
}
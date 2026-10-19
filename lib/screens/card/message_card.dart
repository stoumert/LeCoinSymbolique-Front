import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/message_dto.dart';

class MessageCard extends StatelessWidget {
  final MessageDTO message;
  final bool isCurrentUser;
  final bool showStatusIndicator;

  const MessageCard({
    Key? key,
    required this.message,
    required this.isCurrentUser,
    this.showStatusIndicator = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrentUser
              ? Theme.of(context).primaryColor
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isCurrentUser)
              Text(
                message.sender.username,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCurrentUser ? Colors.white : Colors.black,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              message.content,
              style: TextStyle(
                color: isCurrentUser ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('HH:mm').format(message.sentAt),
                  style: TextStyle(
                    color: isCurrentUser ? Colors.white70 : Colors.grey[600],
                    fontSize: 10,
                  ),
                ),
                if (isCurrentUser && showStatusIndicator) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.status == 'lu'
                        ? Icons.done_all
                        : Icons.done,
                    size: 16,
                    color: message.status == 'lu'
                        ? Colors.blue[100]
                        : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
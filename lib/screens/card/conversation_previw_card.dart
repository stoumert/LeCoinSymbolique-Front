import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/conversation_preview.dart';

class ConversationPreviewCard extends StatelessWidget {
  final ConversationPreview conversation;
  final VoidCallback onTap;

  const ConversationPreviewCard({
    Key? key,
    required this.conversation,
    required this.onTap,
  }) : super(key: key);

  String _formatMessageDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Aujourd\'hui à ${DateFormat('HH:mm').format(date)}';
    } else if (messageDate == today.subtract(Duration(days: 1))) {
      return 'Hier à ${DateFormat('HH:mm').format(date)}';
    } else {
      return DateFormat('dd/MM/yyyy à HH:mm').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lastMessage = conversation.lastMessage;
    final interlocuteur = conversation.interlocuteur;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              CircleAvatar(
                child: Text(interlocuteur.username[0].toUpperCase()),
                radius: 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          interlocuteur.username,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _formatMessageDate(lastMessage.sentAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        if (lastMessage.sender.id == interlocuteur.id)
                          Container()
                        else
                          Text(
                            'Vous: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            lastMessage.content,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (lastMessage.status == 'UNREAD')
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
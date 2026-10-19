import 'package:flutter/material.dart';
import 'package:le_coin_symbolique_front/service/message_service.dart';
import '../model/conversation_preview.dart';
import 'card/conversation_previw_card.dart';
import 'conversation_page.dart';

class ConversationListPage extends StatefulWidget {
  ConversationListPage({Key? key}) : super(key: key);

  @override
  _ConversationListPageState createState() => _ConversationListPageState();
}

class _ConversationListPageState extends State<ConversationListPage> {
  late Future<List<ConversationPreview>> _conversationsFuture;
  final MessageService messageService = MessageService();

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  void _loadConversations() {
    setState(() {
      _conversationsFuture = messageService.getAllConversations();
    });
  }

  void _navigateToConversation(BuildContext context, ConversationPreview conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationPage(
          interlocuteurId: conversation.interlocuteur.id,
          interlocuteurName: conversation.interlocuteur.username,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Messages')),
      body: FutureBuilder<List<ConversationPreview>>(
        future: _conversationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucune conversation'));
          }

          return RefreshIndicator(
            onRefresh: () async => _loadConversations(),
            child: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final conversation = snapshot.data![index];
                return ConversationPreviewCard(
                  conversation: conversation,
                  onTap: () => _navigateToConversation(context, conversation),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
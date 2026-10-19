import 'package:flutter/material.dart';
import 'package:le_coin_symbolique_front/model/annonce_dto.dart';
import 'package:le_coin_symbolique_front/model/client_dto.dart';
import 'package:le_coin_symbolique_front/model/message_dto.dart';
import 'package:le_coin_symbolique_front/service/client_service.dart';
import 'package:le_coin_symbolique_front/service/message_service.dart';

import 'card/message_card.dart';

class ConversationPage extends StatefulWidget {
  final int interlocuteurId;
  final String interlocuteurName;
  final int? annonceId;

  const ConversationPage({
    Key? key,
    required this.interlocuteurId,
    required this.interlocuteurName,
    this.annonceId,
  }) : super(key: key);

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final MessageService _messageService = MessageService();
  final ClientService _clientService = ClientService();

  List<MessageDTO> _messages = [];
  List<AnnonceDTO> _annonces = [];
  ClientDTO? _currentUser;
  bool _isLoading = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _initializeConversation();
  }

  Future<void> _initializeConversation() async {
    setState(() => _isLoading = true);
    try {
      await _loadCurrentUser();
      await _loadConversation();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCurrentUser() async {
    final user = await _clientService.getCurrentUser();
    setState(() => _currentUser = user);
  }

  Future<void> _loadConversation() async {
    if (_currentUser == null) return;

    final response = await _messageService.getConversationDetail(
      widget.interlocuteurId,
    );

    setState(() {
      _messages = response.messages.content;
      _annonces = response.annonces;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _sendMessage() async {
    if (_currentUser == null || _isSending) return;

    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    setState(() {
      _isSending = true;
      _messageController.clear();
    });

    final newMessage = MessageDTO(
      content: content,
      sender: _currentUser!,
      sentAt: DateTime.now(),
      status: 'SENDING',
    );

    setState(() {
      _messages.insert(0, newMessage);
      _scrollToBottom();
    });

    try {
      final success = await _messageService.sendMessage(
        widget.interlocuteurId,
        content,
        widget.annonceId
      );

      if (!success) throw Exception('Échec de l\'envoi');

      setState(() {
        final index = _messages.indexWhere((m) => m == newMessage);
        if (index != -1) {
          _messages[index] = _messages[index];
        }
      });
    } catch (e) {
      setState(() => _messages.remove(newMessage));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null && !_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Vous devez être connecté pour voir les messages'),
              TextButton(
                onPressed: _initializeConversation,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.interlocuteurName),
            if (_annonces.isNotEmpty)
              Text(
                _annonces.first.title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
              onRefresh: _loadConversation,
              child: ListView.builder(
                reverse: true,
                controller: _scrollController,
                padding: const EdgeInsets.all(8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isCurrentUser = _currentUser != null &&
                      message.sender.id == _currentUser!.id;

                  bool isLastUserMessage = false;
                  if (isCurrentUser) {
                    if (index == 0) {
                      isLastUserMessage = true;
                    } else {
                      isLastUserMessage = _messages[index-1].sender.id != _currentUser!.id;
                    }
                  }

                  return MessageCard(
                    message: message,
                    isCurrentUser: isCurrentUser,
                    showStatusIndicator: isLastUserMessage, // Seul le dernier message montre le statut
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0), // Augmentation du padding vertical
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8.0), // Ajout d'une marge en bas
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Écrivez un message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                IconButton(
                  icon: _isSending
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.send),
                  color: Theme.of(context).primaryColor,
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
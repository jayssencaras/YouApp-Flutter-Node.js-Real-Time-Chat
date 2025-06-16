import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final String recipientId;
  final String recipientUsername;

  const ChatScreen({
    Key? key,
    required this.recipientId,
    required this.recipientUsername,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    _connectSocket();
    _loadMessages();
  }

  @override
  void dispose() {
    socket.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _connectSocket() {
    socket = IO.io('http://10.0.2.2:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      final userId = ApiService.getLoggedInUserId();
      socket.emit('register', userId);
    });

    socket.on('newMessage', (data) {
      setState(() {
        _messages.add(data);
      });
    });

    socket.onDisconnect((_) => print('Socket disconnected'));
  }

  Future<void> _loadMessages() async {
    final messages = await ApiService.getMessages(widget.recipientId);
    if (mounted && messages != null) {
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final success = await ApiService.sendMessage(widget.recipientId, text);
    if (success) {
      final currentUserId = ApiService.getLoggedInUserId();
      socket.emit('sendMessage', {
        'senderId': currentUserId,
        'recipientId': widget.recipientId,
        'content': text,
        'timestamp': DateTime.now().toIso8601String(),
      });

      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipientUsername),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMe = message['sender']['_id'] ==
                          ApiService.getLoggedInUserId();

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blueAccent : Colors.grey[800],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message['content'],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: Colors.deepPurple,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final allUsers = await ApiService.fetchAllUsers();
    final currentUserEmail = ApiService.getLoggedInUserEmail();

    if (allUsers != null && currentUserEmail != null) {
      setState(() {
        // Filter out the current user from the user list
        users = allUsers
            .where((user) => user['email'] != currentUserEmail)
            .toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void openChat(Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          recipientId: user['_id'],
          recipientUsername: user['username'] ?? user['email'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
              ? const Center(child: Text("No users found"))
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      leading: const Icon(Icons.account_circle),
                      title: Text(user['username'] ?? user['email']),
                      subtitle: Text(user['email']),
                      onTap: () => openChat(user),
                    );
                  },
                ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  String? currentEmail;

  @override
  void initState() {
    super.initState();
    currentEmail = ApiService.getLoggedInUserEmail();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await ApiService.fetchAllUsers();
      if (response != null) {
        setState(() {
          users =
              response.where((user) => user['email'] != currentEmail).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching users: $e');
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
        title: const Text("Select a User"),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(user['username'] ?? user['email']),
                  subtitle: Text(user['email']),
                  onTap: () => openChat(user),
                );
              },
            ),
    );
  }
}

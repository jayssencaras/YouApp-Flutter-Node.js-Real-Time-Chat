import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../widgets/background_container.dart';
import 'edit_about_screen.dart';
import 'edit_interest_screen.dart';
import 'user_list_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = '';
  String email = '';
  String about = '';
  String interest = '';
  String displayName = '';
  String gender = '';
  String birthday = '';
  String horoscope = '';
  String zodiac = '';
  String height = '';
  String weight = '';
  String avatarUrl = ''; // NEW
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    final data = await ApiService.fetchProfile();
    if (data != null) {
      setState(() {
        username = data['username'] ?? '';
        email = data['email'] ?? '';
        about =
            data['about'] ?? 'Add in your about to help others know you better';
        interest =
            data['interest'] ?? 'Add in your interest to find a better match';
        displayName = data['displayName'] ?? '';
        gender = data['gender'] ?? '';
        birthday = data['birthday'] ?? '';
        horoscope = data['horoscope'] ?? '';
        zodiac = data['zodiac'] ?? '';
        height = data['height'] ?? '';
        weight = data['weight'] ?? '';
        avatarUrl = data['avatar'] ?? ''; // NEW
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final success = await ApiService.uploadAvatar(file);
      if (success) {
        await _fetchProfileData(); // Refresh profile to get new avatar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar updated!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload avatar.')),
        );
      }
    }
  }

  void _editAbout() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditAboutScreen(currentAbout: about),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        displayName = result['displayName'] ?? displayName;
        gender = result['gender'] ?? gender;
        birthday = result['birthday'] ?? birthday;
        horoscope = result['horoscope'] ?? horoscope;
        zodiac = result['zodiac'] ?? zodiac;
        height = result['height'] ?? height;
        weight = result['weight'] ?? weight;
      });

      await ApiService.updateProfile({
        'displayName': displayName,
        'gender': gender,
        'birthday': birthday,
        'horoscope': horoscope,
        'zodiac': zodiac,
        'height': height,
        'weight': weight,
      });

      await _fetchProfileData();
    }
  }

  void _editInterest() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditInterestScreen(currentInterest: interest),
      ),
    );

    if (result != null && result is String) {
      setState(() {
        interest = result;
      });
      await ApiService.updateProfile({'interest': interest});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndUploadAvatar,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
      body: BackgroundContainer(
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Text(
                            '@$username',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: avatarUrl.isNotEmpty
                              ? NetworkImage('http://localhost:5000$avatarUrl')
                              : const AssetImage('assets/default_avatar.png')
                                  as ImageProvider,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const UserListScreen()),
                            );
                          },
                          icon: const Icon(Icons.message),
                          label: const Text('Chat with Other Users'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildProfileCard(
                        title: 'Email',
                        content: Text(
                          email,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                        onEdit: null,
                      ),
                      const SizedBox(height: 16),
                      _buildProfileCard(
                        title: 'About',
                        content: _buildAboutContent(),
                        onEdit: _editAbout,
                      ),
                      const SizedBox(height: 16),
                      _buildProfileCard(
                        title: 'Interest',
                        content: Text(
                          interest,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                        onEdit: _editInterest,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required String title,
    required Widget content,
    VoidCallback? onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: onEdit,
                ),
            ],
          ),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }

  Widget _buildAboutContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAboutField('Display Name', displayName),
        _buildAboutField('Gender', gender),
        _buildAboutField('Birthday', birthday),
        _buildAboutField('Horoscope', horoscope),
        _buildAboutField('Zodiac', zodiac),
        _buildAboutField('Height', height),
        _buildAboutField('Weight', weight),
      ],
    );
  }

  Widget _buildAboutField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value.isNotEmpty ? value : '--',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/background_container.dart';

class EditAboutScreen extends StatefulWidget {
  final String currentAbout;

  const EditAboutScreen({super.key, required this.currentAbout});

  @override
  State<EditAboutScreen> createState() => _EditAboutScreenState();
}

class _EditAboutScreenState extends State<EditAboutScreen> {
  final TextEditingController displayNameController = TextEditingController();
  String selectedGender = 'Select Gender';
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController horoscopeController = TextEditingController();
  final TextEditingController zodiacController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  bool isSaving = false;

  @override
  void dispose() {
    displayNameController.dispose();
    birthdayController.dispose();
    horoscopeController.dispose();
    zodiacController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() {
      isSaving = true;
    });

    final profileData = {
      'displayName': displayNameController.text.trim(),
      'gender': selectedGender,
      'birthday': birthdayController.text.trim(),
      'horoscope': horoscopeController.text.trim(),
      'zodiac': zodiacController.text.trim(),
      'height': heightController.text.trim(),
      'weight': weightController.text.trim(),
    };

    // For now, let's assume the user's email is available from ApiService (or replace with actual email)
    final userEmail = ApiService.getLoggedInUserEmail();
    final success = await ApiService.updateProfile(profileData);

    setState(() {
      isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.pop(context, profileData);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Edit About',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      isSaving
                          ? const CircularProgressIndicator()
                          : TextButton(
                              onPressed: _saveProfile,
                              child: const Text(
                                'Save & Update',
                                style: TextStyle(
                                    color: Colors.blueAccent, fontSize: 16),
                              ),
                            ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.add_a_photo, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Display name',
                    controller: displayNameController,
                    hintText: 'Enter name',
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    label: 'Gender',
                    value: selectedGender,
                    items: const ['Select Gender', 'Male', 'Female', 'Other'],
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Birthday',
                    controller: birthdayController,
                    hintText: 'DD MM YYYY',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Horoscope',
                    controller: horoscopeController,
                    hintText: '--',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Zodiac',
                    controller: zodiacController,
                    hintText: '--',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Height',
                    controller: heightController,
                    hintText: 'Add height',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Weight',
                    controller: weightController,
                    hintText: 'Add weight',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.black.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            dropdownColor: Colors.black,
            underline: const SizedBox(),
            onChanged: onChanged,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

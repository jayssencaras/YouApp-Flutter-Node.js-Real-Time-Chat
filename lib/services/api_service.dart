import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // For ContentType

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';
  static String? _token;
  static String? _email; // 🔥 Store email after login

  static Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['access_token'];
      _email = email; // 🔥 store email
      return true;
    } else {
      return false;
    }
  }

  static String? getLoggedInUserEmail() {
    return _email;
  }

  static Future<http.Response> getProfile() async {
    final url = Uri.parse('$baseUrl/profile');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );
    return response;
  }

  static Future<bool> register(
      String email, String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print('Registration failed: ${response.body}');
      return false;
    }
  }

  /// 🔥 NEW: Fetch Profile Data
  static Future<Map<String, dynamic>?> fetchProfile() async {
    final url = Uri.parse('$baseUrl/profile');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print(
          'Failed to fetch profile: ${response.statusCode} - ${response.body}');
      return null;
    }
  }

  /// 🔥 NEW: Update Profile Data
  static Future<bool> updateProfile(Map<String, dynamic> updatedData) async {
    final url = Uri.parse('$baseUrl/profile');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode(updatedData),
    );

    if (response.statusCode == 200) {
      print('Profile updated successfully!');
      return true;
    } else {
      print(
          'Failed to update profile: ${response.statusCode} - ${response.body}');
      return false;
    }
  }

  /// 🔵 Send a chat message
  static Future<bool> sendMessage(String recipientId, String content) async {
    final url = Uri.parse('$baseUrl/messages/send');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode({
        'recipientId': recipientId,
        'content': content,
      }),
    );

    if (response.statusCode == 201) {
      print('Message sent!');
      return true;
    } else {
      print('Failed to send message: ${response.body}');
      return false;
    }
  }

  /// 🔵 Fetch conversation with a user
  static Future<List<Map<String, dynamic>>?> getMessages(
      String otherUserId) async {
    final url = Uri.parse('$baseUrl/messages/conversation/$otherUserId');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      print('Failed to load conversation: ${response.body}');
      return null;
    }
  }

  static Future<bool> uploadAvatar(File avatarFile) async {
    final url = Uri.parse('$baseUrl/profile/avatar');
    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $_token';

    request.files.add(
      await http.MultipartFile.fromPath(
        'avatar',
        avatarFile.path,
        contentType: MediaType('image', 'jpeg'), // adjust as needed
      ),
    );

    final response = await request.send();
    if (response.statusCode == 200) {
      print('Avatar uploaded successfully!');
      return true;
    } else {
      print('Failed to upload avatar. Status code: ${response.statusCode}');
      return false;
    }
  }

  /// 🔵 Fetch all users
  static Future<List<Map<String, dynamic>>?> fetchAllUsers() async {
    final url = Uri.parse('$baseUrl/users/all');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      print('Failed to load users: ${response.body}');
      return null;
    }
  }

  static String? getLoggedInUserId() {
    final token = _token;
    if (token == null) return null;

    final parts = token.split('.');
    if (parts.length != 3) return null;

    final payload =
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final data = jsonDecode(payload);
    return data['id'];
  }

  static Map<String, dynamic> _decodeJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return {};
    final payload =
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    return jsonDecode(payload);
  }
}

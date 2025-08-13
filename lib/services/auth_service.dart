import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl = 'https://backend.tenderfinder.net/api/v1';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Login method
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save user data and token to shared preferences
        if (data['token'] != null) {
          await _saveUserData(data);
        }
        return {
          'success': true,
          'data': data,
          'message': data['message'] ?? 'Login successful',
        };
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Register method
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Save user data and token to shared preferences if provided
        if (data['token'] != null) {
          await _saveUserData(data);
        }
        return {
          'success': true,
          'data': data,
          'message': data['message'] ?? 'Registration successful',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
          'errors': data['errors'] ?? {},
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Save user data to secure storage
  static Future<void> _saveUserData(Map<String, dynamic> data) async {
    if (data['token'] != null) {
      await _secureStorage.write(key: 'auth_token', value: data['token']);
      // Save login timestamp for session expiry (3 minutes for testing)
      await _secureStorage.write(
        key: 'login_timestamp',
        value: DateTime.now().millisecondsSinceEpoch.toString(),
      );
    }

    if (data['user'] != null) {
      await _secureStorage.write(
        key: 'user_data',
        value: jsonEncode(data['user']),
      );
      await _secureStorage.write(
        key: 'user_name',
        value: data['user']['name'] ?? '',
      );
      await _secureStorage.write(
        key: 'user_email',
        value: data['user']['email'] ?? '',
      );
    }
  }

  // Get saved user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final token = await _secureStorage.read(key: 'auth_token');
    final userData = await _secureStorage.read(key: 'user_data');
    final loginTimestampString = await _secureStorage.read(
      key: 'login_timestamp',
    );

    if (token != null && userData != null && loginTimestampString != null) {
      final loginTimestamp = int.tryParse(loginTimestampString);

      if (loginTimestamp != null) {
        // Check if session has expired (3 minutes = 180000 milliseconds)
        final currentTime = DateTime.now().millisecondsSinceEpoch;
        final sessionDuration = currentTime - loginTimestamp;
        const sessionExpiry = 10800000; // 3 hours in milliseconds

        if (sessionDuration > sessionExpiry) {
          // Session expired, clear data
          await logout();
          return null;
        }

        return {'token': token, 'user': jsonDecode(userData)};
      }
    }
    return null;
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: 'auth_token');
    return token != null;
  }

  // Logout method
  static Future<void> logout() async {
    await _secureStorage.delete(key: 'auth_token');
    await _secureStorage.delete(key: 'user_data');
    await _secureStorage.delete(key: 'user_name');
    await _secureStorage.delete(key: 'user_email');
    await _secureStorage.delete(key: 'login_timestamp');
  }

  // Get auth token
  static Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }
}

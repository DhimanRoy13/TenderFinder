import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  Map<String, dynamic>? _user;
  String? _token;
  bool _isLoading = false;

  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;

  // Initialize auth state on app start
  Future<void> initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    final userData = await AuthService.getUserData();
    if (userData != null) {
      _isLoggedIn = true;
      _user = userData['user'];
      _token = userData['token'];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await AuthService.login(email, password);

    if (result['success']) {
      _isLoggedIn = true;
      _user = result['data']['user'];
      _token = result['data']['token'];
    }

    _isLoading = false;
    notifyListeners();

    return result;
  }

  // Register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await AuthService.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    if (result['success']) {
      _isLoggedIn = true;
      _user = result['data']['user'];
      _token = result['data']['token'];
    }

    _isLoading = false;
    notifyListeners();

    return result;
  }

  // Logout
  Future<void> logout() async {
    await AuthService.logout();
    _isLoggedIn = false;
    _user = null;
    _token = null;
    notifyListeners();
  }

  // Get user name
  String get userName => _user?['name'] ?? '';

  // Get user email
  String get userEmail => _user?['email'] ?? '';

  // Update user data
  void updateUserData({String? name, String? email}) {
    if (_user != null) {
      if (name != null) _user!['name'] = name;
      if (email != null) _user!['email'] = email;
      notifyListeners();
    }
  }
}

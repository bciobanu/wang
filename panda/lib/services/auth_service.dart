import 'dart:html' show window;

class AuthService {
  static bool get isAuthenticated => hasAuthToken;

  static bool get hasAuthToken => authToken != null;

  static String get authToken => window.localStorage['auth-token'];

  static void setNotAuthenticated() {
    window.localStorage.remove('auth-token');
  }

  static void setAuthenticated(String authToken) {
    window.localStorage['auth-token'] = authToken;
  }
}

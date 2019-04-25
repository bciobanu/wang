import 'dart:html' show window;

import 'package:panda/common/credentials.dart';
import 'package:panda/rest_api_client/rest_api_client.dart';
import 'package:quiver/core.dart';

class AuthService {
  final RestApiClient _apiClient;

  AuthService(this._apiClient);

  Future<Optional<String>> register(Credentials credentials) async {
    final response = await _apiClient.post('/auth/register', {
      'username': credentials.username,
      'password': credentials.password,
    });
    if (response.statusCode == 200) {
      return Optional.of(response.body['message']);
    }
    return Optional.absent();
  }

  Future<Optional<String>> login(Credentials credentials) async {
    final response = await _apiClient.post('/auth/login', {
      'username': credentials.username,
      'password': credentials.password,
    });
    if (response.statusCode != 200) {
      return Optional.of(response.body['message']);
    }
    setAuthenticated(response.body['token']);
    return Optional.absent();
  }

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

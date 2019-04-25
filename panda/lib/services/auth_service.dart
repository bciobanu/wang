import 'dart:html' show window;

import 'package:angular/angular.dart';
import 'package:meta/meta.dart';
import 'package:panda/rest_api_client/middleware.dart';
import 'package:panda/rest_api_client/rest_api_response.dart';

class AuthData {
  final String authToken;
  final String username;

  AuthData({@required this.authToken, @required this.username});
}

@Injectable()
class AuthService {
  String _ownUsername = null;

  bool get isAuthenticated => hasAuthToken;

  bool get hasAuthToken => authToken != null;

  String get authToken => window.localStorage['auth-token'];

  String get ownUsername => _ownUsername;

  void setNotAuthenticated() {
    window.localStorage.remove('auth-token');
    _ownUsername = null;
  }

  void setAuthenticated(AuthData authData) {
    window.localStorage['auth-token'] = authData.authToken;
    _ownUsername = authData.username;
  }

  Middleware getMiddleware() {
    return _AuthMiddleware(this);
  }
}

class _AuthMiddleware implements Middleware {
  final AuthService _authService;

  _AuthMiddleware(this._authService);

  @override
  void onRequest(Map<String, String> headers, [Map<String, dynamic> body]) {
    if (_authService.hasAuthToken) {
      headers['x-access-token'] = _authService.authToken;
    }
  }

  @override
  bool onResponse(RestApiResponseBuilder builder) {
    if (builder.statusCode == 401) {
      _authService.setNotAuthenticated();
    }
    return true;
  }
}

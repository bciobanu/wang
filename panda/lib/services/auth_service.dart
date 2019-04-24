import 'dart:html' show window;

import 'package:angular/angular.dart';

class LoginResponse {
  final String error;

  final String authToken;
  final int userId;
  final String username;

  LoginResponse.unsuccessful(this.error)
      : authToken = null,
        userId = null,
        username = null;

  LoginResponse.successful(Map<String, dynamic> response)
      : error = null,
        authToken = response['authToken'],
        userId = response['userId'],
        username = response['username'];

  bool get hasError => error?.isNotEmpty;
}

@Injectable()
class AuthService {
  _User _ownUser = null;

  bool get isAuthenticated => hasAuthToken;

  bool get hasAuthToken => authToken != null;

  String get authToken => window.localStorage['auth-token'];

  int get ownUserId {
    if (_ownUser == null) {
      throw StateError("Called AuthService.ownUserId before setUser");
    }
    return _ownUser.id;
  }

  String get ownUsername {
    if (_ownUser == null) {
      throw StateError("Called AuthService.ownUsername before setUser");
    }
    return _ownUser.username;
  }

  void setNotAuthenticated() {
    window.localStorage.remove('auth-token');
    _ownUser = null;
  }

  void setAuthenticated(LoginResponse loginResponse) {
    window.localStorage['auth-token'] = loginResponse.authToken;
    _ownUser = _User(loginResponse.userId, loginResponse.username);
  }
}

class _User {
  final int id;
  final String username;

  _User(this.id, this.username);
}

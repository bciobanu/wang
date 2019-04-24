import 'dart:html' show window;

import 'package:angular/angular.dart';

class _User {
  final int id;
  final String username;

  _User(this.id, this.username);
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

  void setAuthenticated(String authToken, Map<String, dynamic> apiResponse) {
    window.localStorage['auth-token'] = authToken;
    _ownUser = _User(apiResponse['id'], apiResponse['username']);
  }
}

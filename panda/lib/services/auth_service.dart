import 'dart:html' show window;

import 'package:angular/angular.dart';
import 'package:meta/meta.dart';

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
}

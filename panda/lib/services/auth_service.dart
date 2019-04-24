import 'dart:html' show window;

import 'package:angular/angular.dart';
import 'package:meta/meta.dart';

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

  void setAuthenticated(
      {@required String authToken, @required String username}) {
    window.localStorage['auth-token'] = authToken;
    _ownUsername = username;
  }
}

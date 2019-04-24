import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';

class LoginCredentials {
  final String username;
  final String password;

  LoginCredentials(this.username, this.password);
}

@Component(
  selector: 'login-form',
  templateUrl: 'login_form.html',
  styleUrls: ['login_form.css'],
  directives: [coreDirectives, formDirectives],
)
class LoginFormComponent {
  final _loginSubmitController = StreamController<LoginCredentials>();

  @Input()
  String loginError = "";

  @Input()
  String username = "";

  @Input()
  String password = "";

  bool get hasLoginError => loginError?.isNotEmpty;

  @Output()
  Stream<LoginCredentials> get loginSubmit => _loginSubmitController.stream;

  void onSubmit() {
    _loginSubmitController.add(LoginCredentials(username, password));
  }
}

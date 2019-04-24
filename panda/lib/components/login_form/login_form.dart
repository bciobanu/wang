import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:panda/common/credentials.dart';

@Component(
  selector: 'login-form',
  templateUrl: 'login_form.html',
  styleUrls: ['login_form.css'],
  directives: [coreDirectives, formDirectives],
)
class LoginFormComponent {
  final _loginStreamer = StreamController<Credentials>();

  @Input()
  String loginError = "";

  @Input()
  String username = "";

  @Input()
  String password = "";

  bool get hasLoginError => loginError?.isNotEmpty;

  @Output()
  Stream<Credentials> get loginSubmit => _loginStreamer.stream;

  void onSubmit() {
    _loginStreamer.add(Credentials(username: username, password: password));
  }
}

import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';

class RegisterCredentials {
  final String username;
  final String password;

  RegisterCredentials(this.username, this.password);
}

@Component(
  selector: 'register-form',
  templateUrl: 'register_form.html',
  styleUrls: ['register_form.css'],
  directives: [coreDirectives, formDirectives],
)
class RegisterFormComponent {
  final _registerSubmitController = StreamController<RegisterCredentials>();

  @Input()
  String registrationError = "";

  @Input()
  String username = "";

  @Input()
  String password = "";

  @Input()
  String retypedPassword = "";

  @Input()
  bool registrationSuccessful = false;

  bool get hasRegistrationError => registrationError?.isNotEmpty;

  bool get passwordsMatch => password == retypedPassword;

  @Output()
  Stream<RegisterCredentials> get registerSubmit =>
      _registerSubmitController.stream;

  void onSubmit() {
    _registerSubmitController.add(RegisterCredentials(username, password));
  }
}

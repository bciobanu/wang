import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:panda/common/credentials.dart';

@Component(
  selector: 'register-form',
  templateUrl: 'register_form.html',
  styleUrls: ['register_form.css'],
  directives: [coreDirectives, formDirectives],
)
class RegisterFormComponent {
  final _registerStreamer = StreamController<Credentials>();

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

  bool get passwordsMatch =>
      password == retypedPassword || retypedPassword.isEmpty;

  @Output()
  Stream<Credentials> get registerSubmit => _registerStreamer.stream;

  void onSubmit() => _registerStreamer
      .add(Credentials(username: username, password: password));
}

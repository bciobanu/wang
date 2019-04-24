import 'package:angular/angular.dart' show Component, OnInit, NgIf;
import 'package:quiver/core.dart' show Optional;
import 'package:angular_components/material_spinner/material_spinner.dart';
import 'package:panda/components/login_form/login_form.dart';
import 'package:panda/components/register_form/register_form.dart';
import 'package:panda/services/auth_service.dart';
import 'package:panda/services/rest_api_client.dart';

@Component(
  selector: 'panda-app',
  templateUrl: 'panda_app.html',
  directives: [
    MaterialSpinnerComponent,
    LoginFormComponent,
    RegisterFormComponent,
    NgIf
  ],
  styleUrls: [
    'panda_app.css',
    'package:angular_components/app_layout/layout.scss.css'
  ],
)
class PandaAppComponent implements OnInit {
  AuthService authService;
  RestApiClient _apiClient;

  bool attemptedInitialLoad = false;

  String loginError = "";
  String registrationError = "";
  bool registrationSuccessful = false;

  PandaAppComponent(this.authService, this._apiClient);

  @override
  void ngOnInit() async {
    await _apiClient.getOwnUser();
    attemptedInitialLoad = true;
  }

  void onLoginCredentials(LoginCredentials credentials) {
    print(credentials.username + " " + credentials.password);
    loginError = "Invalid username or password.";
  }

  void onRegisterCredentials(RegisterCredentials credentials) async {
    Optional<String> err =
        await _apiClient.register(credentials.username, credentials.password);
    if (err.isPresent) {
      registrationError = err.value;
    } else {
      registrationSuccessful = true;
    }
  }
}

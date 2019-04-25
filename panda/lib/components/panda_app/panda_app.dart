import 'package:angular/angular.dart' show Component, OnInit, coreDirectives;
import 'package:panda/common/credentials.dart';
import 'package:angular_components/material_spinner/material_spinner.dart';
import 'package:panda/components/login_form/login_form.dart';
import 'package:panda/components/register_form/register_form.dart';
import 'package:panda/components/wang_page/wang_page.dart';
import 'package:panda/services/auth_service.dart';
import 'package:panda/rest_api_client/rest_api_client.dart';

@Component(
  selector: 'panda-app',
  templateUrl: 'panda_app.html',
  directives: [
    MaterialSpinnerComponent,
    LoginFormComponent,
    RegisterFormComponent,
    WangPageComponent,
    coreDirectives,
  ],
  exports: [AuthService],
  styleUrls: [
    'panda_app.css',
    'package:angular_components/app_layout/layout.scss.css',
  ],
)
class PandaAppComponent implements OnInit {
  AuthService _authService;
  RestApiClient _apiClient;

  bool attemptedInitialLoad = false;

  String loginError = "";
  String registrationError = "";
  bool registrationSuccessful = false;

  PandaAppComponent(this._authService, this._apiClient);

  @override
  void ngOnInit() async {
    final response = await _apiClient.get('/user');
    if (!AuthService.isAuthenticated || response.statusCode != 200) {
      AuthService.setNotAuthenticated();
    }
    attemptedInitialLoad = true;
  }

  void onLoginCredentials(Credentials credentials) async {
    final loginResult = await _apiClient.login(credentials);
    if (loginResult.hasError) {
      loginError = loginResult.error;
    } else {
      AuthService.setAuthenticated(loginResult.value);
    }
  }

  void onRegisterCredentials(Credentials credentials) async {
    final registerResult = await _apiClient.register(credentials);
    if (registerResult.hasError) {
      registrationError = registerResult.error;
    } else {
      registrationSuccessful = true;
    }
  }
}

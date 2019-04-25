import 'package:panda/rest_api_client/middleware.dart';
import 'package:panda/rest_api_client/rest_api_response.dart';
import 'package:panda/services/auth_service.dart';

class AuthMiddleware implements Middleware {
  @override
  void onRequest(Map<String, String> headers, [Map<String, dynamic> body]) {
    if (AuthService.hasAuthToken) {
      headers['x-access-token'] = AuthService.authToken;
    }
  }

  @override
  bool onResponse(RestApiResponseBuilder builder) {
    if (builder.statusCode == 401) {
      AuthService.setNotAuthenticated();
    }
    return true;
  }
}
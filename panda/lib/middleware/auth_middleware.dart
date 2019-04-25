import 'package:panda/rest_api_client/middleware.dart';
import 'package:panda/rest_api_client/rest_api_request_builder.dart';
import 'package:panda/rest_api_client/rest_api_response.dart';
import 'package:panda/services/auth_service.dart';

class AuthMiddleware extends Middleware {
  @override
  void onRequest(RestApiRequestBuilder requestBuilder) {
    if (AuthService.hasAuthToken) {
      requestBuilder.headers['x-access-token'] = AuthService.authToken;
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
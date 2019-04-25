import 'rest_api_response.dart';

abstract class Middleware {
  void onRequest(Map<String, String> headers, Map<String, dynamic> body);

  bool onResponse(RestApiResponseBuilder response);
}

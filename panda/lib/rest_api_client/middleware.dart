import 'rest_api_request_builder.dart';
import 'rest_api_response.dart';

abstract class Middleware {
  void onRequest(RestApiRequestBuilder request) {}

  bool onResponse(RestApiResponseBuilder response) => true;
}

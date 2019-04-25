import 'package:http/http.dart' as http;

import 'middleware.dart';
import 'rest_api_request_builder.dart';
import 'rest_api_response.dart';

class RestApiClient {
  final http.Client _client;
  final List<Middleware> _middlewares;

  RestApiClient(this._client, this._middlewares);

  Future<RestApiResponse> get(String url) async {
    return await _fetch('GET', url, null);
  }

  Future<RestApiResponse> post(String url, Map<String, String> body) async {
    return await _fetch('POST', url, body);
  }

  Future<RestApiResponse> put(String url, Map<String, String> body) async {
    return await _fetch('PUT', url, body);
  }

  Future<RestApiResponse> _fetch(
      String method, String url, Map<String, dynamic> body) async {
    final requestBuilder = RestApiRequestBuilder(body)
      ..method = method
      ..url = Uri.parse(url);

    for (final middleware in _middlewares) {
      middleware.onRequest(requestBuilder);
    }

    RestApiResponseBuilder responseBuilder;
    try {
      final streamedResponse = await _client.send(requestBuilder.build());
      final response = await http.Response.fromStream(streamedResponse);
      responseBuilder = RestApiResponseBuilder(response);
    } catch (error) {
      responseBuilder = RestApiResponseBuilder.networkError();
    }

    for (final middleware in _middlewares) {
      if (!middleware.onResponse(responseBuilder)) {
        break;
      }
    }

    return responseBuilder.build();
  }
}

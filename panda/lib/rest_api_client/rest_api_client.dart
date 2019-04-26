import 'package:http/http.dart' as http;

import 'middleware.dart';
import 'rest_api_request_builder.dart';
import 'rest_api_response.dart';

class RestApiClient {
  final http.Client _client;
  final List<Middleware> _middleware;

  RestApiClient(this._client, this._middleware);

  Future<RestApiResponse> get(String url) async {
    return await _fetch('GET', url);
  }

  Future<RestApiResponse> post(String url, Map<String, String> body) async {
    return await _fetch('POST', url, body);
  }

  Future<RestApiResponse> put(String url, Map<String, String> body) async {
    return await _fetch('PUT', url, body);
  }

  Future<RestApiResponse> _fetch(
      String method, String url, [Map<String, dynamic> body]) async {
    final requestBuilder = RestApiRequestBuilder(body)
      ..method = method
      ..url = Uri.parse(url);

    for (final middleware in _middleware) {
      middleware.onRequest(requestBuilder);
    }

    final request = requestBuilder.build();

    RestApiResponseBuilder responseBuilder;
    try {
      final response =
          await http.Response.fromStream(await _client.send(request));
      responseBuilder = RestApiResponseBuilder(request, response);
    } catch (error) {
      responseBuilder = RestApiResponseBuilder.networkError(request);
    }

    for (final middleware in _middleware) {
      if (!middleware.onResponse(responseBuilder)) {
        break;
      }
    }

    return responseBuilder.build();
  }
}

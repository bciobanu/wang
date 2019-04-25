import 'package:http/http.dart' as http;

import 'middleware.dart';
import 'rest_api_response.dart';

typedef _Fetch = Future<http.Response> Function(
    String url, Map<String, String> headers, Map<String, dynamic> body);

class RestApiClient {
  final http.Client _client;
  final String _apiAddress;
  final List<Middleware> _middlewares;

  RestApiClient(this._client, this._apiAddress, this._middlewares);

  Future<RestApiResponse> get(String url) async {
    return await _fetch(
      (url, headers, body) async => await _client.get(url, headers: headers),
      url,
      null,
    );
  }

  Future<RestApiResponse> post(String url, Map<String, String> body) async {
    return await _fetch(
      (url, headers, body) async =>
          await _client.post(url, headers: headers, body: body),
      url,
      body,
    );
  }

  Future<RestApiResponse> put(String url, Map<String, String> body) async {
    return await _fetch(
      (url, headers, body) async =>
          await _client.put(url, headers: headers, body: body),
      url,
      body,
    );
  }

  Future<RestApiResponse> _fetch(
      _Fetch rawFetch, String url, Map<String, dynamic> body) async {
    final headers = Map<String, String>();

    for (final middleware in _middlewares) {
      middleware.onRequest(headers, body);
    }

    RestApiResponseBuilder builder;
    try {
      final response = await rawFetch(_apiAddress + url, headers, body);
      builder = RestApiResponseBuilder(response);
    } catch (error) {
      builder = RestApiResponseBuilder.networkError();
    }

    for (final middleware in _middlewares) {
      if (!middleware.onResponse(builder)) {
        break;
      }
    }

    return builder.toResponse();
  }
}

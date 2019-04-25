import 'dart:convert';

import 'package:angular/angular.dart' show Inject, Injectable, OpaqueToken;
import 'package:http/http.dart' as http;

import 'package:panda/common/credentials.dart';
import 'package:panda/common/error_or.dart';
import 'package:panda/common/tikz_compilation_result.dart';
import 'auth_service.dart';

const apiAddress = OpaqueToken<String>('apiAddress');

class RestApiResponse {
  final int statusCode;
  final dynamic body;

  RestApiResponse(http.Response response)
      : statusCode = response.statusCode,
        body = JsonDecoder().convert(response.body);

  RestApiResponse.networkError()
      : statusCode = -1,
        body = {'message': 'Network error.'};
}

@Injectable()
class RestApiClient {
  final http.Client _client;
  final String _apiAddress;
  final AuthService _authService;

  RestApiClient(
      this._client, @Inject(apiAddress) this._apiAddress, this._authService);

  Future<void> fetchOwnUser() async {
    if (!_authService.hasAuthToken) {
      return;
    }
    final response = await get('/user');
    if (response.statusCode == 200) {
      _authService.setAuthenticated(AuthData(
        authToken: _authService.authToken,
        username: response.body['username'],
      ));
    } else {
      _authService.setNotAuthenticated();
    }
  }

  Future<ErrorOr<void>> register(Credentials credentials) async {
    final response = await post('/auth/register', {
      'username': credentials.username,
      'password': credentials.password,
    });
    if (response.statusCode == 200) {
      return ErrorOr.successful(true);
    }
    return ErrorOr.unsuccessful(response.body['message']);
  }

  Future<ErrorOr<AuthData>> login(Credentials credentials) async {
    final response = await post('/auth/login', {
      'username': credentials.username,
      'password': credentials.password,
    });
    if (response.statusCode != 200) {
      return ErrorOr.unsuccessful(response.body['message']);
    }
    return ErrorOr.successful(AuthData(
        authToken: response.body['token'], username: credentials.username));
  }

  Future<Map<String, dynamic>> fetchFigure(int id) async {
    return (await get('/figure/$id')).body;
  }

  Future<List<dynamic>> fetchFigures() async {
    return (await get('/figure')).body;
  }

  Future<int> createFigure(String name) async {
    return (await post('/figure', {"name": name, "code": ""})).body;
  }

  Future<TikzCompilationResult> compile(String code) async {
    final response = await post('/figure/compile', {'code': code});
    if (response.statusCode == 400) {
      return TikzCompilationResult.unsuccessful(response.body['errors']);
    }
    return TikzCompilationResult.successful(response.body['compiled']);
  }

  Future<RestApiResponse> get(String url) async {
    http.Response response;
    try {
      response = await _client.get(_apiAddress + url, headers: _headers);
    } catch (error) {
      print(error);
      return RestApiResponse.networkError();
    }
    if (response.statusCode == 401) {
      _authService.setNotAuthenticated();
    }
    return RestApiResponse(response);
  }

  Future<RestApiResponse> post(String url, Map<String, String> body) async {
    http.Response response;
    try {
      response =
          await _client.post(_apiAddress + url, headers: _headers, body: body);
    } catch (error) {
      print(error);
      return RestApiResponse.networkError();
    }
    if (response.statusCode == 401) {
      _authService.setNotAuthenticated();
    }
    return RestApiResponse(response);
  }

  Future<RestApiResponse> put(String url, Map<String, String> body) async {
    http.Response response;
    try {
      response =
          await _client.put(_apiAddress + url, headers: _headers, body: body);
    } catch (error) {
      return RestApiResponse.networkError();
    }
    if (response.statusCode == 401) {
      _authService.setNotAuthenticated();
    }
    return RestApiResponse(response);
  }

  Map<String, String> get _headers {
    final headers = Map<String, String>();
    if (_authService.hasAuthToken) {
      headers['x-access-token'] = _authService.authToken;
    }
    return headers;
  }
}

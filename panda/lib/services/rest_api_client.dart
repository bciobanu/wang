import 'dart:convert';

import 'package:angular/angular.dart' show Inject, Injectable, OpaqueToken;
import 'package:http/http.dart';

import 'package:panda/common/credentials.dart';
import 'package:panda/common/error_or.dart';
import 'package:panda/common/tikz_compilation_result.dart';
import 'auth_service.dart';

const apiAddress = OpaqueToken<String>('apiAddress');

@Injectable()
class RestApiClient {
  final Client _client;
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
        username: JsonDecoder().convert(response.body)['username'],
      ));
    } else {
      _authService.setNotAuthenticated();
    }
  }

  Future<ErrorOr<void>> register(Credentials credentials) async {
    Response response;
    try {
      response = await post('/auth/register', {
        'username': credentials.username,
        'password': credentials.password,
      });
    } catch (error) {
      return ErrorOr.unsuccessful("Network error.");
    }
    if (response.statusCode == 200) {
      return ErrorOr.successful(true);
    }
    return ErrorOr.unsuccessful(
        JsonDecoder().convert(response.body)['message']);
  }

  Future<ErrorOr<AuthData>> login(Credentials credentials) async {
    Response response;
    try {
      response = await post('/auth/login', {
        'username': credentials.username,
        'password': credentials.password,
      });
    } catch (error) {
      return ErrorOr.unsuccessful("Network error.");
    }
    if (response.statusCode != 200) {
      return ErrorOr.unsuccessful(
          JsonDecoder().convert(response.body)['message']);
    }
    return ErrorOr.successful(AuthData(
        authToken: JsonDecoder().convert(response.body)['token'],
        username: credentials.username));
  }

  Future<Map<String, dynamic>> fetchFigure(int id) async {
    return JsonDecoder().convert((await get('/figure/$id')).body);
  }

  Future<List<dynamic>> fetchFigures() async {
    return JsonDecoder().convert((await get('/figure')).body);
  }

  Future<int> createFigure(String name) async {
    return JsonDecoder().convert((await post('/figure', {
      "name": name,
      "code": "",
    }))
        .body);
  }

  Future<TikzCompilationResult> compile(String code) async {
    final response = await post('/figure/compile', {'code': code});
    final body = JsonDecoder().convert(response.body);
    if (response.statusCode == 400) {
      return TikzCompilationResult.unsuccessful(body['errors']);
    }
    return TikzCompilationResult.successful(body['compiled']);
  }

  Future<Response> get(String url) async {
    final response = await _client.get(_apiAddress + url, headers: _headers);
    if (response.statusCode == 401) {
      _authService.setNotAuthenticated();
    }
    return response;
  }

  Future<Response> post(String url, Map<String, String> body) async {
    final response =
        await _client.post(_apiAddress + url, headers: _headers, body: body);
    if (response.statusCode == 401) {
      _authService.setNotAuthenticated();
    }
    return response;
  }

  Future<Response> put(String url, Map<String, String> body) async {
    final response =
        await _client.put(_apiAddress + url, headers: _headers, body: body);
    if (response.statusCode == 401) {
      _authService.setNotAuthenticated();
    }
    return response;
  }

  Map<String, String> get _headers {
    final headers = Map<String, String>();
    if (_authService.hasAuthToken) {
      headers['x-access-token'] = _authService.authToken;
    }
    return headers;
  }
}

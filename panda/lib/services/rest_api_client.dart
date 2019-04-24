import 'dart:convert';

import 'package:angular/angular.dart' show Inject, Injectable, OpaqueToken;
import 'package:panda/common/credentials.dart';
import 'package:panda/common/error_or.dart';
import 'package:http/browser_client.dart';
import 'package:http/http.dart';

import 'auth_service.dart';

const apiServerAddress = OpaqueToken<String>('apiServerAddress');

@Injectable()
class RestApiClient {
  final String _apiServerAddress;
  final AuthService _authService;
  final BrowserClient _browserClient = BrowserClient();

  RestApiClient(
      @Inject(apiServerAddress) this._apiServerAddress, this._authService);

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
      response = await post('/auth/register', body: {
        'username': credentials.username,
        'password': credentials.password
      });
    } catch (error) {
      return ErrorOr.unsuccessful("Network error.");
    }
    if (response.statusCode == 200) {
      _authService.setAuthenticated(AuthData(
        authToken: JsonDecoder().convert(response.body)['authToken'],
        username: credentials.username,
      ));
      return ErrorOr.successful(true);
    }
    return ErrorOr.unsuccessful(
        JsonDecoder().convert(response.body)['message']);
  }

  Future<ErrorOr<AuthData>> login(Credentials credentials) async {
    Response response;
    try {
      response = await post('/auth/login', body: {
        'username': credentials.username,
        'password': credentials.password
      });
    } catch (error) {
      return ErrorOr<AuthData>.unsuccessful("Network error.");
    }
    if (response.statusCode == 200) {
      return ErrorOr<AuthData>.successful(AuthData(
          authToken: JsonDecoder().convert(response.body)['token'],
          username: credentials.username));
    }
    return ErrorOr<AuthData>.unsuccessful(
        JsonDecoder().convert(response.body)['message']);
  }

  Future<Response> get(url) async {
    final response = await _browserClient.get(_apiServerAddress + url,
        headers: _enhanceHeaders({}));
    if (response.statusCode == 401) {
      _authService.setNotAuthenticated();
    }
    return response;
  }

  Future<Response> head(url, {Map<String, String> headers}) async {
    final response = await _browserClient.head(_apiServerAddress + url,
        headers: _enhanceHeaders(headers));
    if (response.statusCode == 401) {
      _authService.setNotAuthenticated();
    }
    return response;
  }

  Future<Response> patch(url,
      {Map<String, String> headers, body, Encoding encoding}) async {
    final response = await _browserClient.patch(_apiServerAddress + url,
        headers: _enhanceHeaders(headers), body: body, encoding: encoding);
    if (response.statusCode == 401) {
      _authService.setNotAuthenticated();
    }
    return response;
  }

  Future<Response> post(url,
      {Map<String, String> headers, body, Encoding encoding}) async {
    final response = await _browserClient.post(_apiServerAddress + url,
        headers: _enhanceHeaders(headers), body: body, encoding: encoding);
    if (response.statusCode == 401) {
      _authService.setNotAuthenticated();
    }
    return response;
  }

  Future<Response> put(url,
      {Map<String, String> headers, body, Encoding encoding}) async {
    final response = await _browserClient.put(_apiServerAddress + url,
        headers: _enhanceHeaders(headers), body: body, encoding: encoding);
    if (response.statusCode == 401) {
      _authService.setNotAuthenticated();
    }
    return response;
  }

  Future<Response> delete(url, {Map<String, String> headers}) async {
    final response = await _browserClient.delete(_apiServerAddress + url,
        headers: _enhanceHeaders(headers));
    if (response.statusCode == 401) {
      _authService.setNotAuthenticated();
    }
    return response;
  }

  Map<String, String> _enhanceHeaders(Map<String, String> headers) {
    final enhancedHeaders = Map<String, String>();
    if (headers != null) {
      enhancedHeaders.addAll(headers);
    }
//    enhancedHeaders['Content-Type'] = 'application/json';
    if (_authService.hasAuthToken) {
      enhancedHeaders['x-access-token'] = _authService.authToken;
    }
    return enhancedHeaders;
  }
}

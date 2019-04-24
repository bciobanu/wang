import 'dart:convert';

import 'package:angular/angular.dart' show Inject, Injectable, OpaqueToken;
import 'package:quiver/core.dart' show Optional;
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
//    final getOwnUserResponse = await get('/own_user');
    await Future.delayed(const Duration(milliseconds: 200));
    _authService.setNotAuthenticated();
  }

  Future<Optional<String>> register(String username, String password) async {
    final response = await post('/auth/register',
        body: {'username': username, 'password': password});
    if (response.statusCode == 200) {
      _authService.setAuthenticated(
          authToken: JsonDecoder().convert(response.body)['authToken'],
          username: username);
      return Optional<String>.absent();
    }
    // TODO: Actually send an error message.
    return Optional<String>.of("Unknown error occured.");
  }

  Future<LoginResponse> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 200));
//    final response = await post('/auth/login', body: {
//      'username': username,
//      'password': password
//    });
//    if (response.statusCode == 200) {
//      return LoginResponse.successful(JsonDecoder().convert(response.body));
//    }
    // TODO: Actually send an error message.
    return LoginResponse.unsuccessful("Unknown error occured");
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
      enhancedHeaders['Authentication'] = 'Bearer ${_authService.authToken}';
    }
    return enhancedHeaders;
  }
}

class LoginResponse {
  final String error;

  final String authToken;
  final String username;

  LoginResponse.unsuccessful(this.error)
      : authToken = null,
        username = null;

  LoginResponse.successful(this.authToken, this.username) : error = null;

  bool get hasError => error?.isNotEmpty;
}

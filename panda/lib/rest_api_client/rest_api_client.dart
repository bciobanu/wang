import 'package:angular/angular.dart' show Injectable;
import 'package:http/http.dart' as http;

import 'package:panda/common/credentials.dart';
import 'package:panda/common/error_or.dart';
import 'package:panda/common/tikz_compilation_result.dart';
import 'package:panda/services/auth_service.dart';
import 'middleware.dart';
import 'rest_api_response.dart';

typedef _Fetch = Future<http.Response> Function(
    String url, Map<String, String> headers, Map<String, dynamic> body);

@Injectable()
class RestApiClient {
  final http.Client _client;
  final AuthService _authService;

  final String _apiAddress;
  final List<Middleware> _middlewares;

  RestApiClient(
      this._client, this._apiAddress, this._authService, this._middlewares);

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

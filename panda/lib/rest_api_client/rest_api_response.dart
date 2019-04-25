import 'dart:convert' show JsonDecoder;

import 'package:http/http.dart' show Response;

class RestApiResponseBuilder {
  Response httpResponse = null;

  int statusCode;
  dynamic body;

  RestApiResponseBuilder(this.httpResponse)
      : statusCode = httpResponse.statusCode,
        body = JsonDecoder().convert(httpResponse.body);

  RestApiResponseBuilder.networkError()
      : statusCode = -1,
        body = {'message': 'Network error.'};

  RestApiResponse toResponse() => RestApiResponse._(this.statusCode, this.body);
}

class RestApiResponse {
  final int statusCode;
  final dynamic body;

  RestApiResponse._(this.statusCode, this.body);
}

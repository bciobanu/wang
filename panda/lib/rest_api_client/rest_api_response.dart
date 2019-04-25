import 'package:http/http.dart';

class RestApiResponseBuilder {
  final Response httpResponse;

  int statusCode;
  dynamic body;

  RestApiResponseBuilder(this.httpResponse)
      : statusCode = httpResponse.statusCode,
        body = httpResponse.body;

  RestApiResponseBuilder.networkError()
      : httpResponse = null,
        statusCode = -1,
        body = {'message': 'Network error.'};

  RestApiResponse build() =>
      RestApiResponse._(this.httpResponse, this.statusCode, this.body);
}

class RestApiResponse {
  final Response httpResponse;
  final int statusCode;
  final dynamic body;

  RestApiResponse._(this.httpResponse, this.statusCode, this.body);
}

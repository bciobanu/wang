import 'package:http/http.dart';

class RestApiResponseBuilder {
  final Request httpRequest;
  final Response httpResponse;

  int statusCode;
  dynamic body;

  RestApiResponseBuilder(this.httpRequest, this.httpResponse)
      : statusCode = httpResponse.statusCode,
        body = httpResponse.body;

  RestApiResponseBuilder.networkError(this.httpRequest)
      : httpResponse = null,
        statusCode = -1,
        body = <String, dynamic>{'message': 'Network error.'};

  RestApiResponse build() =>
      RestApiResponse._(this.httpResponse, this.statusCode, this.body);
}

class RestApiResponse {
  final Response httpResponse;
  final int statusCode;
  final dynamic body;

  RestApiResponse._(this.httpResponse, this.statusCode, this.body);
}

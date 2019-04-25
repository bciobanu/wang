import 'dart:convert';

import 'package:panda/rest_api_client/middleware.dart';
import 'package:panda/rest_api_client/rest_api_response.dart';

class JsonResponseMiddleware extends Middleware {
  final _decoder = JsonDecoder();

  @override
  bool onResponse(RestApiResponseBuilder builder) {
    try {
      builder.body = _decoder.convert(builder.body);
    } on FormatException {
      builder.statusCode = 500;
      builder.body = <String, dynamic>{
        'message': 'Invalid server response.'
      };
    }
    return true;
  }
}

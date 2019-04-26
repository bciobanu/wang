import 'dart:convert';

import 'package:http/http.dart' as http;

class RestApiRequestBuilder {
  String method = 'GET';

  Uri url = Uri.parse('/');

  final headers = Map<String, String>();

  final Map<String, dynamic> body;

  RestApiRequestBuilder(this.body);

  http.Request build() {
    final request = http.Request(method, url);
    request.headers.addAll(headers);
    if (body != null) {
      request.headers['Content-Type'] = 'application/json; charset=utf-8';
      request.body = JsonEncoder().convert(body);
    }
    return request;
  }
}

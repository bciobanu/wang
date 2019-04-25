import 'dart:convert';

import 'package:http/http.dart' as http;

class RestApiRequestBuilder {
  String method = 'GET';

  Uri url = Uri.parse('/');

  final headers = Map<String, String>();

  final Map<String, dynamic> body;

  RestApiRequestBuilder(this.body);

  http.Request build() => http.Request(method, url)
    ..headers.addAll(headers)
    ..body = JsonEncoder().convert(body);
}

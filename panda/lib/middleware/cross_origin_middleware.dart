import 'package:panda/rest_api_client/middleware.dart';
import 'package:panda/rest_api_client/rest_api_request_builder.dart';

class CrossOriginMiddleware extends Middleware {
  final String _scheme;
  final String _host;
  final int _port;
  final String _pathPrefix;

  CrossOriginMiddleware(this._scheme, this._host, this._port, this._pathPrefix);

  @override
  void onRequest(RestApiRequestBuilder requestBuilder) {
    requestBuilder.url = requestBuilder.url.replace(
      scheme: _scheme,
      host: _host,
      port: _port,
      path: (_pathPrefix ?? '') + requestBuilder.url.path,
    );
  }
}

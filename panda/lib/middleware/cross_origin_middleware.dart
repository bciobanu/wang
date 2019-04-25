import 'package:panda/common/origin.dart';
import 'package:panda/rest_api_client/middleware.dart';
import 'package:panda/rest_api_client/rest_api_request_builder.dart';

class CrossOriginMiddleware extends Middleware {
  final Origin _origin;

  CrossOriginMiddleware(this._origin);

  @override
  void onRequest(RestApiRequestBuilder requestBuilder) {
    requestBuilder.url = requestBuilder.url.replace(
      scheme: _origin.scheme,
      host: _origin.host,
      port: _origin.port,
      path: (_origin.pathPrefix ?? '') + requestBuilder.url.path,
    );
  }
}

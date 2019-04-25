import 'package:angular/angular.dart';
import 'package:http/http.dart' as http;

import 'package:panda/common/origin.dart';
import 'package:panda/middleware/auth_middleware.dart';
import 'package:panda/middleware/cross_origin_middleware.dart';
import 'package:panda/middleware/json_response_middleware.dart';
import 'package:panda/rest_api_client/rest_api_client.dart';

const apiOrigin = OpaqueToken<Origin>('apiOrigin');

RestApiClient restApiClientFactory(
        http.Client httpClient, @Inject(apiOrigin) Origin apiOrigin) =>
    RestApiClient(httpClient, [
      CrossOriginMiddleware(apiOrigin),
      JsonResponseMiddleware(),
      AuthMiddleware(),
    ]);

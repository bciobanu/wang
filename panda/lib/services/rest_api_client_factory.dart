import 'package:angular/angular.dart';
import 'package:http/http.dart' as http;

import 'package:panda/middleware/auth_middleware.dart';
import 'package:panda/middleware/cross_origin_middleware.dart';
import 'package:panda/middleware/json_response_middleware.dart';
import 'package:panda/rest_api_client/rest_api_client.dart';

const apiOriginScheme = OpaqueToken<String>('apiOrigin.scheme');
const apiOriginHost = OpaqueToken<String>('apiOrigin.host');
const apiOriginPort = OpaqueToken<int>('apiOrigin.port');
const apiOriginPathPrefix = OpaqueToken<String>('apiOrigin.pathPrefix');

RestApiClient restApiClientFactory(
        http.Client httpClient,
        @Inject(apiOriginScheme) String apiScheme,
        @Inject(apiOriginHost) String apiHost,
        @Inject(apiOriginPort) int apiPort,
        @Inject(apiOriginPathPrefix) String apiPathPrefix) =>
    RestApiClient(httpClient, [
      CrossOriginMiddleware(apiScheme, apiHost, apiPort, apiPathPrefix),
      JsonResponseMiddleware(),
      AuthMiddleware(),
    ]);

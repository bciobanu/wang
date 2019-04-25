import 'package:angular/angular.dart';
import 'package:http/http.dart';

import 'package:panda/rest_api_client/rest_api_client.dart';
import 'auth_middleware.dart';

const apiAddress = OpaqueToken<String>('apiAddress');

RestApiClient restApiClientFactory(
        Client httpClient, @Inject(apiAddress) String apiAddress) =>
    RestApiClient(httpClient, apiAddress, [
      AuthMiddleware(),
    ]);

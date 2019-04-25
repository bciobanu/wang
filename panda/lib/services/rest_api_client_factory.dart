import 'package:angular/angular.dart';
import 'package:http/http.dart';

import 'package:panda/rest_api_client/rest_api_client.dart';
import 'package:panda/services/auth_service.dart';

const apiAddress = OpaqueToken<String>('apiAddress');

RestApiClient restApiClientFactory(Client httpClient,
        @Inject(apiAddress) apiAddress, AuthService auth) =>
    RestApiClient(httpClient, apiAddress, auth, [
      auth.getMiddleware(),
    ]);
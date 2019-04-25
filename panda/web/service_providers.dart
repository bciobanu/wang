import 'package:angular/angular.dart';
import 'package:http/browser_client.dart';
import 'package:http/http.dart';

import 'package:panda/rest_api_client/rest_api_client.dart';
import 'package:panda/services/auth_service.dart';
import 'package:panda/services/figures_service.dart';
import 'package:panda/services/rest_api_client_factory.dart';

const serviceProviders = Module(provide: [
  ClassProvider(Client, useClass: BrowserClient),
  FactoryProvider(RestApiClient, restApiClientFactory,
      deps: [Client, apiOrigin]),
  ClassProvider(AuthService),
  ClassProvider(FiguresService),
]);

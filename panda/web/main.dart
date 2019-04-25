import 'package:angular/angular.dart';
import 'package:http/http.dart';
import 'package:http/browser_client.dart';

import 'package:panda/rest_api_client/rest_api_client.dart';
import 'package:panda/services/auth_service.dart';
import 'package:panda/services/figures_service.dart';
import 'package:panda/services/rest_api_client_factory.dart';

import 'package:panda/components/panda_app/panda_app.template.dart'
    show PandaAppComponentNgFactory;
import 'main.template.dart' show injector$Injector;

@GenerateInjector([
  ClassProvider(Client, useClass: BrowserClient),
  ValueProvider.forToken(apiOriginScheme, 'http'),
  ValueProvider.forToken(apiOriginHost, 'localhost'),
  ValueProvider.forToken(apiOriginPort, 3000),
  ValueProvider.forToken(apiOriginPathPrefix, '/api'),
  FactoryProvider(
    RestApiClient,
    restApiClientFactory,
    deps: [
      Client,
      apiOriginScheme,
      apiOriginHost,
      apiOriginPort,
      apiOriginPathPrefix,
    ],
  ),
  ClassProvider(AuthService),
  ClassProvider(FiguresService),
])
final InjectorFactory injector = injector$Injector;

void main() {
  runApp(PandaAppComponentNgFactory, createInjector: injector);
}

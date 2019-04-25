import 'package:angular/angular.dart';
import 'package:panda/services/rest_api_client_factory.dart';

import 'service_providers.dart';

import 'package:panda/components/panda_app/panda_app.template.dart';
import 'main_prod.template.dart';

const apiOriginProd = Module(provide: <Provider>[
  ValueProvider.forToken(apiOriginScheme, 'https'),
  ValueProvider.forToken(apiOriginHost, 'wang.com'),
  ValueProvider.forToken(apiOriginPort, 443),
  ValueProvider.forToken(apiOriginPathPrefix, '/api'),
]);

@GenerateInjector(<Module>[apiOriginProd, serviceProviders])
final InjectorFactory injector = injector$Injector;

void main() => runApp(PandaAppComponentNgFactory, createInjector: injector);

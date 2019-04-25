import 'package:angular/angular.dart';
import 'package:panda/services/rest_api_client_factory.dart';

import 'service_providers.dart';

import 'package:panda/components/panda_app/panda_app.template.dart';
import 'main_dev.template.dart';

const apiOriginDev = Module(provide: <Provider>[
  ValueProvider.forToken(apiOriginScheme, 'http'),
  ValueProvider.forToken(apiOriginHost, 'localhost'),
  ValueProvider.forToken(apiOriginPort, 3000),
  ValueProvider.forToken(apiOriginPathPrefix, '/api'),
]);

@GenerateInjector(<Module>[apiOriginDev, serviceProviders])
final InjectorFactory injector = injector$Injector;

void main() => runApp(PandaAppComponentNgFactory, createInjector: injector);

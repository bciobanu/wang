import 'package:angular/angular.dart';

import 'package:panda/common/origin.dart';
import 'package:panda/services/rest_api_client_factory.dart';

import 'service_providers.dart';

import 'package:panda/components/panda_app/panda_app.template.dart';
import 'main_dev.template.dart';

@GenerateInjector([
  ValueProvider.forToken(
      apiOrigin,
      Origin(
        scheme: 'http',
        host: 'localhost',
        port: 3000,
        pathPrefix: '/api',
      )),
  serviceProviders,
])
final InjectorFactory injector = injector$Injector;

void main() => runApp(PandaAppComponentNgFactory, createInjector: injector);

import 'package:angular/angular.dart';

import 'package:panda/common/origin.dart';
import 'package:panda/services/rest_api_client_factory.dart';

import 'service_providers.dart';

import 'package:panda/components/panda_app/panda_app.template.dart';
import 'main_prod.template.dart';

@GenerateInjector([
  ValueProvider.forToken(
      apiOrigin,
      Origin(
        scheme: 'https',
        host: 'wang.com',
        port: 443,
        pathPrefix: '/api',
      )),
  serviceProviders,
])
final InjectorFactory injector = injector$Injector;

void main() => runApp(PandaAppComponentNgFactory, createInjector: injector);

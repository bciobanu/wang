import 'package:angular/angular.dart';

import 'package:panda/services/auth_service.dart';

import 'package:panda/components/panda_app/panda_app.template.dart'
    show PandaAppComponentNgFactory;
import 'package:panda/services/rest_api_client.dart';
import 'main.template.dart' show injector$Injector;

@GenerateInjector([
  ClassProvider(AuthService),
  ValueProvider.forToken(apiServerAddress, 'http://localhost:3000/api'),
  ClassProvider(RestApiClient),
])
final InjectorFactory injector = injector$Injector;

void main() {
  runApp(PandaAppComponentNgFactory, createInjector: injector);
}

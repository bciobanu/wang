import 'dart:convert';

import 'package:angular/angular.dart';
import 'package:panda/common/tikz_compilation_result.dart';
import 'package:panda/services/rest_api_client.dart';

@Injectable()
class CompileService {
  final RestApiClient _apiClient;

  CompileService(this._apiClient);

  Future<TikzCompilationResult> compile(String code) async {
    final response = await _apiClient.post('/figure/compile', body: {
      'code': code
    });
    final body = JsonDecoder().convert(response.body);
    if (response.statusCode == 400) {
      return TikzCompilationResult.unsuccessful(body['errors']);
    }
    return TikzCompilationResult.successful(body['compiled']);
  }
}

import 'package:panda/rest_api_client/rest_api_client.dart';

import 'tikz_compilation_result.dart';

class Figure {
  final RestApiClient _apiClient;

  final int id;
  String _name;
  String _code = null;

  String _dirtyName = null;
  String _dirtyCode = null;

  bool _committingName = false;
  bool _committingCode = false;
  bool _compiling = false;

  TikzCompilationResult _compilationResult = null;

  Figure(this._apiClient, this.id, this._name, [this._code]);

  String get name => _name;

  bool get hasDirtyName => _dirtyName != null && _dirtyName != _name;

  String get dirtyName => _dirtyName ?? _name;

  void setDirtyName(String dirtyName) => _dirtyName = dirtyName;

  void clearDirtyName() => _dirtyName = null;

  bool get committingName => _committingName;

  Future<void> commitName() async {
    if (!hasDirtyName) {
      return;
    }
    _committingName = true;
    final response = await _apiClient.put('/figure/$id', {'name': _dirtyName});
    if (response.statusCode == 201) {
      _name = _dirtyName;
    }
    _dirtyName = null;
    _committingName = false;
  }

  bool get hasCode => _code != null;

  String get code => _code;

  Future<void> reloadCode() async =>
      _code = (await _apiClient.get('/figure/$id')).body['code'];

  bool get hasDirtyCode => _dirtyCode != null && _dirtyCode != _code;

  String get dirtyCode => _dirtyCode ?? _code;

  void setDirtyCode(String dirtyCode) => _dirtyCode = dirtyCode;

  void clearDirtyCode() => _dirtyCode = null;

  bool get committingCode => _committingCode;

  void commitCode() async {
    if (!hasDirtyCode) {
      return;
    }
    _committingCode = true;
    final response = await _apiClient.put('/figure/$id', {'code': _dirtyCode});
    if (response.statusCode == 201) {
      _code = _dirtyCode;
    }
    _dirtyCode = null;
    _committingCode = false;
  }

  bool get hasCompilationResult => _compilationResult != null;

  TikzCompilationResult get compilationResult => _compilationResult;

  bool get isCompiling => _compiling;

  void compile() async {
    _compiling = true;
    _compilationResult = await _compile();
    _compiling = false;
  }

  Future<TikzCompilationResult> _compile() async {
    final response = await _apiClient.post('/figure/compile', {
      'code': dirtyCode,
    });
    if (response.statusCode == 400) {
      return TikzCompilationResult.unsuccessful(response.body['errors']);
    }
    return TikzCompilationResult.successful(response.body['compiled']);
  }
}

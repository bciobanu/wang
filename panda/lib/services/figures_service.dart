import 'dart:math' show max;

import 'package:angular/angular.dart';
import 'package:panda/common/tikz_compilation_result.dart';
import 'package:panda/services/rest_api_client.dart';

class Figure {
  RestApiClient _apiClient;

  final int id;
  String _name;
  String _code = null;

  String _dirtyName = null;
  String _dirtyCode = null;

  bool _committingName = false;
  bool _committingCode = false;
  bool _compiling = false;

  TikzCompilationResult _compilationResult = null;

  Figure._(this._apiClient, this.id, this._name, [this._code]);

  String get name => _name;

  bool get hasDirtyName => _dirtyName != null && _dirtyName != _name;

  String get dirtyName => _dirtyName ?? _name;

  void setDirtyName(String dirtyName) => _dirtyName = dirtyName;

  void clearDirtyName() => _dirtyName = null;

  bool get committingName => _committingName;

  void commitName() async {
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

  void reloadCode() async => _code = (await _apiClient.fetchFigure(id))['code'];

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
    _compilationResult = await _apiClient.compile(dirtyCode);
    _compiling = false;
  }
}

@Injectable()
class FiguresService {
  final RestApiClient _apiClient;

  final _figures = Map<int, Figure>();

  FiguresService(this._apiClient);

  Iterable<Figure> get figures => _figures.values;

  Figure getFigure(int id) => _figures[id];

  void reloadFigures() async {
    final response = await _apiClient.fetchFigures();
    _figures.clear();
    for (final figureDesc in response) {
      _figures[figureDesc['id']] =
          Figure._(_apiClient, figureDesc['id'], figureDesc['name']);
    }
  }

  void createNewFigure() async {
    final name = _getNextFigureName();
    final figureId = await _apiClient.createFigure(name);
    _figures[figureId] = Figure._(_apiClient, figureId, name, "");
  }

  String _getNextFigureName() {
    int lastUsedIndex = 0;
    for (final figure in _figures.values) {
      final match = RegExp(r"Unnamed figure (\d+)").firstMatch(figure.name);
      if (match != null) {
        lastUsedIndex = max(lastUsedIndex, int.parse(match.group(1)));
      }
    }
    return "Unnamed figure ${lastUsedIndex + 1}";
  }
}

import 'dart:math' show max;

import 'package:angular/angular.dart';
import 'package:panda/common/tikz_compilation_result.dart';
import 'package:panda/services/compile_service.dart';
import 'package:panda/services/rest_api_client.dart';

class Figure {
  final int id;
  String _name;
  String _code = null;

  String _dirtyName = null;
  String _dirtyCode = null;

  TikzCompilationResult _compilationResult = null;

  Figure(this.id, this._name, [this._code]);

  String get name => _name;

  bool get hasCode => _code != null;

  String get code => _code;

  bool get hasDirtyName => _dirtyName != null && _dirtyName != _name;

  String get dirtyName => _dirtyName ?? _name;

  bool get hasDirtyCode => _dirtyCode != null && _dirtyCode != _code;

  String get dirtyCode => _dirtyCode ?? _code;

  bool get hasCompilationResult => _compilationResult != null;

  TikzCompilationResult get compilationResult => _compilationResult;
}

@Injectable()
class FiguresService {
  final CompileService _compileService;
  final RestApiClient _apiClient;

  final _figures = Map<int, Figure>();

  FiguresService(this._compileService, this._apiClient);

  Iterable<Figure> get figures => _figures.values;

  bool isFigureLoaded(int id) =>
      _figures.containsKey(id) && _figures[id].hasCode;

  Figure getFigure(int id) => _figures[id];

  void reloadFigures() async {
    final response = await _apiClient.fetchFigures();
    _figures.clear();
    for (final figureDesc in response) {
      _figures[figureDesc['id']] = Figure(figureDesc['id'], figureDesc['name']);
    }
  }

  void loadFigureCode(int id) async {
    final response = await _apiClient.fetchFigure(id);
    _figures.putIfAbsent(id, () => Figure(response['id'], response['name']));
    _figures[id]._code = response['code'];
  }

  void createNewFigure() async {
    final name = _getNextFigureName();
    final figureId = await _apiClient.createFigure(name);
    _figures[figureId] = Figure(figureId, name, "");
  }

  void setFigureDirtyName(int id, String dirtyName) =>
      _figures[id]._dirtyName = dirtyName;

  void clearFigureDirtyName(int id) => _figures[id]._dirtyName = null;

  void commitFigureName(int id) async {
    if (!_figures[id].hasDirtyName) {
      return;
    }
    final response = await _apiClient
        .put('/figure/$id', body: {'name': _figures[id]._dirtyName});
    if (response.statusCode == 201) {
      _figures[id]._name = _figures[id]._dirtyName;
    }
    _figures[id]._dirtyName = null;
  }

  void setFigureDirtyCode(int id, String dirtyCode) =>
      _figures[id]._dirtyCode = dirtyCode;

  void clearFigureDirtyCode(int id) => _figures[id]._dirtyCode = null;

  void commitFigureCode(int id) async {
    if (!_figures[id].hasDirtyCode) {
      return;
    }
    final response = await _apiClient
        .put('/figure/$id', body: {'code': _figures[id]._dirtyCode});
    if (response.statusCode == 201) {
      _figures[id]._code = _figures[id]._dirtyCode;
    }
    _figures[id]._dirtyCode = null;
  }

  void compileFigure(int id) async {
    _figures[id]._compilationResult =
        await _compileService.compile(_figures[id].dirtyCode);
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

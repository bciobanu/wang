import 'dart:math' show max;

import 'package:angular/angular.dart';
import 'package:panda/services/rest_api_client.dart';

class Figure {
  final int id;
  String _name;
  String _code = null;

  Figure(this.id, this._name, [this._code]);

  bool get hasCode => _code != null;
  String get code => _code;
  String get name => _name;
}

@Injectable()
class FiguresService {
  final RestApiClient _apiClient;

  final _figures = Map<int, Figure>();

  FiguresService(this._apiClient);

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

  void updateFigureName(int id, String name) async {
    final response = await _apiClient.put('/figure/$id', body: {
      'name': name
    });
    if (response.statusCode == 201) {
      _figures[id]._name = name;
    }
  }

  void updateFigureCode(int id, String code) async {
    final response = await _apiClient.put('/figure/$id', body: {
      'code': code
    });
    if (response.statusCode == 201) {
      _figures[id]._code = code;
    }
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

import 'dart:math' show max;

import 'package:panda/common/figure.dart';
import 'package:panda/rest_api_client/rest_api_client.dart';

class FiguresService {
  final RestApiClient _apiClient;

  final _figures = Map<int, Figure>();

  FiguresService(this._apiClient);

  Iterable<Figure> get figures => _figures.values;

  Figure getFigure(int id) => _figures[id];

  void reloadFigures() async {
    final response = await _fetchFigures();
    _figures.clear();
    for (final figureDesc in response) {
      _figures[figureDesc['id']] =
          Figure(_apiClient, figureDesc['id'], figureDesc['name']);
    }
  }

  void createNewFigure() async {
    final name = _getNextFigureName();
    final figureId = await _createFigure(name);
    _figures[figureId] = Figure(_apiClient, figureId, name, "");
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

  Future<List<dynamic>> _fetchFigures() async {
    return (await _apiClient.get('/figure')).body;
  }

  Future<int> _createFigure(String name) async {
    return (await _apiClient.post('/figure', {"name": name, "code": ""})).body;
  }
}

import 'package:angular/angular.dart';
import 'package:panda/services/rest_api_client.dart';

class Figure {
  final int id;
  final String name;
  String code = null;

  Figure(this.id, this.name);

  bool get hasCode => code != null;
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
    _figures[id].code = response['code'];
  }
}

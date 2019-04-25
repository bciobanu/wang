import 'package:angular/angular.dart';
import 'package:angular_components/material_button/material_fab.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_list/material_list.dart';
import 'package:angular_components/material_list/material_list_item.dart';
import 'package:angular_components/material_spinner/material_spinner.dart';

import 'package:panda/common/figure.dart';
import 'package:panda/components/figure_editor/figure_editor.dart';
import 'package:panda/services/figures_service.dart';

@Component(
  selector: 'wang-page',
  templateUrl: 'wang_page.html',
  styleUrls: ['wang_page.css'],
  directives: [
    MaterialSpinnerComponent,
    MaterialListComponent,
    MaterialListItemComponent,
    MaterialIconComponent,
    MaterialFabComponent,
    FigureEditorComponent,
    coreDirectives,
  ],
)
class WangPageComponent implements OnInit {
  final FiguresService _figuresService;

  bool loadedFigures = false;
  int highlightedFigureId = null;

  WangPageComponent(this._figuresService);

  Iterable<Figure> get figures => _figuresService.figures;

  void createFigure() async {
    await _figuresService.createNewFigure();
  }

  void setHighlightedFigureId(int figureId) {
    highlightedFigureId = figureId;
  }

  bool get hasHighlightedFigureId => highlightedFigureId != null;

  Iterable<Figure> get highlightedFigures =>
      figures.where((figure) => figure.id == highlightedFigureId);

  @override
  void ngOnInit() async {
    await _figuresService.reloadFigures();
    loadedFigures = true;
  }
}

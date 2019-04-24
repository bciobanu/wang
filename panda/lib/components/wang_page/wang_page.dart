import 'package:angular/angular.dart';
import 'package:angular_components/material_list/material_list.dart';
import 'package:angular_components/material_list/material_list_item.dart';
import 'package:angular_components/material_spinner/material_spinner.dart';
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
    FigureEditorComponent,
    coreDirectives,
  ],
)
class WangPageComponent implements OnInit {
  final FiguresService _figuresService;

  bool loadedFigures = false;
  Iterable<Figure> figures;
  int highlightedFigureId = null;

  WangPageComponent(this._figuresService);

  @override
  void ngOnInit() async {
    await _figuresService.reloadFigures();
    figures = _figuresService.figures;
    loadedFigures = true;
  }
}

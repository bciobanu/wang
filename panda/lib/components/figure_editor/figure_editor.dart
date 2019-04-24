import 'package:angular/angular.dart';
import 'package:angular_components/material_spinner/material_spinner.dart';
import 'package:panda/services/figures_service.dart';

@Component(
  selector: 'figure-editor',
  templateUrl: 'figure_editor.html',
  styleUrls: ['figure_editor.css'],
  directives: [
    coreDirectives,
    MaterialSpinnerComponent,
  ],
)
class FigureEditorComponent implements OnChanges {
  FiguresService _figuresService;

  @Input()
  int figureId = null;

  bool isFigureLoaded = false;

  FigureEditorComponent(this._figuresService);

  bool get hasHighlightedFigure => figureId != null;

  Figure get figure => _figuresService.getFigure(figureId);

  @override
  void ngOnChanges(Map<String, SimpleChange> changes) async {
    isFigureLoaded = false;
    if (hasHighlightedFigure && !_figuresService.isFigureLoaded(figureId)) {
      await _figuresService.loadFigureCode(figureId);
    }
    isFigureLoaded = true;
  }
}

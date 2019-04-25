import 'package:angular/angular.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_button/material_fab.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_spinner/material_spinner.dart';
import 'package:panda/services/figures_service.dart';

@Component(
  selector: 'figure-editor',
  templateUrl: 'figure_editor.html',
  styleUrls: ['figure_editor.css'],
  directives: [
    coreDirectives,
    MaterialSpinnerComponent,
    MaterialFabComponent,
    MaterialButtonComponent,
    MaterialIconComponent,
  ],
)
class FigureEditorComponent implements OnChanges {
  final FiguresService _figuresService;

  @Input()
  int figureId = null;

  bool isFigureLoaded = false;

  bool committingFigureNameEdit = false;
  bool editingFigureName = false;
  int figureIdDirtyName = null;
  String figureNameDirty = null;

  bool committingFigureCode = false;

  /// A Map from figureId to the code that should be displayed in the editor for
  /// that figure.
  final _dirtyCode = Map<int, String>();

  FigureEditorComponent(this._figuresService);

  bool get hasHighlightedFigure => figureId != null;

  Figure get figure => _figuresService.getFigure(figureId);

  bool get isCurrentFigureDirty => isDirty(figureId);

  bool isDirty(int figureId) =>
      _dirtyCode.containsKey(figureId) &&
      _figuresService.getFigure(figureId).code != _dirtyCode[figureId];

  String get currentFigureDirtyCode => _dirtyCode[figureId];

  void setEditingFigureName() {
    figureNameDirty = figure.name;
    editingFigureName = true;
    figureIdDirtyName = figureId;
  }

  void cancelEditingFigureName() {
    editingFigureName = false;
    figureNameDirty = null;
    figureIdDirtyName = null;
  }

  void commitFigureName() async {
    committingFigureNameEdit = true;
    await _figuresService.updateFigureName(figureIdDirtyName, figureNameDirty);
    committingFigureNameEdit = false;
    cancelEditingFigureName();
  }

  void commitFigureCode() async {
    committingFigureCode = true;
    await _figuresService.updateFigureCode(figureId, currentFigureDirtyCode);
    committingFigureCode = false;
  }

  void setCurrentFigureDirtyCode(String dirtyCode) {
    _dirtyCode[figureId] = dirtyCode;
  }

  @override
  void ngOnChanges(Map<String, SimpleChange> changes) async {
    if (editingFigureName && figureIdDirtyName != figureId) {
      cancelEditingFigureName();
    }
    isFigureLoaded = false;
    if (hasHighlightedFigure && !_figuresService.isFigureLoaded(figureId)) {
      int loadingFigureId = figureId;
      await _figuresService.loadFigureCode(loadingFigureId);
      _dirtyCode[loadingFigureId] =
          _figuresService.getFigure(loadingFigureId).code;
    }
    isFigureLoaded = true;
  }
}

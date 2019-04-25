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
class FigureEditorComponent implements OnInit {
  final FiguresService _figuresService;

  @Input()
  int figureId;

  bool isFigureLoaded = false;

  bool committingFigureNameEdit = false;
  bool editingFigureName = false;

  bool committingFigureCode = false;
  bool compilingFigure = false;

  FigureEditorComponent(this._figuresService);

  Figure get figure => _figuresService.getFigure(figureId);

  void setEditingFigureName() => editingFigureName = true;

  void cancelEditingFigureName() => editingFigureName = false;

  void commitFigureName() async {
    committingFigureNameEdit = true;
    await _figuresService.commitFigureName(figureId);
    committingFigureNameEdit = false;
    cancelEditingFigureName();
  }

  void commitFigureCode() async {
    committingFigureCode = true;
    await _figuresService.commitFigureCode(figureId);
    committingFigureCode = false;
  }

  void compileFigure() async {
    compilingFigure = true;
    await _figuresService.compileFigure(figureId);
    compilingFigure = false;
  }

  void setFigureDirtyCode(String dirtyCode) =>
      _figuresService.setFigureDirtyCode(figureId, dirtyCode);

  void setFigureDirtyName(String dirtyName) =>
      _figuresService.setFigureDirtyName(figureId, dirtyName);

  @override
  void ngOnInit() async {
    cancelEditingFigureName();
    isFigureLoaded = false;
    if (!_figuresService.isFigureLoaded(figureId)) {
      await _figuresService.loadFigureCode(figureId);
    }
    isFigureLoaded = true;
  }
}

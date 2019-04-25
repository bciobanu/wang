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
  bool editingFigureName = false;

  FigureEditorComponent(this._figuresService);

  Figure get figure => _figuresService.getFigure(figureId);

  void setEditingFigureName() => editingFigureName = true;

  void cancelEditingFigureName() => editingFigureName = false;

  void commitFigureName() async {
    await figure.commitName();
    cancelEditingFigureName();
  }

  void commitFigureCode() async {
    await figure.commitCode();
  }

  void compileFigure() async {
    await figure.compile();
  }

  void setFigureDirtyCode(String dirtyCode) => figure.setDirtyCode(dirtyCode);

  void setFigureDirtyName(String dirtyName) => figure.setDirtyName(dirtyName);

  @override
  void ngOnInit() async {
    await figure.reloadCode();
    isFigureLoaded = true;
  }
}

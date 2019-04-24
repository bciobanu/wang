import 'package:angular/angular.dart';
import 'package:angular_components/material_spinner/material_spinner.dart';
import 'package:panda/components/figure_editor/figure_editor.dart';
import 'package:panda/services/auth_service.dart';
import 'package:panda/services/figures_service.dart';

@Component(
  selector: 'wang-page',
  templateUrl: 'wang_page.html',
  styleUrls: ['wang_page.css'],
  directives: [
    MaterialSpinnerComponent,
    FigureEditorComponent,
    coreDirectives,
  ],
)
class WangPageComponent implements OnInit {
  final AuthService _authService;
  final FiguresService _figuresService;

  bool loadedFigures = false;
  Iterable<Figure> figures;
  int highlightedFigureId = null;

  WangPageComponent(this._authService, this._figuresService);

  String get username => _authService.ownUsername;

  @override
  void ngOnInit() async {
    await _figuresService.reloadFigures();
    figures = _figuresService.figures;
    loadedFigures = true;
  }
}

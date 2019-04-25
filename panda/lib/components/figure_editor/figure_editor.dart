import 'package:angular/angular.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_spinner/material_spinner.dart';

import 'package:panda/common/figure.dart';
import 'name_editor.dart';

@Component(
  selector: 'figure-editor',
  templateUrl: 'figure_editor.html',
  styleUrls: ['figure_editor.css'],
  directives: [
    coreDirectives,
    MaterialSpinnerComponent,
    MaterialButtonComponent,
    MaterialIconComponent,
    NameEditorComponent,
  ],
)
class FigureEditorComponent implements OnInit {
  @Input()
  Figure figure;

  bool loaded = false;

  void commit() async => await figure.commitCode();

  void compile() async => await figure.compile();

  void setDirtyCode(String dirtyCode) => figure.setDirtyCode(dirtyCode);

  @override
  void ngOnInit() async => await figure.reloadCode().then((_) => loaded = true);
}

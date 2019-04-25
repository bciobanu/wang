import 'package:angular/angular.dart';
import 'package:angular_components/material_button/material_fab.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_spinner/material_spinner.dart';

import 'package:panda/common/figure.dart';

@Component(
  selector: 'name-editor',
  templateUrl: 'name_editor.html',
  styleUrls: ['name_editor.css'],
  directives: [
    coreDirectives,
    MaterialSpinnerComponent,
    MaterialFabComponent,
    MaterialIconComponent,
  ],
)
class NameEditorComponent {
  @Input()
  Figure figure;

  bool editing = false;

  void setEditing() => editing = true;

  void cancelEditing() => editing = false;

  void setDirtyName(String dirtyName) => figure.setDirtyName(dirtyName);

  void commit() async => await figure.commitName().then((_) => editing = false);
}

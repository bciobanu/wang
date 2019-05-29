import 'dart:async';

import 'package:angular/angular.dart';

@Component(
  selector: 'text-editor',
  templateUrl: 'text_editor.html',
  styleUrls: ['text_editor.css'],
)
class TextEditorComponent {
  @Input()
  String value;

  @Output()
  Stream<String> get changes => _changesController.stream;

  final _changesController = StreamController<String>();

  void onChange(String newContent) => _changesController.add(newContent);
}
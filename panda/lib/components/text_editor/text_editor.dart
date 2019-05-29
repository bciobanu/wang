import 'dart:async';
import 'dart:html' show ScriptElement, document;
import 'dart:js' show context;

import 'package:angular/angular.dart';
import 'package:angular_components/material_spinner/material_spinner.dart';

@Component(
  selector: 'text-editor',
  templateUrl: 'text_editor.html',
  styleUrls: ['text_editor.css'],
  directives: [coreDirectives, MaterialSpinnerComponent],
)
class TextEditorComponent implements OnInit {
  static _AceLoadState _aceLoadState = _AceLoadState.notLoaded;
  static Future<void> _aceLoadFuture;

  static Future<void> _loadAce() async {
    if (_aceLoadState == _AceLoadState.notLoaded) {
      _aceLoadState = _AceLoadState.loading;

      final aceLoadCompleter = Completer();
      _aceLoadFuture = aceLoadCompleter.future;

      final scriptTag = ScriptElement();
      scriptTag.src = '/ext/ace.js';
      document.head.append(scriptTag);

      Timer.periodic(const Duration(milliseconds: 10), (Timer t) {
        print(context["ace"]);
        if (context["ace"] != null) {
          t.cancel();
          _aceLoadState = _AceLoadState.loaded;
          aceLoadCompleter.complete();
        }
      });
    }

    return _aceLoadFuture;
  }

  @Input()
  String value;

  @Output()
  Stream<String> get changes => _changesController.stream;

  bool loaded = false;

  final _changesController = StreamController<String>();

  void onChange(String newContent) => _changesController.add(newContent);

  @override
  void ngOnInit() async {
    await _loadAce();
    loaded = true;
  }
}

enum _AceLoadState {
  notLoaded,
  loading,
  loaded,
}

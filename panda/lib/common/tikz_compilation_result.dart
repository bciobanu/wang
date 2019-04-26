class TikzCompilationError {
  final int code;
  final String description;

  TikzCompilationError(this.code, this.description);
}

class TikzCompilationResult {
  final String tikzCode;
  final List<TikzCompilationError> errors;

  TikzCompilationResult.successful(this.tikzCode) : this.errors = [];

  TikzCompilationResult.unsuccessful(List<dynamic> errors)
      : this.errors = errors.map((e) => TikzCompilationError(
              e['code'],
              e['description'],
            )).toList(growable: false),
        this.tikzCode = null;

  bool get isSuccessful => errors.isEmpty;
}

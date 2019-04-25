class TikzCompilationError {
  final int code;
  final String codeName;
  final String description;

  TikzCompilationError(this.code, this.codeName, this.description);
}

class TikzCompilationResult {
  final String tikzCode;
  final List<TikzCompilationError> errors;

  TikzCompilationResult.successful(this.tikzCode) : this.errors = null;

  TikzCompilationResult.unsuccessful(List<dynamic> errors)
      : this.errors = [],
        this.tikzCode = null {
    for (final error in errors) {
      this.errors.add(TikzCompilationError(
            error['code']['number'],
            error['code']['name'],
            error['description'],
          ));
    }
  }

  bool get isSuccessful => errors == null;
}

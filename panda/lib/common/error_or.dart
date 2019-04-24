class ErrorOr<T> {
  final String error;
  final T value;

  ErrorOr.successful(this.value) : error = null;

  ErrorOr.unsuccessful(this.error) : value = null;

  bool get hasError => error != null;
}

/// A tiny "either it worked or it didn't" wrapper.
///
/// The logic layer never throws for expected outcomes (wrong OTP, expired
/// session). It returns a [Result] so the caller is forced to handle both cases.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  /// Value when successful, otherwise null.
  T? get valueOrNull => this is Success<T> ? (this as Success<T>).value : null;

  /// Failure when unsuccessful, otherwise null.
  AppFailure? get failureOrNull =>
      this is Failure<T> ? (this as Failure<T>).failure : null;

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(AppFailure failure) onFailure,
  }) {
    final self = this;
    if (self is Success<T>) return onSuccess(self.value);
    return onFailure((self as Failure<T>).failure);
  }
}

final class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

final class Failure<T> extends Result<T> {
  final AppFailure failure;
  const Failure(this.failure);
}

/// Base type for anything that can go wrong in the logic layer.
class AppFailure {
  final String code;
  final String message;

  const AppFailure({required this.code, required this.message});

  @override
  String toString() => 'AppFailure($code): $message';
}

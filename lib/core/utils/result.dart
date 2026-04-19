import '../error/failures.dart';

class Result<T> {
  const Result._({this.data, this.failure});

  final T? data;
  final Failure? failure;

  bool get isSuccess => failure == null;
  bool get isFailure => failure != null;

  static Result<T> ok<T>([T? data]) => Result<T>._(data: data);

  static Result<T> err<T>(Failure failure) => Result<T>._(failure: failure);
}

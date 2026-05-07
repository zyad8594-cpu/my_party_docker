import '../errors/failures.dart';

abstract class ApiResult<T> 
{
  const ApiResult();

  factory ApiResult.success(T data) = SuccessResult<T>;
  factory ApiResult.failure(AppFailure failure) = FailureResult<T>;

  bool get isSuccess => this is SuccessResult<T>;
  bool get isFailure => this is FailureResult<T>;

  T? get data => isSuccess ? (this as SuccessResult<T>).value : null;
  AppFailure? get failure => isFailure ? (this as FailureResult<T>).error : null;

  R fold<R>(R Function(AppFailure failure) onFailure, R Function(T data) onSuccess) 
  {
    if (isSuccess) 
    {
      return onSuccess((this as SuccessResult<T>).value);
    } 
    else 
    {
      return onFailure((this as FailureResult<T>).error);
    }
  }
}

class SuccessResult<T> extends ApiResult<T> 
{
  final T value;
  const SuccessResult(this.value);
}

class FailureResult<T> extends ApiResult<T> 
{
  final AppFailure error;
  const FailureResult(this.error);
}

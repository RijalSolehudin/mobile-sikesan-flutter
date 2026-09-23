sealed class ApiResult<T> {
  const ApiResult();
}

class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  final String? message;
  const ApiSuccess(this.data, {this.message});
}

class ApiFailure<T> extends ApiResult<T> {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;
  const ApiFailure(this.message, {this.statusCode, this.errors});
}

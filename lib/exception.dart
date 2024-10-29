/// {@template redis_exception}
/// An exception thrown by the Redis client.
/// {@endtemplate}
/// Redis客户端抛出异常。
class RedisException implements Exception {
  /// {@macro redis_exception}
  const RedisException(this.message);

  /// The message for the exception.
  final String message;

  @override
  String toString() => message;
}

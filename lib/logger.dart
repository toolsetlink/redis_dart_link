/// {@template redis_logger}
/// A logger for the Redis client.
/// Redis客户端的记录器。
/// {@endtemplate}
abstract interface class RedisLogger {
  // coverage:ignore-start
  /// {@macro redis_logger}
  const RedisLogger();
  // coverage:ignore-end

  /// Log a debug message.
  void debug(String message);

  /// Log an info message.
  void info(String message);

  /// Log an error message.
  void error(String message, {Object? error, StackTrace? stackTrace});
}

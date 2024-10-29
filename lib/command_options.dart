/// {@template redis_command_options}
/// Options for sending commands to a Redis server.
/// 向Redis服务器发送命令的选项。
/// {@endtemplate}
class RedisCommandOptions {
  /// {@macro redis_command_options}
  const RedisCommandOptions({
    this.timeout = const Duration(seconds: 3),
    this.retryInterval = const Duration(seconds: 1),
    this.retryAttempts = 3,
  });

  /// The timeout for sending commands to the Redis server.
  /// Defaults to 3 seconds.
  /// 向Redis服务器发送命令的超时时间。
  /// 默认为3秒。
  final Duration timeout;

  /// The delay between command attempts.
  /// Defaults to 1 second.
  /// 命令尝试之间的延迟。
  /// 默认为1秒。
  final Duration retryInterval;

  /// The maximum number of command attempts.
  /// Defaults to 3.
  /// 命令重试的最大次数。
  /// 默认为3。
  final int retryAttempts;
}

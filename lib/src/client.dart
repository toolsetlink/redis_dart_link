import 'dart:async';
import 'dart:io';

import '../redis_dart_link.dart';
import './model/info.dart';
import 'client/client.dart';
import 'client/commands.dart';
import 'client/server.dart';
import 'model/hscan.dart';
import 'model/scan.dart';
import 'model/set.dart';
import 'model/sscan.dart';

/// {@template redis_client}
/// A client for interacting with a Redis server.
/// 与Redis服务器交互的客户端。
/// {@endtemplate}
class RedisClient {
  /// {@macro redis_client}
  RedisClient({
    RedisSocketOptions? socket,
    RedisCommandOptions command = const RedisCommandOptions(),
    RedisLogger logger = const _NoopRedisLogger(),
  })  : _socketOptions = socket ?? RedisSocketOptions(),
        _commandOptions = command,
        _logger = logger;

  /// The socket options for the Redis server.
  /// Redis服务器的socket选项。
  final RedisSocketOptions _socketOptions;

  /// The command options for the Redis client.
  /// Redis客户端的命令选项。
  final RedisCommandOptions _commandOptions;

  /// The underlying client for interacting with the Redis server.
  /// 与 Resp 协议 服务器交互的底层客户端。
  RespClient? _client;

  /// The logger for the Redis client.
  /// Redis客户端的记录器。
  final RedisLogger _logger;

  /// The underlying connection to the Redis server.
  /// 到Redis服务器的底层连接。
  RespServerConnection? _connection;

  /// Whether the client is connected.
  /// 客户端是否连接。
  var _isConnected = false;

  /// Whether the client has been closed.
  /// 定义 客户端是否关闭 状态。
  var _closed = false;

  /// A completer which completes when the client establishes a connection.
  /// 当客户端建立连接时完成的一种完成程序。
  var _connected = Completer<void>();

  /// A future which completes when the client establishes a connection.
  /// 当客户端建立连接时完成的future。
  Future<void> get _untilConnected => _connected.future;

  /// A completer which completes when the client disconnects.
  /// Begins in a completed state since the client is initially disconnected.
  /// 当客户端断开连接时完成。
  /// 由于客户端最初是断开连接的，所以以已完成状态开始。
  var _disconnected = Completer<void>()..complete();

  /// A future which completes when the client disconnects.
  /// 当客户端断开连接时完成的future。
  Future<void> get _untilDisconnected => _disconnected.future;

  /// The Redis JSON commands.
  /// Redis JSON命令。
  // RedisJson get json => RedisJson._(client: this);

  /// 登录到Redis
  Future<dynamic> _login() async {
    String? username = _socketOptions.username;
    String? password = _socketOptions.password;
    if (password != null) {
      List<String> commands = username != ''
          ? <String>['AUTH', username, password]
          : <String>['AUTH', password];
      return await RespCommandsTier0(_client!).execute(commands);
    }
  }

  /// 建立连接实现方法
  Future<void> _onConnectionOpened(RespServerConnection connection) async {
    _logger.info('Connection opened.');

    _disconnected = Completer<void>();

    _connection = connection;

    _client = RespClient(connection);

    try {
      // 执行登录流程
      await _login();
      // 设置登录状态
      _isConnected = true;

      // 进行数据库选择
      await RespCommandsTier2(_client!).select(_socketOptions.db);

      if (!_connected.isCompleted) _connected.complete();

      _logger.info('Connected.');
    } catch (error) {
      // 异常处理逻辑
      _logger.error('Error during connection opening', error: error);
      _connected.completeError(error);
    }
  }

  /// 重连接
  /// retryAttempts 重连接次数
  Future<void> _reconnect({required int retryAttempts}) async {
    // 判断是否已经到最大重连接次数
    if (retryAttempts <= 0) {
      _connected.completeError(
        const SocketException('Connection retry limit exceeded'),
        StackTrace.current,
      );
      return;
    }

    /// 当连接关闭时调用此方法，可选参数为错误对象和堆栈跟踪。
    /// [error] - 如果关闭是由于错误引起的，则提供错误对象。
    /// [stackTrace] - 如果关闭是由于错误引起的，则提供相关的堆栈跟踪。
    void onConnectionClosed([Object? error, StackTrace? stackTrace]) {
      // 简化逻辑，避免复杂的条件判断
      _logger.info(error != null
          ? 'Connection closed with error.'
          : 'Connection closed.');
      if (error != null) {
        _logger.error('Connection closed with error.',
            error: error, stackTrace: stackTrace);
      }

      // 检查连接是否已经标记为关闭，避免重复操作
      if (_closed) return;

      // 保存当前连接状态，并更新为未连接
      final wasConnected = _isConnected;
      _isConnected = false;

      if (wasConnected) _reset();

      // 获取重连间隔和总尝试次数
      final retryInterval = _socketOptions.retryInterval;
      final totalAttempts = _socketOptions.retryAttempts;

      // 计算剩余尝试次数，根据之前是否已连接
      final remainingAttempts =
          wasConnected ? totalAttempts : retryAttempts - 1;
      final attemptsMade = totalAttempts - remainingAttempts;

      // 构造尝试次数信息，用于日志输出
      final attemptInfo =
          attemptsMade > 0 ? ' ($attemptsMade/$totalAttempts attempts)' : '';

      // 如果之前是连接状态，则重置相关资源
      if (wasConnected) _reset();

      // 记录即将尝试重连的日志信息
      _logger.info(
        'Reconnecting in ${retryInterval.inMilliseconds}ms$attemptInfo.',
      );

      // 延迟执行重连操作，使用剩余的尝试次数作为参数
      Future<void>.delayed(
        retryInterval,
        () => _reconnect(retryAttempts: remainingAttempts),
      );
    }

    try {
      _logger.info('Connecting to ${_socketOptions.connectionUri}.');

      late final connection;

      /// 获取连接参数
      connection = await _getSecureOrInsecureConnection();

      /// 进行异步连接
      unawaited(_onConnectionOpened(connection));

      /// 监听连接关闭事件
      unawaited(
        connection.outputSink.done
            .then((_) => onConnectionClosed())
            .catchError(onConnectionClosed),
      );
    } catch (error, stackTrace) {
      onConnectionClosed(error, stackTrace);
      // 重新抛出错误，让它能被上层捕捉
      // rethrow;
    }
  }

  /// 获取连接 connect 参数
  Future<RespServerConnection> _getSecureOrInsecureConnection() async {
    if (_socketOptions.tlsSecure) {
      return await connectSecureSocket(
        _socketOptions.connectionUri.host,
        port: _socketOptions.connectionUri.port,
        caCertBytes: _socketOptions.caCertBytes,
        certBytes: _socketOptions.certBytes,
        keyBytes: _socketOptions.keyBytes,
        timeout: _socketOptions.timeout,
      );
    } else {
      return await connectSocket(_socketOptions.connectionUri.host,
          port: _socketOptions.connectionUri.port,
          timeout: _socketOptions.timeout);
    }
  }

  /// Establish a connection to the Redis server.
  /// The delay between connection attempts.
  /// 与Redis服务器建立连接
  /// 连接尝试之间的延迟。
  Future<void> connect() async {
    // 判断当前连接状态
    if (_closed) throw StateError('RedisClient has been closed.');

    /// 异步等待连接完成
    unawaited(_reconnect(retryAttempts: _socketOptions.retryAttempts));

    /// 返回处理连接完成的状态
    return _untilConnected;
  }

  /// Terminate the connection to the Redis server.
  Future<void> disconnect() async {
    _logger.info('Disconnecting.');
    await _connection?.close();
    _reset();
    await _untilDisconnected;
    _logger.info('Disconnected.');
  }

  /// 终止与Redis服务器的连接并关闭客户端
  /// 调用此方法后，客户端实例不再可用。
  /// 当你使用完客户端和/或希望调用这个方法
  /// 阻止重新连接。
  Future<void> close() {
    _logger.info('Closing connection.');
    _closed = true;
    return disconnect();
  }

  /// 重置连接状态和相关对象。
  ///
  /// 该方法通过初始化一个新的`Completer<void>`实例、设置`_connection`和`_client`为`null`，
  /// 以及如果`_disconnected`未完成则手动完成它，来确保连接状态被正确地重置。
  void _reset() {
    _connected = Completer<void>();
    _connection = null;
    _client = null;
    if (!_disconnected.isCompleted) _disconnected.complete();
  }

  /// 执行一个异步操作并根据需要重试。
  ///
  /// [fn] 是一个返回异步结果的函数。
  /// [remainingAttempts] 是剩余的重试次数，默认为 [_commandOptions.retryAttempts]。
  ///
  /// 如果 Redis 客户端已关闭，则抛出 [StateError] 异常。
  /// 如果 [remainingAttempts] 为 null，则从 [_commandOptions.retryAttempts] 获取。
  Future<T> _runWithRetryNew<T>(
    Future<T> Function() fn, {
    int? remainingAttempts,
  }) async {
    // 检查 Redis 客户端是否已关闭
    if (_closed) throw StateError('RedisClient has been closed.');

    // 设置剩余重试次数，默认为总重试次数
    remainingAttempts ??= _commandOptions.retryAttempts;

    try {
      // 尝试执行命令，并在连接后返回结果
      return await Future<T>.sync(() async {
        // 判断在判断 执行完异步连接的情况下，才能进行实际操作
        await _untilConnected;

        // 执行 fn
        return fn();
      }).timeout(_commandOptions.timeout);
    } catch (error, stackTrace) {
      // 如果错误是SocketException 则需要尝试重连
      if (error is SocketException) {
        print("尝试重新连接1");
        await connect();
      }

      // 如果错误是TimeoutException 则需要尝试重连
      if (error is TimeoutException) {
        print("尝试重新连接2");
        await connect();
      }

      // 如果是 Redis 异常，则直接抛出
      if (error is RedisException) rethrow;

      // 如果还有剩余重试次数，则记录错误并重试
      if (remainingAttempts > 0) {
        _logger.error(
          'Command failed to complete. Retrying.',
          error: error,
          stackTrace: stackTrace,
        );

        return _runWithRetryNew(
          fn,
          remainingAttempts: remainingAttempts - 1,
        );
      }

      // 如果没有剩余重试次数，则记录错误，关闭连接并抛出异常
      _logger.error(
        'Command failed to complete.',
        error: error,
        stackTrace: stackTrace,
      );

      // 主动断开连接
      await _connection?.close();

      rethrow;
    }
  }

  /// 执行命令行
  Future<dynamic> execute(String str) async {
    List<Object> commandList =
        str.split(" ").where((item) => item.trim().isNotEmpty).toList();
    return _runWithRetryNew(
      () async {
        final result = await RespCommandsTier0(_client!).execute(commandList);
        // if (result.isError) throw RedisException(result.toString());
        return result.payload;
      },
    );
  }

  ///  ------------------------------   Key  ------------------------------

  Future<int> del(List<String> keys) async {
    return await _runWithRetryNew(() async {
      return await RespCommandsTier2(_client!).del(keys);
    });
  }

  Future<bool> expire({required String key, required Duration timeout}) async {
    return await _runWithRetryNew(() async {
      return await RespCommandsTier2(_client!).expire(key, timeout);
    });
  }

  Future<void> rename(String keyName, String newKeyName) async {
    return await _runWithRetryNew(() async {
      return await RespCommandsTier2(_client!).rename(keyName, newKeyName);
    });
  }

  Future<Scan> scan(int cursor, {String? pattern, int? count}) async {
    ScanResult result = await _runWithRetryNew(() async {
      return await RespCommandsTier2(_client!).scan(cursor, count: count);
    });
    return Scan.fromResult(result);
  }

  Future<int> ttl(String key) async {
    return await _runWithRetryNew(() async {
      return await RespCommandsTier2(_client!).ttl(key);
    });
  }

  Future<String?> type({required String key}) async {
    return await _runWithRetryNew(() async {
      return await RespCommandsTier2(_client!).type(key);
    });
  }

  ///  ------------------------------   String  ------------------------------

  Future<String?> get(String key) async {
    return await _runWithRetryNew(() async {
      return await RespCommandsTier2(_client!).get(key);
    });
  }

  Future<Set> set(
    Object key,
    Object value, {
    Duration? ex,
    DateTime? exat,
    Duration? px,
    DateTime? pxat,
    bool nx = false,
    bool xx = false,
    bool get = false,
  }) async {
    SetResult result = await _runWithRetryNew(() async {
      return await RespCommandsTier2(_client!).set(key, value,
          ex: ex, exat: exat, px: px, pxat: pxat, nx: nx, xx: xx, get: get);
    });

    return Set.fromResult(result);
  }

  Future<int> strlen(String key) async {
    return await _runWithRetryNew(() async {
      return await RespCommandsTier2(_client!).strlen(key);
    });
  }

  ///  ------------------------------   Hash  ------------------------------

  Future<int> hdel({required String key, required List<String> fields}) async {
    return await _runWithRetryNew(() async {
      return await RespCommandsTier2(_client!).hdel(key, fields);
    });
  }

  Future<int> hlen(String key) async {
    return await _runWithRetryNew(() async {
      return await RespCommandsTier2(_client!).hlen(key);
    });
  }

  Future<Map<String, String?>> hgetall(String key) async {
    return await _runWithRetryNew(() async {
      return await RespCommandsTier2(_client!).hgetall(key);
    });
  }

  Future<bool> hset(
      {required String key,
      required String field,
      required Object value}) async {
    return await _runWithRetryNew(() async {
      return await RespCommandsTier2(_client!).hset(key, field, value);
    });
  }

  Future<void> hmset(
      {required String key, required Map<Object, Object> values}) async {
    return await _runWithRetryNew(() async {
      return await RespCommandsTier2(_client!).hmset(key, values);
    });
  }

  Future<Hscan> hscan(String key, int cursor,
      {String? pattern, int? count}) async {
    HscanResult result = await _runWithRetryNew(() async {
      return await RespCommandsTier2(_client!).hscan(key, cursor, count: count);
    });

    return Hscan.fromResult(result);
  }

  ///  ------------------------------   List  ------------------------------

  Future<int> llen(String key) async {
    return await _runWithRetryNew(() async {
      return await RespCommandsTier2(_client!).llen(key);
    });
  }

  Future<int> lpush({required String key, required List<Object> values}) async {
    return await _runWithRetryNew(() async {
      return await RespCommandsTier2(_client!).lpush(key, values);
    });
  }

  Future<List<String?>> lrange(String key, int start, int stop) async {
    return await _runWithRetryNew(() async {
      return await RespCommandsTier2(_client!).lrange(key, start, stop);
    });
  }

  Future<int> lrem(
      {required String key, required int count, required Object value}) async {
    return await _runWithRetryNew(() async {
      return await RespCommandsTier2(_client!).lrem(key, count, value);
    });
  }

  Future<bool> lset(
      {required String key, required int index, required Object value}) async {
    return await _runWithRetryNew(() async {
      return await RespCommandsTier2(_client!).lset(key, index, value);
    });
  }

  Future<int> rpush({required String key, required List<Object> values}) async {
    return await _runWithRetryNew(() async {
      return await RespCommandsTier2(_client!).rpush(key, values);
    });
  }

  ///  ------------------------------   Set  ------------------------------

  Future<int> sadd({required String key, required List<Object> values}) async {
    return await _runWithRetryNew(() async {
      return await RespCommandsTier2(_client!).sadd(key, values);
    });
  }

  Future<List<String?>> smembers(String key) async {
    return await _runWithRetryNew(() async {
      return await RespCommandsTier2(_client!).smembers(key);
    });
  }

  Future<int> srem({required String key, required List<Object> members}) async {
    return await _runWithRetryNew(() async {
      return await RespCommandsTier2(_client!).srem(key, members);
    });
  }

  Future<Sscan> sscan(String key, int cursor,
      {String? pattern, int? count}) async {
    SscanResult result = await _runWithRetryNew(() async {
      return await RespCommandsTier2(_client!).sscan(key, cursor, count: count);
    });

    return Sscan.fromResult(result);
  }

  ///  ------------------------------   SortedSet  ------------------------------

  Future<int> zadd(
      {required String key, required Map<Object, double> values}) async {
    return await _runWithRetryNew(() async {
      return await RespCommandsTier2(_client!).zadd(key, values);
    });
  }

  Future<Map<String, double>> zrange(String key, int start, int stop) async {
    return await _runWithRetryNew(() async {
      return await RespCommandsTier2(_client!).zrange(key, start, stop);
    });
  }

  Future<int> zrem({required String key, required List<Object> members}) async {
    return await _runWithRetryNew(() async {
      return await RespCommandsTier2(_client!).zrem(key, members);
    });
  }

  ///  ------------------------------   HyperLogLog  ------------------------------
  ///  ------------------------------   Geo  ------------------------------
  ///  ------------------------------   PubSub  ------------------------------
  ///  ------------------------------   transactions  ------------------------------
  ///  ------------------------------   scripting  ------------------------------

  ///  ------------------------------   connection  ------------------------------

  Future<String> ping() async {
    return _runWithRetryNew(() async {
      return await RespCommandsTier2(_client!).ping();
    });
  }

  Future<void> select(int index) async {
    return await _runWithRetryNew(() async {
      _socketOptions.db = index;
      return await RespCommandsTier2(_client!).select(index);
    });
  }

  ///  ------------------------------   server  ------------------------------

  Future<Info> info([String? section]) async {
    List<String> result = await _runWithRetryNew(() async {
      return await RespCommandsTier2(_client!).info(section);
    });

    return Info.fromResult(result);
  }

  /// ------------------------------  end  -----------------------------
}

/// {@template redis_json}
/// An object that adds support for getting and setting JSON values.
/// Backed by the RedisJSON module.
/// https://redis.io/docs/data-types/json/
/// {@endtemplate}
// class RedisJson {
//   RedisJson._({required RedisClient client}) : _client = client;
//
//   final RedisClient _client;
//
//   /// Set the value of a key.
//   /// Equivalent to the `JSON.SET` command.
//   /// https://redis.io/commands/json.set
//   Future<void> set({
//     required String key,
//     required dynamic value,
//     String path = r'$',
//   }) {
//     return _client.execute(['JSON.SET', key, path, json.encode(value)]);
//   }
//
//   /// Gets the value of a key.
//   /// Returns null if the key does not exist.
//   /// Equivalent to the `JSON.GET` command.
//   /// https://redis.io/commands/json.get
//   Future<dynamic> get({
//     required String key,
//     String path = r'$',
//   }) async {
//     final result = await _client.execute(['JSON.GET', key, path]);
//     if (result is String) {
//       final parts = LineSplitter.split(result);
//       if (parts.isNotEmpty) {
//         final decoded = json.decode(parts.first) as List;
//         if (decoded.isNotEmpty) return decoded.first;
//       }
//     }
//     return null;
//   }
//
//   /// Deletes the specified key.
//   /// Equivalent to the `JSON.DEL` command.
//   /// https://redis.io/commands/json.del
//   Future<void> delete({required String key, String path = r'$'}) {
//     return _client.execute(['JSON.DEL', key, path]);
//   }
//
//   /// Merges the value of a key with the specified value.
//   /// Equivalent to the `JSON.MERGE` command.
//   /// https://redis.io/commands/json.merge
//   Future<void> merge({
//     required String key,
//     required dynamic value,
//     String path = r'$',
//   }) {
//     return _client.execute(['JSON.MERGE', key, path, json.encode(value)]);
//   }
// }

extension on RedisSocketOptions {
  /// The connection URI for the Redis server derived from the socket options.
  Uri get connectionUri => Uri.parse('redis://$host:$port');
}

final class _NoopRedisLogger implements RedisLogger {
  const _NoopRedisLogger();

  @override
  void debug(String message) {}

  @override
  void info(String message) {}

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {}
}

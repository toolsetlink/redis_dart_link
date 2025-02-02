import 'dart:async';
import 'dart:io';

import 'package:redis_dart_link/socket_options.dart';
import 'package:redis_dart_link/src/client.dart';
import 'package:redis_dart_link/src/commands.dart';
import 'package:redis_dart_link/src/server.dart';

import 'command_options.dart';
import 'exception.dart';
import 'logger.dart';
import 'models.dart';

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

      // 判断出当前版本，根据当前版本来判断是否需要调整 resp 协议版本
      Object redisServerInfoObject =
          await RespCommandsTier1(_client!).info('server');
      Info redisInfo = Info.fromResult(redisServerInfoObject);
      int majorVersion = getMajorVersion(redisInfo.server.redisVersion);
      // 设置 resp 协议版本 优先使用resp2
      if (majorVersion > 5) {
        _client?.setRespType(2);
        await RespCommandsTier1(_client!).hello(2);
      }

      // 进行数据库选择
      await RespCommandsTier1(_client!).select(_socketOptions.db);

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

      /// 获取连接参数
      RespServerConnection connection = await _getSecureOrInsecureConnection();

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
        await connect();
      }

      // 如果错误是TimeoutException 则需要尝试重连
      if (error is TimeoutException) {
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

  /// execute
  Future<Execute> execute(String str) async {
    List<Object> commandList =
        str.split(" ").where((item) => item.trim().isNotEmpty).toList();

    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).execute(commandList));
    });

    if (result is RespType2<dynamic>) {
      return Execute.fromResult(result);
    }

    /// 格式化展示
    return Execute.fromResultResp3(result as RespType3<dynamic>);
  }

  ///  ------------------------------   Key  ------------------------------

  /// del
  Future<int> del(List<String> keys) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).del(keys));
    });

    if (result is RespType2<dynamic>) {
      return result.toInteger().payload;
    }

    return (result as RespType3<dynamic>).toInteger().payload;
  }

  /// exists
  Future<int> exists(List<String> keys) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).exists(keys));
    });

    if (result is RespType2<dynamic>) {
      return result.toInteger().payload;
    }

    return (result as RespType3<dynamic>).toInteger().payload;
  }

  /// pexpire
  Future<bool> pexpire(String key, Duration timeout) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).pexpire(key, timeout));
    });

    if (result is RespType2<dynamic>) {
      return result.toInteger().payload == 1;
    }

    return (result as RespType3<dynamic>).toInteger().payload == 1;
  }

  /// expire
  Future<bool> expire(String key, Duration timeout) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).expire(key, timeout));
    });

    if (result is RespType2<dynamic>) {
      return result.toInteger().payload == 1;
    }

    return (result as RespType3<dynamic>).toInteger().payload == 1;
  }

  /// rename
  Future<void> rename(String keyName, String newKeyName) async {
    return await _runWithRetryNew(() async {
      (await RespCommandsTier1(_client!).rename(keyName, newKeyName));
      return null;
    });
  }

  /// scan
  Future<Scan> scan(int cursor, {String? pattern, int? count}) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!)
          .scan(cursor, pattern: pattern, count: count));
    });

    return Scan.fromResult(result);
  }

  /// ttl
  Future<int> ttl(String key) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).ttl(key));
    });

    if (result is RespType2<dynamic>) {
      return result.toInteger().payload;
    }

    return (result as RespType3<dynamic>).toInteger().payload;
  }

  /// type
  Future<String> type(String key) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).type(key));
    });

    if (result is RespType2<dynamic>) {
      return result.toSimpleString().payload;
    }

    return (result as RespType3<dynamic>).toSimpleString().payload;
  }

  ///  ------------------------------   String  ------------------------------

  /// decr
  Future<int> decr(String key) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).decr(key));
    });

    if (result is RespType2<dynamic>) {
      return result.toInteger().payload;
    }

    return (result as RespType3<dynamic>).toInteger().payload;
  }

  /// decrby
  Future<int> decrby(String key, int increment) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).decrby(key, increment));
    });

    if (result is RespType2<dynamic>) {
      return result.toInteger().payload;
    }

    return (result as RespType3<dynamic>).toInteger().payload;
  }

  /// get
  Future<String?> get(String key) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).get(key));
    });

    if (result is RespType2<dynamic>) {
      return result.toSimpleString().payload;
    }

    return (result as RespType3<dynamic>).toSimpleString().payload;
  }

  /// incr
  Future<int> incr(String key) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).incr(key));
    });

    if (result is RespType2<dynamic>) {
      return result.toInteger().payload;
    }

    return (result as RespType3<dynamic>).toInteger().payload;
  }

  /// incrby
  Future<int> incrby(String key, int increment) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).incrby(key, increment));
    });

    if (result is RespType2<dynamic>) {
      return result.toInteger().payload;
    }

    return (result as RespType3<dynamic>).toInteger().payload;
  }

  /// set
  Future<Set> set(Object key, Object value,
      {Duration? ex,
      DateTime? exat,
      Duration? px,
      DateTime? pxat,
      bool nx = false,
      bool xx = false,
      bool get = false}) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).set(
        key,
        value,
        ex: ex,
        exat: exat,
        px: px,
        pxat: pxat,
        nx: nx,
        xx: xx,
        get: get,
      ));
    });

    return Set.fromResult(result);
  }

  /// strlen
  Future<int> strlen(String key) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).strlen(key));
    });

    if (result is RespType2<dynamic>) {
      return result.toInteger().payload;
    }

    return (result as RespType3<dynamic>).toInteger().payload;
  }

  ///  ------------------------------   Hash  ------------------------------

  /// hdel
  Future<int> hdel(String key, List<String> fields) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).hdel(key, fields));
    });

    if (result is RespType2<dynamic>) {
      return result.toInteger().payload;
    }

    return (result as RespType3<dynamic>).toInteger().payload;
  }

  /// hexists
  Future<bool> hexists(String key, String field) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).hexists(key, field));
    });

    if (result is RespType2<dynamic>) {
      return result.toInteger().payload == 1;
    }

    return (result as RespType3<dynamic>).toInteger().payload == 1;
  }

  /// hget
  Future<String?> hget(String key, String field) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).hget(key, field));
    });

    if (result is RespType2<dynamic>) {
      return result.toSimpleString().payload;
    }

    return (result as RespType3<dynamic>).toSimpleString().payload;
  }

  /// hgetall
  Future<Map<String, String?>> hgetall(String key) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).hgetall(key));
    });

    final map = <String, String?>{};

    if (result is RespType2<dynamic>) {
      final result1 = result.toArray().payload;
      if (result1 != null) {
        for (var i = 0; i < result1.length; i += 2) {
          final key = result1[i].toBulkString().payload;
          final value = result1[i + 1].toBulkString().payload;
          if (key != null) {
            map[key] = value;
          }
        }
      }
      return map;
    }

    final result1 = (result as RespType3<dynamic>).toArray().payload;
    if (result1 != null) {
      for (var i = 0; i < result1.length; i += 2) {
        final key = result1[i].toBulkString().payload;
        final value = result1[i + 1].toBulkString().payload;
        if (key != null) {
          map[key] = value;
        }
      }
    }

    return map;
  }

  /// hkeys
  Future<List<String?>> hkeys(String key) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).hkeys(key));
    });

    if (result is RespType2<dynamic>) {
      final result1 = result.toArray().payload;
      if (result1 != null) {
        return result1
            .map((e) => e.toBulkString().payload)
            .toList(growable: false);
      }
      return [];
    }

    final result1 = (result as RespType3<dynamic>).toArray().payload;
    if (result1 != null) {
      return result1
          .map((e) => e.toBulkString().payload)
          .toList(growable: false);
    }
    return [];
  }

  /// hlen
  Future<int> hlen(String key) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).hlen(key));
    });

    if (result is RespType2<dynamic>) {
      return result.toInteger().payload;
    }

    return (result as RespType3<dynamic>).toInteger().payload;
  }

  /// hset
  Future<int> hset(String key, String field, Object value) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).hset(key, field, value));
    });

    if (result is RespType2<dynamic>) {
      return result.toInteger().payload;
    }

    return (result as RespType3<dynamic>).toInteger().payload;
  }

  /// hmset
  Future<void> hmset(String key, Map<Object, Object> values) async {
    return await _runWithRetryNew(() async {
      (await RespCommandsTier1(_client!).hmset(key, values));
      return null;
    });
  }

  /// hscan
  Future<Hscan> hscan(String key, int cursor,
      {String? pattern, int? count}) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!)
          .hscan(key, cursor, pattern: pattern, count: count));
    });

    return Hscan.fromResult(result);
  }

  /// hvals
  Future<List<String?>> hvals(String key) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).hvals(key));
    });

    if (result is RespType2<dynamic>) {
      final result1 = result.toArray().payload;
      if (result1 != null) {
        return result1
            .map((e) => e.toBulkString().payload)
            .toList(growable: false);
      }
      return [];
    }

    final result1 = (result as RespType3<dynamic>).toArray().payload;
    if (result1 != null) {
      return result1
          .map((e) => e.toBulkString().payload)
          .toList(growable: false);
    }
    return [];
  }

  ///  ------------------------------   List  ------------------------------

  /// llen
  Future<int> llen(String key) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).llen(key));
    });

    if (result is RespType2<dynamic>) {
      return result.toInteger().payload;
    }

    return (result as RespType3<dynamic>).toInteger().payload;
  }

  /// lpush
  Future<int> lpush(String key, List<Object> values) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).lpush(key, values));
    });

    if (result is RespType2<dynamic>) {
      return result.toInteger().payload;
    }

    return (result as RespType3<dynamic>).toInteger().payload;
  }

  /// lrange
  Future<List<String?>> lrange(String key, int start, int stop) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).lrange(key, start, stop));
    });

    if (result is RespType2<dynamic>) {
      final result1 = result.toArray().payload;
      if (result1 != null) {
        return result1
            .map((e) => e.toBulkString().payload)
            .toList(growable: false);
      }
      return [];
    }

    final result1 = (result as RespType3<dynamic>).toArray().payload;
    if (result1 != null) {
      return result1
          .map((e) => e.toBulkString().payload)
          .toList(growable: false);
    }
    return [];
  }

  /// lrem
  Future<int> lrem(String key, int count, Object value) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).lrem(key, count, value));
    });

    if (result is RespType2<dynamic>) {
      return result.toInteger().payload;
    }

    return (result as RespType3<dynamic>).toInteger().payload;
  }

  /// lset
  Future<void> lset(String key, int index, Object value) async {
    return await _runWithRetryNew(() async {
      (await RespCommandsTier1(_client!).lset(key, index, value));
      return null;
    });
  }

  /// rpush
  Future<int> rpush(String key, List<Object> values) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).rpush(key, values));
    });

    if (result is RespType2<dynamic>) {
      return result.toInteger().payload;
    }

    return (result as RespType3<dynamic>).toInteger().payload;
  }

  ///  ------------------------------   Set  ------------------------------

  /// sadd
  Future<int> sadd(String key, List<Object> values) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).sadd(key, values));
    });

    if (result is RespType2<dynamic>) {
      return result.toInteger().payload;
    }

    return (result as RespType3<dynamic>).toInteger().payload;
  }

  /// scard
  Future<int> scard(String key) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).scard(key));
    });

    if (result is RespType2<dynamic>) {
      return result.toInteger().payload;
    }

    return (result as RespType3<dynamic>).toInteger().payload;
  }

  /// smembers
  Future<List<String?>> smembers(String key) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).smembers(key));
    });

    if (result is RespType2<dynamic>) {
      final result1 = result.toArray().payload;
      if (result1 != null) {
        return result1
            .map((e) => e.toBulkString().payload)
            .toList(growable: false);
      }
      return [];
    }

    final result1 = (result as RespType3<dynamic>).toArray().payload;
    if (result1 != null) {
      return result1
          .map((e) => e.toBulkString().payload)
          .toList(growable: false);
    }
    return [];
  }

  /// srem
  Future<int> srem(String key, List<Object> members) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).srem(key, members));
    });

    if (result is RespType2<dynamic>) {
      return result.toInteger().payload;
    }

    return (result as RespType3<dynamic>).toInteger().payload;
  }

  /// sscan
  Future<Sscan> sscan(String key, int cursor,
      {String? pattern, int? count}) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!)
          .sscan(key, cursor, pattern: pattern, count: count));
    });

    return Sscan.fromResult(result);
  }

  ///  ------------------------------   SortedSet  ------------------------------

  /// zadd
  Future<int> zadd(String key, Map<Object, double> values) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).zadd(key, values));
    });

    if (result is RespType2<dynamic>) {
      return result.toInteger().payload;
    }

    return (result as RespType3<dynamic>).toInteger().payload;
  }

  /// zcard
  Future<int> zcard(String key) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).zcard(key));
    });

    if (result is RespType2<dynamic>) {
      return result.toInteger().payload;
    }

    return (result as RespType3<dynamic>).toInteger().payload;
  }

  /// zrange
  Future<Map<String, double>> zrange(String key, int start, int stop) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).zrange(key, start, stop));
    });

    final Map<String, double> memberScores = {};

    if (result is RespType2<dynamic>) {
      final result1 = result.toArray().payload;
      if (result1 == null) {
        return memberScores;
      }

      for (int i = 0; i < result1.length; i += 2) {
        final member = result1[i].toBulkString().payload;
        final score = result1[i + 1].toBulkString().payload;

        if (member != null && score != null) {
          memberScores[member] = double.parse(score);
        }
      }

      return memberScores;
    }

    final result1 = (result as RespType3<dynamic>).toArray().payload;
    if (result1 == null) {
      return memberScores;
    }

    for (int i = 0; i < result1.length; i += 2) {
      final member = result1[i].toBulkString().payload;
      final score = result1[i + 1].toBulkString().payload;

      if (member != null && score != null) {
        memberScores[member] = double.parse(score);
      }
    }

    return memberScores;
  }

  /// zrem
  Future<int> zrem(String key, List<Object> members) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).zrem(key, members));
    });

    if (result is RespType2<dynamic>) {
      return result.toInteger().payload;
    }

    return (result as RespType3<dynamic>).toInteger().payload;
  }

  /// zscan
  Future<Zscan> zscan(String key, int cursor,
      {String? pattern, int? count}) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!)
          .zscan(key, cursor, pattern: pattern, count: count));
    });

    return Zscan.fromResult(result);
  }

  ///  ------------------------------   HyperLogLog  ------------------------------

  /// pfadd
  Future<bool> pfadd(String key, List<Object> values) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).pfadd(key, values));
    });

    if (result is RespType2<dynamic>) {
      return result.toInteger().payload == 1;
    }

    return (result as RespType3<dynamic>).toInteger().payload == 1;
  }

  /// pfcount
  Future<int> pfcount(List<Object> keys) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).pfcount(keys));
    });

    if (result is RespType2<dynamic>) {
      return result.toInteger().payload;
    }

    return (result as RespType3<dynamic>).toInteger().payload;
  }

  /// pfmerge
  Future<void> pfmerge(String destkey, List<Object> sourcekeys) async {
    await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).pfmerge(destkey, sourcekeys));
    });
  }

  ///  ------------------------------   Geo  ------------------------------
  /// geoAdd
  Future<int> geoAdd(
      String key, double longitude, double latitude, String member) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!)
          .geoAdd(key, longitude, latitude, member));
    });

    if (result is RespType2<dynamic>) {
      return result.toInteger().payload;
    }

    return (result as RespType3<dynamic>).toInteger().payload;
  }

  /// geoDist
  Future<String?> geoDist(String key, String member1, String member2,
      [String? unit]) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!)
          .geoDist(key, member1, member2, unit));
    });

    if (result is RespType2<dynamic>) {
      return result.toSimpleString().payload;
    }

    return (result as RespType3<dynamic>).toSimpleString().payload;
  }

  /// geoHash
  Future<List<String?>> geoHash(String key, List<Object> members) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).geoHash(key, members));
    });

    if (result is RespType2<dynamic>) {
      final result1 = result.toArray().payload;
      if (result1 != null) {
        return result1
            .map((e) => e.toBulkString().payload)
            .toList(growable: false);
      }
      return [];
    }

    final result1 = (result as RespType3<dynamic>).toArray().payload;
    if (result1 != null) {
      return result1
          .map((e) => e.toBulkString().payload)
          .toList(growable: false);
    }
    return [];
  }

  /// geoHash
  Future<GeoPos> geoPos(String key, List<Object> members) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).geoPos(key, members));
    });

    return GeoPos.fromResult(result);
  }

  ///  ------------------------------   PubSub  ------------------------------

  /// psubscribe
  Stream<Psubscribe> psubscribe(List<String> pattern) {
    Stream<Object> stream = (RespCommandsTier1(_client!).psubscribe(pattern));

    return stream.map((resp) {
      return Psubscribe.fromResult(resp);
    });
  }

  /// subscribe
  Stream<Subscribe> subscribe(List<String> channels) {
    Stream<Object> stream = (RespCommandsTier1(_client!).subscribe(channels));

    return stream.map((resp) {
      return Subscribe.fromResult(resp);
    });
  }

  /// publish
  Future<int> publish(String channel, Object message) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).publish(channel, message));
    });

    if (result is RespType2<dynamic>) {
      return result.toInteger().payload;
    }

    return (result as RespType3<dynamic>).toInteger().payload;
  }

  ///  ------------------------------   transactions  ------------------------------

  /// discard
  Future<void> discard() async {
    (await RespCommandsTier1(_client!).discard());
    return null;
  }

  /// exec
  Future<void> exec() async {
    (await RespCommandsTier1(_client!).exec());
    return null;
  }

  /// multi
  Future<void> multi() async {
    (await RespCommandsTier1(_client!).multi());
    return null;
  }

  /// unwatch
  Future<void> unwatch() async {
    (await RespCommandsTier1(_client!).unwatch());
    return null;
  }

  /// watch
  Future<void> watch(List<String> keys) async {
    (await RespCommandsTier1(_client!).watch(keys));
    return null;
  }

  ///  ------------------------------   scripting  ------------------------------

  ///  ------------------------------   connection  ------------------------------

  /// auth
  Future<void> auth(String password) async {
    return _runWithRetryNew(() async {
      (await RespCommandsTier1(_client!).auth(password));
      return null;
    });
  }

  /// ping
  Future<void> ping() async {
    return _runWithRetryNew(() async {
      (await RespCommandsTier1(_client!).ping());
      return null;
    });
  }

  /// select
  Future<void> select(int index) async {
    return await _runWithRetryNew(() async {
      _socketOptions.db = index;
      (await RespCommandsTier1(_client!).select(index));
      return null;
    });
  }

  /// hello
  Future<void> hello(int protover) async {
    return await _runWithRetryNew(() async {
      (await RespCommandsTier1(_client!).select(protover));
      _client?.setRespType(protover);
      return null;
    });
  }

  ///  ------------------------------   server  ------------------------------

  /// clientList
  Future<ClientList> clientList() async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).clientList());
    });

    return ClientList.fromResult(result);
  }

  /// info
  Future<Info> info([String? section]) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).info(section));
    });
    return Info.fromResult(result);
  }

  /// dbsize
  Future<int> dbsize() async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).dbsize());
    });

    if (result is RespType2<dynamic>) {
      return result.toInteger().payload;
    }

    return (result as RespType3<dynamic>).toInteger().payload;
  }

  /// flushAll
  Future<void> flushAll({bool? doAsync}) async {
    return await _runWithRetryNew(() async {
      (await RespCommandsTier1(_client!).flushAll());
      return null;
    });
  }

  /// flushDb
  Future<void> flushDb({bool? doAsync}) async {
    return await _runWithRetryNew(() async {
      (await RespCommandsTier1(_client!).flushDb());
      return null;
    });
  }

  /// slowlogGet
  Future<SlowlogGet> slowlogGet({int? count}) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).slowlogGet(count));
    });

    return SlowlogGet.fromResult(result);
  }

  /// slowlogLen
  Future<int> slowlogLen() async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).slowlogLen());
    });

    if (result is RespType2<dynamic>) {
      return result.toInteger().payload;
    }

    return (result as RespType3<dynamic>).toInteger().payload;
  }

  /// slowlogReset
  Future<void> slowlogReset() async {
    return await _runWithRetryNew(() async {
      (await RespCommandsTier1(_client!).slowlogReset());
      return null;
    });
  }

  ///  ------------------------------   json  ------------------------------
  /// https://redis.io/docs/latest/develop/data-types/json/

  /// jsonArrAppend
  Future<int> jsonArrAppend(String key, Object value,
      {String path = '\$'}) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!)
          .jsonArrAppend(key: key, path: path, value: value));
    });

    if (result is RespType2<dynamic>) {
      final result1 = result.toArray().payload;
      if (result1 != null && result1.isNotEmpty) {
        return result1[0].payload as int;
      } else {
        throw Exception('jsonArrAppend: No elements in the result list');
      }
    }

    final result1 = (result as RespType3<dynamic>).toArray().payload;
    if (result1 != null && result1.isNotEmpty) {
      return result1[0].payload as int;
    } else {
      throw Exception('jsonArrAppend: No elements in the result list');
    }
  }

  /// jsonArrIndex
  Future<int> jsonArrIndex(
    String key,
    Object value, {
    String path = '\$',
    int? start,
    int? end,
  }) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).jsonArrIndex(
          key: key, path: path, value: value, start: start, end: end));
    });

    if (result is RespType2<dynamic>) {
      final result1 = result.toArray().payload;
      if (result1 != null && result1.isNotEmpty) {
        return result1[0].payload as int;
      } else {
        throw Exception('jsonArrIndex: No elements in the result list');
      }
    }

    final result1 = (result as RespType3<dynamic>).toArray().payload;
    if (result1 != null && result1.isNotEmpty) {
      return result1[0].payload as int;
    } else {
      throw Exception('jsonArrIndex: No elements in the result list');
    }
  }

  /// jsonArrInsert
  Future<int> jsonArrInsert(
    String key,
    Object value, {
    String path = '\$',
    int? start,
    int? end,
  }) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).jsonArrIndex(
          key: key, path: path, value: value, start: start, end: end));
    });

    if (result is RespType2<dynamic>) {
      final result1 = result.toArray().payload;
      if (result1 != null && result1.isNotEmpty) {
        return result1[0].payload as int;
      } else {
        throw Exception('jsonArrInsert: No elements in the result list');
      }
    }

    final result1 = (result as RespType3<dynamic>).toArray().payload;
    if (result1 != null && result1.isNotEmpty) {
      return result1[0].payload as int;
    } else {
      throw Exception('jsonArrInsert: No elements in the result list');
    }
  }

  /// jsonArrLen
  Future<int> jsonArrLen(String key, {String path = '\$'}) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!)
          .jsonArrLen(key: key, path: path));
    });

    if (result is RespType2<dynamic>) {
      final result1 = result.toArray().payload;
      if (result1 != null && result1.isNotEmpty) {
        return result1[0].payload as int;
      } else {
        throw Exception('jsonArrLen: No elements in the result list');
      }
    }

    final result1 = (result as RespType3<dynamic>).toArray().payload;
    if (result1 != null && result1.isNotEmpty) {
      return result1[0].payload as int;
    } else {
      throw Exception('jsonArrLen: No elements in the result list');
    }
  }

  /// jsonArrPop
  Future<String> jsonArrPop(String key,
      {String path = '\$', int index = 0}) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!)
          .jsonArrPop(key: key, path: path, index: index));
    });

    if (result is RespType2<dynamic>) {
      final result1 = result.toArray().payload;
      if (result1 != null && result1.isNotEmpty) {
        return result1[0].payload as String;
      } else {
        throw Exception('jsonArrPop: No elements in the result list');
      }
    }

    final result1 = (result as RespType3<dynamic>).toArray().payload;
    if (result1 != null && result1.isNotEmpty) {
      return result1[0].payload as String;
    } else {
      throw Exception('jsonArrPop: No elements in the result list');
    }
  }

  /// jsonArrTrim
  Future<int> jsonArrTrim(
    String key, {
    String path = '\$',
    int start = 0,
    int stop = 0,
  }) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!)
          .jsonArrTrim(key: key, path: path, start: start, stop: stop));
    });

    if (result is RespType2<dynamic>) {
      final result1 = result.toArray().payload;
      if (result1 != null && result1.isNotEmpty) {
        return result1[0].payload as int;
      } else {
        throw Exception('jsonArrTrim: No elements in the result list');
      }
    }

    final result1 = (result as RespType3<dynamic>).toArray().payload;
    if (result1 != null && result1.isNotEmpty) {
      return result1[0].payload as int;
    } else {
      throw Exception('jsonArrTrim: No elements in the result list');
    }
  }

  /// jsonClear
  Future<int> jsonClear(
    String key, {
    String path = '\$',
  }) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!)
          .jsonClear(key: key, path: path));
    });

    if (result is RespType2<dynamic>) {
      return result.toInteger().payload;
    }

    return (result as RespType3<dynamic>).toInteger().payload;
  }

  /// jsonDel
  Future<int> jsonDel(String key, {String path = '\$'}) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).jsonDel(key: key, path: path));
    });

    if (result is RespType2<dynamic>) {
      return result.toInteger().payload;
    }

    return (result as RespType3<dynamic>).toInteger().payload;
  }

  /// jsonForget
  Future<int> jsonForget(String key, {String path = '\$'}) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!)
          .jsonForget(key: key, path: path));
    });

    if (result is RespType2<dynamic>) {
      return result.toInteger().payload;
    }

    return (result as RespType3<dynamic>).toInteger().payload;
  }

  /// jsonGet
  Future<String?> jsonGet(String key, {String path = '\$'}) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).jsonGet(key: key, path: path));
    });

    if (result is RespType2<dynamic>) {
      return result.toBulkString().payload;
    }

    return (result as RespType3<dynamic>).toBulkString().payload;
  }

  /// jsonMerge
  Future<void> jsonMerge(String key,
      {String path = '\$', required value}) async {
    await _runWithRetryNew(() async {
      (await RespCommandsTier1(_client!)
          .jsonMerge(key: key, path: path, value: value));

      return null;
    });
  }

  /// jsonMget
  Future<List<String?>> jsonMget(List<String> keys,
      {String path = '\$'}) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!)
          .jsonMget(keys: keys, path: path));
    });

    if (result is RespType2<dynamic>) {
      final result1 = result.toArray().payload;
      return result1!
          .map((e) => e.toBulkString().payload)
          .toList(growable: false);
    }

    final result1 = (result as RespType3<dynamic>).toArray().payload;
    return result1!
        .map((e) => e.toBulkString().payload)
        .toList(growable: false);
  }

  /// jsonMset
  Future<void> jsonMset(String key,
      {String path = '\$', required value}) async {
    await _runWithRetryNew(() async {
      (await RespCommandsTier1(_client!)
          .jsonMset(key: key, path: path, value: value));

      return null;
    });
  }

  /// jsonNumincrby
  Future<String?> jsonNumincrby(
    String key, {
    String path = '\$',
    required value,
  }) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).jsonNumincrby(
        key: key,
        path: path,
        value: value,
      ));
    });

    if (result is RespType2<dynamic>) {
      return result.toBulkString().payload;
    }

    return (result as RespType3<dynamic>).toBulkString().payload;
  }

  /// jsonNummultby
  Future<String?> jsonNummultby(
    String key, {
    String path = '\$',
    required value,
  }) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!)
          .jsonNummultby(key: key, path: path, value: value));
    });

    if (result is RespType2<dynamic>) {
      return result.toBulkString().payload;
    }

    return (result as RespType3<dynamic>).toBulkString().payload;
  }

  /// jsonObjkeys
  Future<void> jsonObjkeys(String key, {String path = '\$'}) async {
    await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!)
          .jsonObjkeys(key: key, path: path));
    });
  }

  /// jsonSet
  Future<void> jsonSet({
    required String key,
    String path = '\$',
    required dynamic value,
    bool nx = false,
    bool xx = false,
  }) async {
    await _runWithRetryNew(() async {
      (await RespCommandsTier1(_client!)
          .jsonSet(key: key, path: path, value: value, nx: nx, xx: xx));
    });
    return null;
  }

  /// jsonStrappend
  Future<void> jsonStrappend(
    String key, {
    String path = '\$',
    required value,
  }) async {
    await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!).jsonStrappend(
        key: key,
        path: path,
        value: value,
      ));
    });
  }

  /// jsonStrlen
  Future<List<int?>> jsonStrlen(String key, {String path = '\$'}) async {
    Object result = await _runWithRetryNew(() async {
      return (await RespCommandsTier1(_client!)
          .jsonStrlen(key: key, path: path));
    });

    if (result is RespType2<dynamic>) {
      final result1 = result.toArray().payload;

      if (result1 != null) {
        return result1.map((item) {
          if (item is RespType2<int>) {
            return item.payload;
          } else {
            return null;
          }
        }).toList(growable: false);
      }
      return [];
    }

    final result1 = (result as RespType3<dynamic>).toArray().payload;
    if (result1 != null) {
      return result1.map((item) {
        if (item is RespType3<int>) {
          return item.payload;
        } else {
          return null;
        }
      }).toList(growable: false);
    }
    return [];
  }

  ///  ------------------------------   Commands  ------------------------------

  /// moduleList
  Future<ModuleList> moduleList() async {
    return await _runWithRetryNew(() async {
      Object result = await _runWithRetryNew(() async {
        return (await RespCommandsTier1(_client!).moduleList());
      });
      return ModuleList.fromResult(result);
    });
  }

  /// ------------------------------  end  -----------------------------
  int getMajorVersion(String version) {
    List<String> parts = version.split('.');
    if (parts.isNotEmpty) {
      return int.parse(parts[0]);
    } else {
      throw FormatException('Invalid version format');
    }
  }
}

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

/// {@template redis_socket_options}
/// Options for connecting to a Redis server.
/// 连接到Redis服务器的选项。
/// {@endtemplate}
class RedisSocketOptions {
  /// The host of the Redis server.
  /// Defaults to localhost.
  /// Redis服务器所在主机。
  /// 默认为localhost。
  String host;

  /// The port of the Redis server.
  /// Defaults to 6379.
  /// Redis服务器的端口。
  /// 默认为6379。
  int port;

  /// The timeout for connecting to the Redis server.
  /// Defaults to 30 seconds.
  /// 连接Redis服务器超时时间。
  /// 默认为30秒。
  Duration timeout;

  /// The username for authenticating to the Redis server.
  /// Defaults to ''.
  /// 认证到Redis服务器的用户名
  /// 默认为 '' 。
  String username;

  /// The password for authenticating to the Redis server.
  /// Defaults to null.
  /// 认证到Redis服务器的密码
  /// 默认为null。
  String? password;

  /// 数据库索引，默认为0。
  int db;

  /// The delay between connection attempts.
  /// Defaults to 1 second.
  /// 连接尝试之间的延迟。
  /// 默认为1秒。
  Duration retryInterval;

  /// The maximum number of connection attempts.
  /// Defaults to 10.
  /// 最大连接尝试数。
  /// 默认为10。
  int retryAttempts;

  /// 指定是否使用安全（TLS/SSL）Socket连接。
  bool tlsSecure;

  /// tls 证书
  List<int> caCertBytes;
  List<int> certBytes;
  List<int> keyBytes;

  // 私有构造函数，确保只能通过工厂构造函数创建实例
  RedisSocketOptions._({
    required this.host,
    required this.port,
    required this.timeout,
    required this.username,
    this.password,
    required this.db,
    required this.retryInterval,
    required this.retryAttempts,
    required this.tlsSecure,
    required this.caCertBytes,
    required this.certBytes,
    required this.keyBytes,
  });

  // 工厂构造函数
  factory RedisSocketOptions({
    String host = 'localhost',
    int port = 6379,
    String username = '',
    String? password,
    int db = 0,
    Duration timeout = const Duration(seconds: 30),
    Duration retryInterval = const Duration(seconds: 1),
    int retryAttempts = 10,
    bool tlsSecure = false,
    List<int> caCertBytes = const [],
    List<int> certBytes = const [],
    List<int> keyBytes = const [],
  }) {
    return RedisSocketOptions._(
      host: host,
      port: port,
      timeout: timeout,
      username: username,
      password: password,
      db: db,
      retryInterval: retryInterval,
      retryAttempts: retryAttempts,
      tlsSecure: tlsSecure,
      caCertBytes: caCertBytes,
      certBytes: certBytes,
      keyBytes: keyBytes,
    );
  }
}

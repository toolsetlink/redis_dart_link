import 'package:redis_dart_link/client.dart';
import 'package:redis_dart_link/logger.dart';
import 'package:redis_dart_link/socket_options.dart';
import 'package:test/test.dart';

class MyCustomLogger implements RedisLogger {
  @override
  void debug(String message) {
    print("debug:" + message); // 或
  }

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    print("error:" + message);
  }

  @override
  void info(String message) {
    print("info:" + message);
  }
}

void main() {
  test(
    'adds one to input values',
    () async {
      /// Create a new redis instance
      RedisClient client = RedisClient(
        socket: RedisSocketOptions(
          host: '127.0.0.1',
          port: 7379,
          password: '123456',
        ),
      );
      // Connect to the Redis server.
      await client.connect();

      try {
        await client.ping();

        await client.auth("12345");
      } catch (error, stackTrace) {
        print("ang error: $error");
        print("ang stackTrace: $stackTrace");
      }
    },
    timeout: Timeout(Duration(seconds: 60)), // 设置测试方法超时时间为60秒);
  );
}

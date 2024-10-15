import 'package:redis_dart_link/redis_dart_link.dart';
import 'package:redis_dart_link/src/model/info.dart';
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
  test('adds one to input values', () async {
    /// Create a new redis instance
    RedisClient client = RedisClient(
      socket: RedisSocketOptions(
        host: '127.0.0.1',
        port: 7379,
        password: '123456',
      ),
      logger: MyCustomLogger(),
    );

    // Connect to the Redis server.
    await client.connect();

    Info redisInfo = await client.info();

    print('Redis Info: ${redisInfo}');

    // await Future.delayed(Duration(seconds: 20), () {
    //   print('Redis version: ${redisInfo.server.redisVersion}');
    // });
  });
}

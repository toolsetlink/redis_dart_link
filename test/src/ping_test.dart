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

      Info? redisInfo = await client.info();
      print('Redis version1: ${redisInfo.server.redisVersion}');

      // 睡眠  秒
      // await Future.delayed(Duration(seconds: 12));
      // print("sleep 12");

      try {
        await client.ping();
        print("ping");
      } catch (error, stackTrace) {
        print("ang error: $error");
        print("ang stackTrace: $stackTrace");
      }
    },
    timeout: Timeout(Duration(seconds: 60)), // 设置测试方法超时时间为60秒);
  );
}

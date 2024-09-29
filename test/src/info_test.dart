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
        port: 9527,
        password: '123456',
      ),
      logger: MyCustomLogger(),
    );

    // Connect to the Redis server.
    await client.connect();

    Info? redisInfo = await client.info();
    print('Redis version1: ${redisInfo?.server.redisVersion}');

    Info? redisInfo1 = await client.info();
    print('Redis version1: ${redisInfo1?.server.redisVersion}');

    // 睡眠 5 秒
    // await Future.delayed(Duration(seconds: 20));
    // print("sleep 20");

    // await client.xPing();
    // print("ping");

    // await Future.delayed(Duration(seconds: 20));
    // print("sleep 20");

    // print('Redis info: $redisInfo');
    // print('Redis version1: ${redisInfo?.server.redisVersion}');
    // print('Connected clients: ${redisInfo?.clients.connectedClients}');
    // print('Used memory (bytes): ${redisInfo?.memory.usedMemory}');
    // print('keyspace.length: ${redisInfo?.keyspace.databases.toString()}');
    // print('keyspace.length: ${redisInfo?.keyspace.databases.length}');
    // print('keyspace.length: ${redisInfo?.keyspace.databases[0].keys}');
    // print('keyspace.length: ${redisInfo?.keyspace.databases[1].keys}');

    // await Future.delayed(Duration(seconds: 20), () {
    //   print('Redis version2: ${redisInfo?.server.redisVersion}');
    // });
  });
}

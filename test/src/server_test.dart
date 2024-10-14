import 'package:redis_dart_link/redis_dart_link.dart';
import 'package:redis_dart_link/src/model/slowlog_get.dart';
import 'package:test/test.dart';

void main() {
  test('adds one to input values', () async {
    /// Create a new redis instance
    RedisClient client = RedisClient(
      socket: RedisSocketOptions(
        host: '127.0.0.1',
        port: 6527,
        password: '123456',
      ),
    );

    // Connect to the Redis server.
    await client.connect();

    // int slowlogLenVal = await client.slowlogLen();
    // print(slowlogLenVal);

    SlowlogGet slowlogGetVal = await client.slowlogGet(100);
    print("slowlogGetVal.toString() : ${slowlogGetVal.toString()}");
  });
}

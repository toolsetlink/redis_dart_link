import 'package:redis_dart_link/redis_dart_link.dart';
import 'package:redis_dart_link/src/model/zscan.dart';
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

    await client.zadd(key: 'test-zset', values: {"key1": 1, 'key2': 2});

    Zscan value1 = await client.zscan('test-zset', 0);
    print(value1.keys);
  });
}

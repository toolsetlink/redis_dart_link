import 'package:redis_dart_link/redis_dart_link.dart';
import 'package:redis_dart_link/src/model/sscan.dart';
import 'package:test/test.dart';

void main() {
  test('adds one to input values', () async {
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

    await client.sadd('test-set', ["1", "2"]);

    Sscan value1 = await client.sscan('test-set', 0);
    print(value1.keys);

    int value2 = await client.scard('test-set');
    print(value2);
  });
}

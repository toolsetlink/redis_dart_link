import 'package:redis_dart_link/redis_dart_link.dart';
import 'package:redis_dart_link/src/model/hscan.dart';
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

    final ping_str = await client.ping();
    print("ping_str: $ping_str");

    Hscan value1 = await client.hscan('hash', 0);
    print(value1.keys);
  });
}

import 'package:redis_dart_link/redis_dart_link.dart';
import 'package:redis_dart_link/src/model/scan.dart';
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

    final ping_str = await client.ping();
    print("ping_str: $ping_str");

    Scan value1 = await client.scan(0);
    print(value1.keys);
  });
}

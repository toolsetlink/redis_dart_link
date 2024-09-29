import 'package:redis_dart_link/redis_dart_link.dart';
import 'package:redis_dart_link/src/model/set.dart';
import 'package:test/test.dart';

void main() {
  test('adds one to input values', () async {
    /// Create a new redis instance
    RedisClient client = RedisClient(
      socket: RedisSocketOptions(
        host: '127.0.0.1',
        port: 9527,
        password: '123456',
      ),
    );

    // Connect to the Redis server.
    await client.connect();

    await client.select(1);

    SetModel val = await client.set("test set", "test value");

    print("test val $val");
  });
}

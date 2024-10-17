import 'package:redis_dart_link/redis_dart_link.dart';
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

    var Val = await client.jsonGet('user:1000');
    print("Val.toString() : ${Val}");
  });
}

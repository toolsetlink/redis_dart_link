import 'package:redis_dart_link/client.dart';
import 'package:redis_dart_link/model/hscan.dart';
import 'package:redis_dart_link/socket_options.dart';
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

    Hscan value1 = await client.hscan('hash', 0);
    print(value1.keys);
  });
}
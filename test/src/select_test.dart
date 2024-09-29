import 'package:redis_dart_link/redis_dart_link.dart';
import 'package:redis_dart_link/src/client/commands.dart';
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

    ScanResult scanResult = await client.scan(0, count: 10);
    print('1 cursor: ${scanResult.cursor}');
    print('1 keys.len: ${scanResult.keys.length}');

    await client.select(1);

    scanResult = await client.scan(0, count: 10);
    print('2 cursor: ${scanResult.cursor}');
    print('2 keys.len: ${scanResult.keys.length}');

    await client.select(0);

    scanResult = await client.scan(0, count: 10);
    print('1 cursor: ${scanResult.cursor}');
    print('1 keys.len: ${scanResult.keys.length}');
  });
}

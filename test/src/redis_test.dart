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
    // Set the value of a key.
    // await client.set(key: 'HELLO', value: 'WORLD');
    // String? val = await client.get(key: 'HELLO');
    // print("val: $val");

    ScanResult scanResult = await client.scan(0, count: 10000);
    print('1 cursor: ${scanResult.cursor}');
    print('1 keys.len: ${scanResult.keys.length}');

    print(scanResult.cursor.toString());

    scanResult = await client.scan(
      scanResult.cursor,
      count: 10000,
    );
    print('2 cursor: ${scanResult.cursor}');
    print('2 keys.len: ${scanResult.keys.length}');

    // 处理 scan 返回的结果
    // for (var key in scanResult.keys) {
    //   print('keys: $key'); // 在这里你可以处理每个返回的键
    // }
  });
}

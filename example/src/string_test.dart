import 'package:redis_dart_link/client.dart';
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

    await client.connect();

    String? val = await client.get('string');
    print('val: ${val}');

    String? val1 = await client.get('string1');
    print('val1: ${val1}');

    /// todo 出 error 直线命令会执行 4 次 需要解决
    try {
      String? val2 = await client.get('user:1000');
      print('val2: ${val2}');
    } catch (error, stackTrace) {
      print("error: $error");
      print("stackTrace: $stackTrace");
    }
  });
}

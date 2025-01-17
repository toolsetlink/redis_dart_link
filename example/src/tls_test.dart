import 'package:redis_dart_link/client.dart';
import 'package:redis_dart_link/model.dart';
import 'package:redis_dart_link/socket_options.dart';
import 'package:test/test.dart';

void main() {
  test('adds one to input values', () async {
    // 加载 CA 证书
    // List<int> caCertBytes =
    //     await File("/Users/Downloads/tls redis 密钥/ca.crt").readAsBytes();
    // // print("caCertBytes: $caCertBytes");
    //
    // List<int> certBytes =
    //     await File("/Users/Downloads/tls redis 密钥/redis.crt").readAsBytes();
    // // print("certBytes: $certBytes");
    //
    // List<int> keyBytes =
    //     await File("/Users/Downloads/tls redis 密钥/redis.key").readAsBytes();
    // // print("keyBytes: $keyBytes");

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

    Info? redisInfo = await client.info();

    print('Redis version: ${redisInfo.server.redisVersion}');
  });
}

import 'package:redis_dart_link/client.dart';
import 'package:redis_dart_link/socket_options.dart';

Future<RedisClient> initRedisClient() async {
  // Create a new redis instance
  RedisClient client = RedisClient(
    socket: RedisSocketOptions(
      host: '127.0.0.1',
      port: 7379,
      password: '123456',
    ),
  );

  // Connect to the Redis server.
  await client.connect();
  return client;
}

Future<void> closeRedisClient(RedisClient client) async {
  try {
    await client.close();
  } catch (e) {
    print('Error closing Redis client: $e');
  }
}

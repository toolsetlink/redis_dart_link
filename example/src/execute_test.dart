import 'package:redis_dart_link/client.dart';
import 'package:redis_dart_link/socket_options.dart';
import 'package:test/test.dart';

void main() {
  test('adds one to input values', () async {
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

    // simple
    final simpleResponse = await client.execute('ping');
    print(simpleResponse.list);

    // bulk
    final bulkResponse = await client.execute('info');
    print(bulkResponse.list);

    // array
    final arrayResponse = await client.execute('module list');
    for (var item in arrayResponse.list) {
      print(item);
    }

    // err
    try {
      await client.execute('info111');
    } catch (error) {
      print("error: $error");
    }

    // Close the client connection
    await client.disconnect();
  });
}

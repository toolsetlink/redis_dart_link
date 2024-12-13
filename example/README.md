Example:
## Example:

```
import 'package:redis_dart_link/client.dart';
import 'package:redis_dart_link/logger.dart';
import 'package:redis_dart_link/model/info.dart';
import 'package:redis_dart_link/socket_options.dart';

RedisClient client = RedisClient(
    socket: RedisSocketOptions(
      host: '127.0.0.1',
      port: 9527,
      password: '123456',
    ),
);

// Connect to the Redis server.
await client.connect();

try {
    await client.ping();
    print("ping");
} catch (error, stackTrace) {
    print("error: $error");
    print("stackTrace: $stackTrace");
}

```

Redis client for Dart
=====================

[Redis](http://redis.io/) protocol parser and client for [Dart](https://www.dartlang.org)  


## References
* [resp_client](https://pub.dev/packages/resp_client)
* [redis-dart](https://github.com/ra1u/redis-dart)


## Example:

```
import 'package:redis_dart_link/redis_dart_link.dart';


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
    final str = await client.ping();
    print("ping");
    print("str: $str");

} catch (error, stackTrace) {
    print("error: $error");
    print("stackTrace: $stackTrace");
}

```

See more examples in the test folder

## Changes

[CHANGELOG.md](CHANGELOG.md)

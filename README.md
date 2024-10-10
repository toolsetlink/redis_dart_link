Redis client for Dart
=====================

[![test master](https://github.com/ra1u/redis-dart/actions/workflows/dart.yml/badge.svg)](https://github.com/ra1u/redis-dart/actions/workflows/dart.yml?query=event%3Apush+branch%3Amaster)

[Redis](http://redis.io/) protocol parser and client for [Dart](https://www.dartlang.org)  

Fast and simple by design. It requires no external package to run.

### Supported features:

* [transactions](#transactions) and [CAS](#cas) (check-and-set) pattern
* [pubsub](#pubsub) 
* [unicode](#unicode)
* [performance](#fast) and [simplicity](#Simple)
* [tls](#Tls) 

## Simple

**redis** is simple serializer and deserializer of the [redis protocol](http://redis.io/topics/protocol) with additional helper functions and classes.

Redis protocol is a composition of array, strings (and bulk) and integers.

For example a [SET](http://redis.io/commands/set) command might look like this:

```dart
Future f = command.send_object(["SET","key","value"]);
```

This enables sending any command. Before sending commands one needs to open a
connection to Redis.

In the following example we will open a connection to a Redis server running on
port 6379, execute the command 'SET key 0' and print the result.

```dart
import 'package:redis/redis.dart';
...
final conn = RedisConnection();
conn.connect('localhost', 6379).then((Command command){
    command.send_object(["SET","key","0"]).then((var response)
        print(response);
    )
}
```

Due to the simple implementation, it is possible to execute commands in various
ways. In the following example we execute one after the other.

```dart
final conn = RedisConnection();
conn.connect('localhost', 6379).then((Command command){
  command.send_object(["SET","key","0"])
  .then((var response){
    assert(response == 'OK');
    return command.send_object(["INCR","key"]);
  })
  .then((var response){
    assert(response == 1);  
    return command.send_object(["INCR","key"]);
  })
  .then((var response){
    assert(response == 2);
    return command.send_object(["INCR","key"]);
  })
  .then((var response){
    assert(response == 3);
    return command.send_object(["GET","key"]);
  })
  .then((var response){
    return print(response); // 3
  });
});
```

Another way is to execute commands without waiting for the previous command to
complete, and we can still be sure that the response handled by `Future` will be
completed in the correct order.

```dart
final conn = RedisConnection();
conn.connect('localhost',6379).then((Command command){
  command.send_object(["SET","key","0"])
  .then((var response){
    assert(response == 'OK');
  });
  command.send_object(["INCR","key"])
  .then((var response){
    assert(response == 1);  
  });
  command.send_object(["INCR","key"])
  .then((var response){
    assert(response == 2);
  });
  command.send_object(["INCR","key"])
  .then((var response){
    assert(response == 3);
  });
  command.send_object(["GET","key"])
  .then((var response){
     print(response); // 3
  });
});
```

Difference is that there are five commands in last examples
and only one in the previous example.

### Generic

Redis responses and requests can be arbitrarily nested. 

Mapping

| Redis         | Dart          |
| ------------- |:-------------:| 
| String        | String        | 
| Integer       | Integer       |
| Array         | List          |
| Error         | RedisError    |
| Bulk          | String or Binary |

\* Both simple string and bulk string from Redis are serialized to Dart string.
Strings from Dart to Redis are converted to bulk string. UTF8 encoding is used
in both directions.

New feature since 3.0: Support for converting received data as [binary data](#Binary data).

Lists can be nested. This is useful when executing the [EVAL](http://redis.io/commands/EVAL) command.

```dart
command.send_object(["EVAL","return {KEYS[1],{KEYS[2],{ARGV[1]},ARGV[2]},2}","2","key1","key2","first","second"])
.then((response){
  print(response);
});
```
    
results in

```dart
[key1, [key2, [first], second], 2]
```

## Tls 

Secure ssl/tls with `RedisConnection.connectSecure(host,port)`

```dart
final conn = RedisConnection();
conn.connectSecure('localhost', 6379).then((Command command) {
  command
      .send_object(["AUTH", "username", "password"]).then((var response) {
    print(response);
    command.send_object(["SET", "key", "0"]).then(
        (var response) => print(response));
  });
});
```

or by passing any other [`Socket`](https://api.dart.dev/stable/dart-io/Socket-class.html) to
`RedisConnection.connectWithSocket(Socket s)` in similar fashion.

## Fast

Tested on a laptop, we can execute and process 180K INCR operations per second.

Example

```dart
const int N = 200000;
int start;
final conn = RedisConnection();
conn.connect('localhost',6379).then((Command command){
  print("test started, please wait ...");
  start = DateTime.now().millisecondsSinceEpoch;
  command.pipe_start();
  command.send_object(["SET","test","0"]);
  for(int i=1;i<=N;i++){
    command.send_object(["INCR","test"])
    .then((v){
      if(i != v)
        throw("wrong received value, we got $v");
    });
  }
  //last command will be executed and then processed last
  command.send_object(["GET","test"]).then((v){
    print(v);
    double diff = (new DateTime.now().millisecondsSinceEpoch - start)/1000.0;
    double perf = N/diff;
    print("$N operations done in $diff s\nperformance $perf/s");
  });
  command.pipe_end();
});
```

We are not just sending 200K commands here, but also checking result of every send command.

Using `command.pipe_start();` and  `command.pipe_end();` does nothing more
than enabling and disabling the [Nagle's algorhitm](https://en.wikipedia.org/wiki/Nagle%27s_algorithm) on socket. By default it is disabled to achieve shortest
possible latency at the expense of more TCP packets and extra overhead. Enabling
Nagle's algorithm during transactions can achieve greater data throughput and
less overhead.

## [Transactions](http://redis.io/topics/transactions)

Transactions by redis protocol are started by MULTI command and completed with
EXEC command. `.multi()`, `.exec()` and `class Transaction` are implemented as
helpers for checking the result of each command executed during transaction.

```dart
Future<Transaction> Command.multi();
```

Executing `multi()` returns a `Future<Transaction>`. This class should be used
to execute commands by calling `.send_object`. It returns a `Future` that is
called after calling `.exec()`.

```dart
import 'package:redis/redis.dart';
...

final conn = RedisConnection();
conn.connect('localhost',6379).then((Command command){
  command.multi().then((Transaction trans){
    trans.send_object(["SET","val","0"]);
    for(int i=0;i<200000;++i){
      trans.send_object(["INCR","val"]).then((v){
        assert(i==v);
      });
    }
    trans.send_object(["GET","val"]).then((v){
      print("number is now $v");
    });
    trans.exec();
  });
});
```
    
### [CAS](http://redis.io/topics/transactions#cas)

It's impossible to write code that depends on the result of the previous command 
during a transaction, because all commands are executed at once. To overcome
this, user should use the [CAS](http://redis.io/topics/transactions#cas).

`Cas` requires a `Command` as a constructor argument. It implements two methods:
`watch` and `multiAndExec`.  

`watch` takes two arguments: a list of keys to watch and a handler to call and
to proceed with CAS.

Example:

```dart
cas.watch(["key1,key2,key3"],(){
  //body of CAS
});
```

Failure happens if the watched key is modified outside of the transaction. When
this happens the handler is called until final transaction completes.

`multiAndExec` is used to complete a transaction with a handler where
the argument is `Transaction`. 
 
Example:

```dart
//last part in body of CAS
cas.multiAndExec((Transaction trans){
  trans.send_object(["SET","key1",v1]);
  trans.send_object(["SET","key2",v2]);
  trans.send_object(["SET","key2",v2]);
});
```

Lets imagine we need to atomically increment the value of a key by 1 (and that
Redis does not have the [INCR](http://redis.io/commands/incr) command).

```dart
Cas cas = new Cas(command);
cas.watch(["key"], (){
  command.send_object(["GET","key"]).then((String val){
    int i = int.parse(val);
    i++;
    cas.multiAndExec((Transaction trans){
      trans.send_object(["SET","key",i.toString()]);
    });
  });
});
```

## Unicode

By default UTF8 encoding/decoding for string is used. Each string is converted 
in binary array using UTF8 encoding. This makes ascii string compatible in both
direction.

## Binary data

Default conversion response from Redis of Bulk data is converted to utf-8 string. 
In case when binary interpretation is needed, there is option to request such parsing.

```dart
final conn = RedisConnection();
Command cmd = await conn.connect('localhost',6379);
Command cmd_bin = Command.from(cmd).setParser(RedisParserBulkBinary());
List<int> d = [1,2,3,4,5,6,7,8,9]; 
// send binary
await cmd_bin.send_object(["SET", key, RedisBulk(d)]);
// receive binary from binary command handler
var r = await cmd_bin.send_object(["GET", key])
// r is now same as d
```



## [PubSub](http://redis.io/topics/pubsub)

PubSub is a helper for dispatching received messages. First, create a new
`PubSub` from an existing `Command`

```dart
final pubsub = PubSub(command);
```

Once `PubSub` is created, `Command` is invalidated and should not be used
on the same connection. `PubSub` have the following commands

```dart
void subscribe(List<String> channels)
void psubscribe(List<String> channels)
void unsubscribe(List<String> channels)
void punsubscribe(List<String> channels)
```

and additional `Stream getStream()`

`getStream` returns [`Stream`](https://api.dartlang.org/stable/dart-async/Stream-class.html)

Example for receiving and printing messages

```dart
import 'dart:async';
import 'package:redis/redis.dart';

Future<void> rx() async {
  Command cmd = await RedisConnection().connect('localhost', 6379);
  final pubsub = PubSub(cmd);
  pubsub.subscribe(["monkey"]);
  final stream = pubsub.getStream();
  var streamWithoutErrors = stream.handleError((e) => print("error $e"));
  await for (final msg in streamWithoutErrors) {
    var kind = msg[0];
    var food = msg[2];
    if (kind == "message") {
      print("monkey got ${food}");
      if (food == "cucumber") {
        print("monkey does not like cucumber");
        cmd.get_connection().close();
      }
    }
    else {
      print("received non-message ${msg}");
    }
  }
}

Future<void> tx() async {
  Command cmd = await RedisConnection().connect('localhost', 6379);
  await cmd.send_object(["PUBLISH", "monkey", "banana"]);
  await cmd.send_object(["PUBLISH", "monkey", "apple"]);
  await cmd.send_object(["PUBLISH", "monkey", "peanut"]);
  await cmd.send_object(["PUBLISH", "monkey", "cucumber"]);
  cmd.get_connection().close();
}

void main() async {
  var frx = rx();
  var ftx = tx();
  await ftx;
  await frx;
}
```

Sending messages can be done from different connection for example

```dart
command.send_object(["PUBLISH","monkey","banana"]);
```

## Todo
In the near future:

- Better documentation
- Implement all "generic commands" with named commands
- Better error handling - that is ability to recover from error
- Spell check code

## Changes

[CHANGELOG.md](CHANGELOG.md)

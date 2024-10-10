part of commands;

///
/// Result of a set operation.
/// 集合操作的结果。
///
class SetResult {
  ///
  /// [true] if the value was set.
  /// [true]如果设置了该值。
  ///
  final bool ok;

  ///
  /// The old value of the key before the operation.
  /// 操作前的旧键值。
  ///
  final String? old;
  SetResult._(this.ok, this.old);

  @override
  String toString() => 'SetResult(ok: $ok, old: $old)';
}

///
/// The result of a scan operation.
/// 扫描操作的结果。
///
class ScanResult {
  int _cursor = 0;
  List<String> _keys = [];

  ScanResult._(List<RespType>? result) {
    if (result != null && result.length == 2) {
      final element1 = result[0] as RespBulkString;
      final payload1 = element1.payload;
      if (payload1 != null) {
        _cursor = int.parse(payload1);
      }

      final element2 = result[1] as RespArray;
      final payload2 = element2.payload;
      if (payload2 != null) {
        _keys = payload2
            .cast<RespBulkString>()
            .map((e) => e.payload!)
            .toList(growable: false);
      }
    }
  }

  int get cursor => _cursor;

  List<String> get keys => _keys;

  @override
  String toString() => 'ScanResult(cursor: $cursor, keys: $keys)';
}

class HscanResult {
  int _cursor = 0;
  Map<String, String> _keys = {};

  HscanResult._(List<RespType>? result) {
    if (result != null && result.length == 2) {
      final element1 = result[0] as RespBulkString;
      final payload1 = element1.payload;
      if (payload1 != null) {
        _cursor = int.parse(payload1);
      }
      final element2 = result[1] as RespArray;
      final payload2 = element2.payload;
      if (payload2 != null) {
        // 将原来处理列表的逻辑改为处理映射
        for (var i = 0; i < payload2.length; i += 2) {
          var keyItem = payload2[i] as RespBulkString;
          var valueItem = payload2[i + 1] as RespBulkString;
          if (keyItem.payload != null && valueItem.payload != null) {
            _keys[keyItem.payload!] = valueItem.payload!;
          }
        }
      }
    }
  }

  int get cursor => _cursor;

  Map<String, String> get keys => _keys;

  @override
  String toString() => 'HscanResult(cursor: $_cursor, keys: $_keys)';
}

class SscanResult {
  int _cursor = 0;
  List<String> _keys = [];

  SscanResult._(List<RespType>? result) {
    if (result != null && result.length == 2) {
      final element1 = result[0] as RespBulkString;
      final payload1 = element1.payload;
      if (payload1 != null) {
        _cursor = int.parse(payload1);
      }

      final element2 = result[1] as RespArray;
      final payload2 = element2.payload;
      if (payload2 != null) {
        _keys = payload2
            .cast<RespBulkString>()
            .map((e) => e.payload!)
            .toList(growable: false);
      }
    }
  }

  int get cursor => _cursor;

  List<String> get keys => _keys;

  @override
  String toString() => 'SscanResult(cursor: $cursor, keys: $keys)';
}

///
/// Easy to use API for the Redis commands.
/// 易于使用Redis命令的API。
///
class RespCommandsTier2 {
  final RespCommandsTier1 tier1;

  // 根据RespClient实例创建RespCommandsTier2实例，并通过RespCommandsTier0间接初始化内部的tier1组件
  RespCommandsTier2(RespClient client)
      : tier1 = RespCommandsTier1.tier0(RespCommandsTier0(client));

  // todo 关闭下面两个试试
  // 直接接收RespCommandsTier0实例来构造RespCommandsTier2实例，并同样初始化内部的tier1组件。
  // RespCommandsTier2.tier0(RespCommandsTier0 tier0)
  //     : tier1 = RespCommandsTier1.tier0(tier0);
  // 接收已初始化的tier1组件直接构建RespCommandsTier2实例。
  // RespCommandsTier2.tier1(this.tier1);

  ///
  /// Returns a list of connected clients.
  /// 返回已连接的客户端列表。
  ///
  Future<List<String>> clientList() async {
    final bulkString = (await tier1.clientList()).toBulkString().payload;
    if (bulkString != null) {
      return bulkString
          .split('\n')
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
    }
    return [];
  }

  ///
  /// Sets a value for the given key.
  ///
  /// Returns a [SetResult].
  ///
  Future<SetResult> set(
    Object key,
    Object value, {
    Duration? ex,
    DateTime? exat,
    Duration? px,
    DateTime? pxat,
    bool nx = false,
    bool xx = false,
    bool get = false,
  }) async {
    final result = (await tier1.set(
      key,
      value,
      ex: ex,
      exat: exat,
      px: px,
      pxat: pxat,
      nx: nx,
      xx: xx,
      get: get,
    ));

    return result.handleAs<SetResult>(
      simple: (_) => SetResult._(true, null),
      bulk: (type) => SetResult._(type.payload != null, type.payload),
      error: (_) => SetResult._(false, null),
    );
  }

  // Future<SetResult> set_bak(String key, Object value,
  //     {ExpireMode? expire, SetMode? mode, bool get = false}) async {
  //   final result =
  //       (await tier1.set_bak(key, value, expire: expire, mode: mode, get: get));
  //   return result.handleAs<SetResult>(
  //     simple: (_) => SetResult._(true, null),
  //     bulk: (type) => SetResult._(type.payload != null, type.payload),
  //     error: (_) => SetResult._(false, null),
  //   );
  // }

  ///
  /// Returns the value for the given [key].
  /// If no value if present for the key, [null] is returned.
  ///
  Future<String?> get(String key) async {
    return (await tier1.get(key)).toBulkString().payload;
  }

  Future<int> strlen(String key) async {
    return (await tier1.strlen(key)).toInteger().payload;
  }

  ///
  /// Removes the value for the given [keys].
  /// Returns the number of deleted values.
  ///
  Future<int> del(List<String> keys) async {
    return (await tier1.del(keys)).toInteger().payload;
  }

  ///
  /// Returns the number of values exists for the given [keys]
  ///
  Future<int> exists(List<String> keys) async {
    return (await tier1.exists(keys)).toInteger().payload;
  }

  ///
  /// Return the ttl of the given [key] in seconds. Returns
  /// [-1], if the key has no ttl. Returns [-2], if the key
  /// does not exists.
  ///
  Future<int> ttl(String key) async {
    return (await tier1.ttl(key)).toInteger().payload;
  }

  Future<String> ping() async {
    return (await tier1.ping()).toSimpleString().payload;
  }

  Future<void> rename(String keyName, String newKeyName) async {
    (await tier1.rename(keyName, newKeyName)).toSimpleString();
    return null;
  }

  Future<String?> type(String key) async {
    return (await tier1.type(key)).toSimpleString().payload;
  }

  ///
  /// Sets the timeout for the given [key]. Returns [true],
  /// if the timeout was successfully set. Otherwise,
  /// [false] is returned.
  ///
  Future<bool> pexpire(String key, Duration timeout) async {
    return (await tier1.pexpire(key, timeout)).toInteger().payload == 1;
  }

  Future<bool> expire(String key, Duration timeout) async {
    return (await tier1.expire(key, timeout)).toInteger().payload == 1;
  }

  ///
  /// Selects the Redis logical database. Completes with no value, if the command was successful.
  ///
  Future<void> select(int index) async {
    (await tier1.select(index)).toSimpleString();
    return null;
  }

  ///
  /// Flushes the currently selected database. Completes with no value, if the command was successful.
  ///
  Future<void> flushDb({bool? doAsync}) async {
    (await tier1.flushDb(doAsync: doAsync)).toSimpleString();
    return null;
  }

  ///
  /// Flushes all databases. Completes with no value, if the command was successful.
  ///
  Future<void> flushAll({bool? doAsync}) async {
    (await tier1.flushAll(doAsync: doAsync)).toSimpleString();
    return null;
  }

  ///
  /// Sends the authentication password to the server. Returns true, if the password matches, otherwise false.
  ///
  Future<bool> auth(String password) async {
    final result = await tier1.auth(password);
    if (result is RespSimpleString) {
      return result.payload == 'OK';
    } else {
      return false;
    }
  }

  ///
  /// Sets field in the hash stored at key to value. If key does not exist, a new key
  /// holding a hash is created. If field already exists in the hash, it is overwritten.
  ///
  /// True, if field is a new field in the hash and value was set. False, if field already
  /// exists in the hash and the value was updated.
  ///
  Future<bool> hset(String key, String field, Object value) async {
    return (await tier1.hset(key, field, value)).toInteger().payload == 1;
  }

  ///
  /// Sets field in the hash stored at key to value, only if field does not yet exist.
  /// If key does not exist, a new key holding a hash is created. If field already
  /// exists, this operation has no effect.
  ///
  /// True, if field is a new field in the hash and value was set. False, if field already
  /// exists in the hash and no operation was performed.
  ///
  Future<bool> hsetnx(String key, String field, Object value) async {
    return (await tier1.hsetnx(key, field, value)).toInteger().payload == 1;
  }

  ///
  /// Sets the specified fields to their respective values in the hash stored at key. This
  /// command overwrites any specified fields already existing in the hash. If key does
  /// not exist, a new key holding a hash is created.
  ///
  /// True, if the operation was successful.
  ///
  Future<void> hmset(String key, Map<Object, Object> keysAndValues) async {
    (await tier1.hmset(key, keysAndValues)).toSimpleString();
  }

  ///
  /// Returns the value associated with field in the hash stored at key.
  ///
  /// The value associated with field, or nil when field is not present in the hash or key
  /// does not exist.
  ///
  Future<String?> hget(String key, String field) async {
    return (await tier1.hget(key, field)).toBulkString().payload;
  }

  ///
  /// Returns all fields and values of the hash stored at key. In the returned value, every
  /// field name is followed by its value, so the length of the reply is twice the size of
  /// the hash.
  ///
  /// Map of fields and their values stored in the hash, or an empty list when key does
  /// not exist.
  ///
  Future<Map<String, String?>> hgetall(String key) async {
    final result = (await tier1.hgetall(key)).toArray().payload;

    final map = <String, String?>{};
    if (result != null) {
      for (var i = 0; i < result.length; i += 2) {
        final key = result[i].toBulkString().payload;
        final value = result[i + 1].toBulkString().payload;
        if (key != null) {
          map[key] = value;
        }
      }
    }
    return map;
  }

  ///
  /// Returns the values associated with the specified fields in the hash stored at key.
  ///
  /// For every field that does not exist in the hash, a nil value is returned. Because
  /// non-existing keys are treated as empty hashes, running HMGET against a non-existing
  /// key will return a list of nil values.
  ///
  /// A map of values associated with the given fields, in the same order as they are requested.
  ///
  Future<Map<String, String?>> hmget(String key, List<String> fields) async {
    final result = (await tier1.hmget(key, fields)).toArray().payload;

    if (result != null) {
      final hash = <String, String?>{};
      for (var i = 0; i < fields.length; i++) {
        hash[fields[i]] = result[i].toBulkString().payload;
      }
      return hash;
    }
    return {};
  }

  ///
  /// Removes the specified fields from the hash stored at key. Specified fields that do not
  /// exist within this hash are ignored. If key does not exist, it is treated as an empty
  /// hash and this command returns 0.
  ///
  /// The number of fields that were removed from the hash, not including specified but non
  /// existing fields.
  ///
  Future<int> hdel(String key, List<String> fields) async {
    return (await tier1.hdel(key, fields)).toInteger().payload;
  }

  Future<int> hlen(String key) async {
    return (await tier1.hlen(key)).toInteger().payload;
  }

  ///
  /// Returns if field is an existing field in the hash stored at key.
  ///
  /// True, if the hash contains field. False, if the hash does not contain field, or key
  /// does not exist.
  ///
  Future<bool> hexists(String key, String field) async {
    return (await tier1.hexists(key, field)).toInteger().payload == 1;
  }

  ///
  /// Returns all field names in the hash stored at key.
  ///
  /// List of fields in the hash, or an empty list when key does not exist.
  ///
  Future<List<String>> hkeys(String key) async {
    final result = (await tier1.hkeys(key)).toArray().payload;
    if (result != null) {
      return result
          .map((e) => e.toBulkString().payload!)
          .toList(growable: false);
    }
    return [];
  }

  ///
  /// Returns all values in the hash stored at key.
  ///
  /// List of values in the hash, or an empty list when key does not exist.
  ///
  Future<List<String?>> hvals(String key) async {
    final result = (await tier1.hvals(key)).toArray().payload;
    if (result != null) {
      return result
          .map((e) => e.toBulkString().payload)
          .toList(growable: false);
    }
    return [];
  }

  ///
  /// See https://redis.io/commands/blpop
  ///
  Future<List<String?>> blpop(List<String> keys, int timeout) async {
    final result = (await tier1.blpop(keys, timeout)).toArray().payload;
    if (result != null) {
      return result
          .map((e) => e.toBulkString().payload)
          .toList(growable: false);
    }
    return [];
  }

  ///
  /// BRPOP is a blocking list pop primitive. It is the blocking version of
  /// RPOP because it blocks the connection when there are no elements to
  /// pop from any of the given lists. An element is popped from the tail
  /// of the first list that is non-empty, with the given keys being checked
  /// in the order that they are given.
  ///
  /// See the BLPOP documentation for the exact semantics, since BRPOP is
  /// identical to BLPOP with the only difference being that it pops elements
  /// from the tail of a list instead of popping from the head.
  ///
  /// Returns specifically:
  ///
  /// A nil multi-bulk when no element could be popped and the timeout expired.
  ///
  /// A two-element multi-bulk with the first element being the name of the key
  /// where an element was popped and the second element being the value of the
  /// popped element.
  ///
  Future<List<String?>> brpop(List<String> keys, int timeout) async {
    final result = (await tier1.brpop(keys, timeout)).toArray().payload;
    if (result != null) {
      return result
          .map((e) => e.toBulkString().payload)
          .toList(growable: false);
    }
    return [];
  }

  ///
  /// BRPOPLPUSH is the blocking variant of RPOPLPUSH. When source contains
  /// elements, this command behaves exactly like RPOPLPUSH. When used inside
  /// a MULTI/EXEC block, this command behaves exactly like RPOPLPUSH. When
  /// source is empty, Redis will block the connection until another client
  /// pushes to it or until timeout is reached. A timeout of zero can be
  /// used to block indefinitely.
  ///
  /// See RPOPLPUSH for more information.
  ///
  /// Returns the element being popped from source and pushed to destination.
  /// If timeout is reached, a Null reply is returned.
  ///
  Future<String?> brpoplpush(
      String source, String destination, int timeout) async {
    final result = (await tier1.brpoplpush(source, destination, timeout));
    return result.handleAs(
      bulk: (type) => type.payload,
      array: (_) => null,
    );
  }

  ///
  /// Returns the element at index index in the list stored at key. The
  /// index is zero-based, so 0 means the first element, 1 the second
  /// element and so on. Negative indices can be used to designate elements
  /// starting at the tail of the list. Here, -1 means the last element,
  /// -2 means the penultimate and so forth.
  ///
  /// When the value at key is not a list, an error is returned.
  ///
  /// Returns the requested element, or nil when index is out of range.
  ///
  Future<String?> lindex(String key, int index) async {
    return (await tier1.lindex(key, index)).toBulkString().payload;
  }

  ///
  /// Inserts value in the list stored at key either before or after the
  /// reference value pivot.
  ///
  /// When key does not exist, it is considered an empty list and no
  /// operation is performed.
  ///
  /// An error is returned when key exists but does not hold a list value.
  ///
  /// Returns the length of the list after the insert operation, or -1
  /// when the value pivot was not found.
  ///
  Future<int> linsert(
      String key, InsertMode insertMode, Object pivot, Object value) async {
    return (await tier1.linsert(key, insertMode, pivot, value))
        .toInteger()
        .payload;
  }

  ///
  /// Returns the length of the list stored at key. If key does not exist,
  /// it is interpreted as an empty list and 0 is returned. An error is
  /// returned when the value stored at key is not a list.
  ///
  /// Returns the length of the list at key.
  ///
  Future<int> llen(String key) async {
    return (await tier1.llen(key)).toInteger().payload;
  }

  ///
  /// Removes and returns the first element of the list stored at key.
  ///
  /// Returns the value of the first element, or nil when key does not exist.
  ///
  Future<String?> lpop(String key) async {
    return (await tier1.lpop(key)).toBulkString().payload;
  }

  ///
  /// Insert all the specified values at the head of the list stored at key.
  /// If key does not exist, it is created as empty list before performing
  /// the push operations. When key holds a value that is not a list, an
  /// error is returned.
  ///
  /// It is possible to push multiple elements using a single command call
  /// just specifying multiple arguments at the end of the command. Elements
  /// are inserted one after the other to the head of the list, from the
  /// leftmost element to the rightmost element. So for instance the command
  /// LPUSH mylist a b c will result into a list containing c as first
  /// element, b as second element and a as third element.
  ///
  /// Returns the length of the list after the push operations.
  ///
  Future<int> lpush(String key, List<Object> values) async {
    return (await tier1.lpush(key, values)).toInteger().payload;
  }

  ///
  /// Inserts value at the head of the list stored at key, only if key
  /// already exists and holds a list. In contrary to LPUSH, no operation
  /// will be performed when key does not yet exist.
  ///
  Future<int> lpushx(String key, List<Object> values) async {
    return (await tier1.lpushx(key, values)).toInteger().payload;
  }

  ///
  /// Returns the specified elements of the list stored at key. The offsets
  /// start and stop are zero-based indexes, with 0 being the first element
  /// of the list (the head of the list), 1 being the next element and so on.
  ///
  /// These offsets can also be negative numbers indicating offsets starting
  /// at the end of the list. For example, -1 is the last element of the list,
  /// -2 the penultimate, and so on.
  ///
  /// Note that if you have a list of numbers from 0 to 100, LRANGE list 0 10
  /// will return 11 elements, that is, the rightmost item is included. This
  /// is not be consistent with behavior of range-related functions in the Dart
  /// programming language.
  ///
  /// Out of range indexes will not produce an error. If start is larger than
  /// the end of the list, an empty list is returned. If stop is larger than
  /// the actual end of the list, Redis will treat it like the last element of
  /// the list.
  ///
  /// Returns list of elements in the specified range.
  ///
  Future<List<String?>> lrange(String key, int start, int stop) async {
    final result = (await tier1.lrange(key, start, stop)).toArray().payload;
    if (result != null) {
      return result
          .map((e) => e.toBulkString().payload)
          .toList(growable: false);
    }
    return [];
  }

  Future<Map<String, double>> zrange(String key, int start, int stop) async {
    // 发送带有 WITHSCORES 选项的 ZRANGE 命令。
    final result = (await tier1.zrange(key, start, stop)).toArray().payload;
    print("zrange result: $result");
    if (result != null) {
      // 创建一个 Map 来存储返回的结果。
      final Map<String, double> memberScores = {};

      // 由于 WITHSCORES 选项的存在，结果是一个数组，元素和分数交替出现。
      // 即 [member1, score1, member2, score2, ...]。
      // 因此我们需要每两步遍历一次数组。
      for (int i = 0; i < result.length; i += 2) {
        // 获取成员和对应的分数。
        final member = result[i].toBulkString().payload;
        final score = result[i + 1].toBulkString().payload;

        // 将分数由 String 转换为 double，并将它们添加到 Map 中。
        if (member != null && score != null) {
          memberScores[member] = double.parse(score);
        }
      }

      return memberScores;
    }
    return {};
  }

  Future<List<String?>> smembers(String key) async {
    final result = (await tier1.smembers(key)).toArray().payload;
    if (result != null) {
      return result
          .map((e) => e.toBulkString().payload)
          .toList(growable: false);
    }
    return [];
  }

  ///
  /// Time complexity: O(N) where N is the length of the list.
  ///
  /// Removes the first count occurrences of elements equal to value from
  /// the list stored at key. The count argument influences the operation
  /// in the following ways:
  ///
  /// count > 0: Remove elements equal to value moving from head to tail.
  ///
  /// count < 0: Remove elements equal to value moving from tail to head.
  ///
  /// count = 0: Remove all elements equal to value.
  ///
  /// For example, LREM list -2 "hello" will remove the last two occurrences
  /// of "hello" in the list stored at list.
  ///
  /// Note that non-existing keys are treated like empty lists, so when key
  /// does not exist, the command will always return 0.
  ///
  /// Returns the number of removed elements.
  ///
  Future<int> lrem(String key, int count, Object value) async {
    return (await tier1.lrem(key, count, value)).toInteger().payload;
  }

  ///
  /// Sets the list element at index to value. For more information on the index argument, see LINDEX.
  ///
  /// False is returned for out of range indexes.
  ///
  Future<bool> lset(String key, int index, Object value) async {
    final result = (await tier1.lset(key, index, value));
    print('result: $result');
    return result.handleAs<bool>(
      simple: (_) => true,
      error: (_) => false,
    );
  }

  ///
  /// Trim an existing list so that it will contain only the specified range of elements specified.
  /// Both start and stop are zero-based indexes, where 0 is the first element of the list (the head),
  /// 1 the next element and so on.
  ///
  /// For example: LTRIM foobar 0 2 will modify the list stored at foobar so that only the first
  /// three elements of the list will remain.
  ///
  /// start and end can also be negative numbers indicating offsets from the end of the list,
  /// where -1 is the last element of the list, -2 the penultimate element and so on.
  ///
  /// Out of range indexes will not produce an error: if start is larger than the end of the list,
  /// or start > end, the result will be an empty list (which causes key to be removed). If end
  /// is larger than the end of the list, Redis will treat it like the last element of the list.
  ///
  /// A common use of LTRIM is together with LPUSH / RPUSH. For example:
  ///
  /// LPUSH mylist someelement
  ///
  /// LTRIM mylist 0 99
  ///
  /// This pair of commands will push a new element on the list, while making sure that the list
  /// will not grow larger than 100 elements. This is very useful when using Redis to store logs
  /// for example. It is important to note that when used in this way LTRIM is an O(1) operation
  /// because in the average case just one element is removed from the tail of the list.
  ///
  Future<void> ltrim(String key, int start, int stop) async {
    (await tier1.ltrim(key, start, stop)).toSimpleString();
    return null;
  }

  ///
  /// Removes and returns the last element of the list stored at key.
  ///
  /// Returns the value of the last element, or nil when key does not exist.
  ///
  Future<String?> rpop(String key) async {
    return (await tier1.rpop(key)).toBulkString().payload;
  }

  ///
  /// Atomically returns and removes the last element (tail) of the list stored at source,
  /// and pushes the element at the first element (head) of the list stored at destination.
  ///
  /// For example: consider source holding the list a,b,c, and destination holding the
  /// list x,y,z. Executing RPOPLPUSH results in source holding a,b and destination holding c,x,y,z.
  ///
  /// If source does not exist, the value nil is returned and no operation is performed.
  /// If source and destination are the same, the operation is equivalent to removing the
  /// last element from the list and pushing it as first element of the list, so it can
  /// be considered as a list rotation command.
  ///
  /// Returns the element being popped and pushed.
  ///
  Future<String?> rpoplpush(String source, String destination) async {
    return (await tier1.rpoplpush(source, destination))
        .toSimpleString()
        .payload;
  }

  ///
  /// Insert all the specified values at the tail of the list stored at key.
  /// If key does not exist, it is created as empty list before performing
  /// the push operation. When key holds a value that is not a list, an
  /// error is returned.
  ///
  /// It is possible to push multiple elements using a single command call
  /// just specifying multiple arguments at the end of the command. Elements
  /// are inserted one after the other to the tail of the list, from the
  /// leftmost element to the rightmost element. So for instance the command
  /// RPUSH mylist a b c will result into a list containing a as first
  /// element, b as second element and c as third element.
  ///
  /// Returns the length of the list after the push operation.
  ///
  Future<int> rpush(String key, List<Object> values) async {
    return (await tier1.rpush(key, values)).toInteger().payload;
  }

  Future<int> sadd(String key, List<Object> values) async {
    return (await tier1.sadd(key, values)).toInteger().payload;
  }

  Future<int> srem(String key, List<Object> members) async {
    return (await tier1.srem(key, members)).toInteger().payload;
  }

  Future<int> zrem(String key, List<Object> members) async {
    return (await tier1.zrem(key, members)).toInteger().payload;
  }

  Future<int> zadd(String key, Map<Object, double> values) async {
    return (await tier1.zadd(key, values)).toInteger().payload;
  }

  ///
  /// Inserts value at the tail of the list stored at key, only if key already
  /// exists and holds a list. In contrary to RPUSH, no operation will be
  /// performed when key does not yet exist.
  ///
  /// Returns the length of the list after the push operation.
  ///
  Future<int> rpushx(String key, List<Object> values) async {
    return (await tier1.rpushx(key, values)).toInteger().payload;
  }

  ///
  /// The SCAN command and the closely related commands SSCAN, HSCAN and ZSCAN
  /// are used in order to incrementally iterate over a collection of elements.
  ///
  /// See https://redis.io/commands/scan for more detailed documentation.
  ///
  Future<ScanResult> scan(int cursor, {String? pattern, int? count}) async {
    final result = (await tier1.scan(cursor, pattern: pattern, count: count))
        .toArray()
        .payload;
    return ScanResult._(result);
  }

  Future<HscanResult> hscan(String key, int cursor,
      {String? pattern, int? count}) async {
    final result =
        (await tier1.hscan(key, cursor, pattern: pattern, count: count))
            .toArray()
            .payload;
    return HscanResult._(result);
  }

  Future<SscanResult> sscan(String key, int cursor,
      {String? pattern, int? count}) async {
    final result =
        (await tier1.sscan(key, cursor, pattern: pattern, count: count))
            .toArray()
            .payload;
    return SscanResult._(result);
  }

  ///
  /// Return the number of keys in the currently-selected database.
  ///
  Future<int> dbsize() async {
    return (await tier1.dbsize()).toInteger().payload;
  }

  ///
  /// The INFO command returns information and statistics
  /// about the server in a format that is simple to parse
  /// by computers and easy to read by humans.
  ///
  /// The optional parameter can be used to select a
  /// specific section of information:
  /// server: General information about the Redis server
  /// clients: Client connections section
  /// memory: Memory consumption related information
  /// persistence: RDB and AOF related information
  /// stats: General statistics
  /// replication: Master/replica replication information
  /// cpu: CPU consumption statistics
  /// commandstats: Redis command statistics
  /// cluster: Redis Cluster section
  /// modules: Modules section
  /// keyspace: Database related statistics
  /// modules: Module related sections
  /// errorstats: Redis error statistics
  ///
  /// It can also take the following values:
  /// all: Return all sections (excluding module generated ones)
  /// default: Return only the default set of sections
  /// everything: Includes all and modules
  ///
  /// When no parameter is provided, the default option is
  /// assumed.
  ///
  /// Returns as a collection of text lines.
  ///
  /// Lines can contain a section name (starting with a
  /// # character) or a property. All the properties are in
  /// the form of field:value terminated by \r\n.
  ///
  Future<List<String>> info([String? section]) async {
    final bulkString = (await tier1.info(section)).toBulkString().payload;

    if (bulkString != null) {
      return bulkString
          .split('\n')
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
    }
    return [];
  }

  ///
  /// Increments the number stored at key by one. If the
  /// key does not exist, it is set to 0 before performing
  /// the operation. An error is returned if the key
  /// contains a value of the wrong type or contains a
  /// string that can not be represented as integer. This
  /// operation is limited to 64 bit signed integers.
  ///
  /// Note: this is a string operation because Redis does
  /// not have a dedicated integer type. The string stored
  /// at the key is interpreted as a base-10 64 bit signed
  /// integer to execute the operation.
  ///
  /// Redis stores integers in their integer
  /// representation, so for string values that actually
  /// hold an integer, there is no overhead for storing the
  /// string representation of the integer.
  ///
  /// Returns the value of key after the increment.
  ///
  Future<int> incr(String key) async {
    return (await tier1.incr(key)).toInteger().payload;
  }

  ///
  /// Increments the number stored at key by increment. If
  /// the key does not exist, it is set to 0 before
  /// performing the operation. An error is returned if the
  /// key contains a value of the wrong type or contains a
  /// string that can not be represented as integer. This
  /// operation is limited to 64 bit signed integers.
  ///
  /// See [incr] for extra information on increment/
  /// decrement operations.
  ///
  /// Returns he value of key after the increment.
  ///
  Future<int> incrby(String key, int increment) async {
    return (await tier1.incrby(key, increment)).toInteger().payload;
  }

  ///
  /// Decrements the number stored at key by one. If the
  /// key does not exist, it is set to 0 before performing
  /// the operation. An error is returned if the key
  /// contains a value of the wrong type or contains a
  /// string that can not be represented as integer. This
  /// operation is limited to 64 bit signed integers.
  ///
  /// See [incr] for extra information on increment/
  /// decrement operations.
  ///
  /// Returns the value of key after the decrement.
  ///
  Future<int> decr(String key) async {
    return (await tier1.decr(key)).toInteger().payload;
  }

  ///
  /// Decrements the number stored at key by decrement. If
  /// the key does not exist, it is set to 0 before
  /// performing the operation. An error is returned if the
  /// key contains a value of the wrong type or contains a
  /// string that can not be represented as integer. This
  /// operation is limited to 64 bit signed integers.
  ///
  /// See [incr] for extra information on increment/
  /// decrement operations.
  ///
  /// Returns the value of key after the decrement.
  ///
  Future<int> decrby(String key, int decrement) async {
    return (await tier1.decrby(key, decrement)).toInteger().payload;
  }

  Future<bool> multi() async {
    return (await tier1.multi()).toSimpleString().payload == 'OK';
  }

  Future<RespArray> exec() async {
    return (await tier1.exec()).toArray();
  }

  Future<bool> discard() async {
    return (await tier1.discard()).toSimpleString().payload == 'OK';
  }

  Future<bool> watch(List<String> keys) async {
    return (await tier1.watch(keys)).toSimpleString().payload == 'OK';
  }

  Future<bool> unwatch() async {
    return (await tier1.unwatch()).toSimpleString().payload == 'OK';
  }

  ///
  /// Posts a message to the given channel.
  ///
  /// Returns the number of clients that received the message.
  ///
  Future<int> publish(String channel, Object message) async {
    return (await tier1.publish(channel, message)).toInteger().payload;
  }

  ///
  /// Subscribes the client to the specified channels.
  ///
  /// Once the client enters the subscribed state it is not supposed to
  /// issue any other commands, except for additional SUBSCRIBE,
  /// PSUBSCRIBE, UNSUBSCRIBE and PUNSUBSCRIBE commands.
  ///
  Future<void> subscribe(List<String> channels) async {
    await tier1.subscribe(channels);
  }

  ///
  /// Unsubscribes the client from the given channels, or from all of them
  /// if none is given.
  ///
  /// When no channels are specified, the client is unsubscribed from all
  /// the previously subscribed channels. In this case, a message for every
  /// unsubscribed channel will be sent to the client.
  ///
  Future<void> unsubscribe(Iterable<String> channels) async {
    await tier1.unsubscribe(channels);
  }
}

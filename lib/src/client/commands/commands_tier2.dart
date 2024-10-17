part of commands;

class ZscanResult {
  int _cursor = 0;
  Map<String, String> _keys = {};

  ZscanResult._(List<RespType>? result) {
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

class SlowlogGetResult {
  List<SlowlogGetInfoResult> _list = [];

  SlowlogGetResult._(List<RespType>? result) {
    if (result != null) {
      for (var item in result) {
        if (item is RespArray) {
          final payload = item.payload;

          if (payload != null && payload.length == 6) {
            // 提取 id、timestamp 和 duration
            final id = (payload[0] as RespInteger).payload;
            final timestamp = (payload[1] as RespInteger).payload;
            final duration = (payload[2] as RespInteger).payload;

            // // 提取 command，command 是一个数组
            final commandArray = (payload[3] as RespArray).payload;
            List<String>? command = [];
            if (commandArray != null) {
              command = commandArray.map((cmd) {
                return (cmd as RespBulkString).payload ?? '';
              }).toList(); // 将命令部分转换为 List<String>
            }

            // 提取 client
            String? client = (payload[4] as RespBulkString).payload;

            // extraInfo 可以根据需要进行处理，这里假设总是存在且为字符串
            String? extraInfo =
                (payload.length > 5 && payload[5] is RespBulkString)
                    ? (payload[5] as RespBulkString).payload
                    : '';

            _list.add(SlowlogGetInfoResult(
              id: id,
              timestamp: timestamp,
              duration: duration,
              command: command,
              client: client,
              extraInfo: extraInfo,
            ));
          }
        }
      }
    }
  }

  List<SlowlogGetInfoResult> get list => _list;
}

class SlowlogGetInfoResult {
  final int id;
  final int timestamp;
  final int duration;
  final List<String>? command;
  final String? client;
  final String? extraInfo;

  SlowlogGetInfoResult({
    required this.id,
    required this.timestamp,
    required this.duration,
    required this.command,
    required this.client,
    required this.extraInfo,
  });
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

  ///  ------------------------------   Key  ------------------------------

  ///  ------------------------------   String  ------------------------------

  ///  ------------------------------   Hash  ------------------------------

  // Future<HscanResult> hscan(String key, int cursor,
  //     {String? pattern, int? count}) async {
  //   final result =
  //       (await tier1.hscan(key, cursor, pattern: pattern, count: count))
  //           .toArray()
  //           .payload;
  //   return HscanResult._(result);
  // }

  ///  ------------------------------   List  ------------------------------

  ///  ------------------------------   Set  ------------------------------

  ///  ------------------------------   SortedSet  ------------------------------

  Future<Map<String, double>> zrange(String key, int start, int stop) async {
    final result = (await tier1.zrange(key, start, stop)).toArray().payload;
    if (result != null) {
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

  Future<ZscanResult> zscan(String key, int cursor,
      {String? pattern, int? count}) async {
    final result =
        (await tier1.zscan(key, cursor, pattern: pattern, count: count))
            .toArray()
            .payload;
    return ZscanResult._(result);
  }

  ///  ------------------------------   HyperLogLog  ------------------------------
  ///  ------------------------------   Geo  ------------------------------
  ///  ------------------------------   PubSub  ------------------------------
  ///  ------------------------------   transactions  ------------------------------
  ///  ------------------------------   scripting  ------------------------------

  ///  ------------------------------   connection  ------------------------------

  Future<void> select(int index) async {
    (await tier1.select(index)).toSimpleString();
    return null;
  }

  ///  ------------------------------   server  ------------------------------

  // Future<List<String>> info([String? section]) async {
  //   final bulkString = (await tier1.info(section)).toBulkString().payload;
  //
  //   if (bulkString != null) {
  //     return bulkString
  //         .split('\n')
  //         .where((e) => e.isNotEmpty)
  //         .toList(growable: false);
  //   }
  //   return [];
  // }

  // Future<SlowlogGetResult> slowlogGet({int? count}) async {
  //   if (count == null) {
  //     final result = (await tier1.slowlogGet()).toArray().payload;
  //     return SlowlogGetResult._(result);
  //   } else {
  //     final result = (await tier1.slowlogGet(count)).toArray().payload;
  //     return SlowlogGetResult._(result);
  //   }
  // }

  ///  ------------------------------   json  ------------------------------

  Future<void> jsonSet({
    required String key,
    String path = r'$',
    required dynamic value,
    bool nx = false,
    bool xx = false,
  }) async {
    (await tier1.jsonSet(
      key: key,
      path: path,
      value: value,
      nx: nx,
      xx: xx,
    ))
        .toSimpleString();
    return null;
  }

  Future<List<String>> jsonMget(
      {required List<String> key, String path = r'$'}) async {
    final bulkString =
        (await tier1.jsonMget(key: key, path: path)).toBulkString().payload;
    if (bulkString != null) {
      return bulkString
          .split('\n')
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
    }
    return [];
  }

  //////////////////////////////////////////////////////////////////////////////////

  Future<int> exists(List<String> keys) async {
    return (await tier1.exists(keys)).toInteger().payload;
  }

  Future<bool> pexpire(String key, Duration timeout) async {
    return (await tier1.pexpire(key, timeout)).toInteger().payload == 1;
  }

  Future<void> flushDb({bool? doAsync}) async {
    (await tier1.flushDb(doAsync: doAsync)).toSimpleString();
    return null;
  }

  Future<void> flushAll({bool? doAsync}) async {
    (await tier1.flushAll(doAsync: doAsync)).toSimpleString();
    return null;
  }

  Future<bool> auth(String password) async {
    final result = await tier1.auth(password);
    if (result is RespSimpleString) {
      return result.payload == 'OK';
    } else {
      return false;
    }
  }

  Future<bool> hsetnx(String key, String field, Object value) async {
    return (await tier1.hsetnx(key, field, value)).toInteger().payload == 1;
  }

  Future<String?> hget(String key, String field) async {
    return (await tier1.hget(key, field)).toBulkString().payload;
  }

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

  Future<bool> hexists(String key, String field) async {
    return (await tier1.hexists(key, field)).toInteger().payload == 1;
  }

  Future<List<String>> hkeys(String key) async {
    final result = (await tier1.hkeys(key)).toArray().payload;
    if (result != null) {
      return result
          .map((e) => e.toBulkString().payload!)
          .toList(growable: false);
    }
    return [];
  }

  Future<List<String?>> hvals(String key) async {
    final result = (await tier1.hvals(key)).toArray().payload;
    if (result != null) {
      return result
          .map((e) => e.toBulkString().payload)
          .toList(growable: false);
    }
    return [];
  }

  Future<List<String?>> blpop(List<String> keys, int timeout) async {
    final result = (await tier1.blpop(keys, timeout)).toArray().payload;
    if (result != null) {
      return result
          .map((e) => e.toBulkString().payload)
          .toList(growable: false);
    }
    return [];
  }

  Future<List<String?>> brpop(List<String> keys, int timeout) async {
    final result = (await tier1.brpop(keys, timeout)).toArray().payload;
    if (result != null) {
      return result
          .map((e) => e.toBulkString().payload)
          .toList(growable: false);
    }
    return [];
  }

  Future<String?> brpoplpush(
      String source, String destination, int timeout) async {
    final result = (await tier1.brpoplpush(source, destination, timeout));
    return result.handleAs(
      bulk: (type) => type.payload,
      array: (_) => null,
    );
  }

  Future<String?> lindex(String key, int index) async {
    return (await tier1.lindex(key, index)).toBulkString().payload;
  }

  Future<int> linsert(
      String key, InsertMode insertMode, Object pivot, Object value) async {
    return (await tier1.linsert(key, insertMode, pivot, value))
        .toInteger()
        .payload;
  }

  Future<String?> lpop(String key) async {
    return (await tier1.lpop(key)).toBulkString().payload;
  }

  Future<int> lpushx(String key, List<Object> values) async {
    return (await tier1.lpushx(key, values)).toInteger().payload;
  }

  Future<void> ltrim(String key, int start, int stop) async {
    (await tier1.ltrim(key, start, stop)).toSimpleString();
    return null;
  }

  Future<String?> rpop(String key) async {
    return (await tier1.rpop(key)).toBulkString().payload;
  }

  Future<String?> rpoplpush(String source, String destination) async {
    return (await tier1.rpoplpush(source, destination))
        .toSimpleString()
        .payload;
  }

  Future<int> rpushx(String key, List<Object> values) async {
    return (await tier1.rpushx(key, values)).toInteger().payload;
  }

  Future<int> dbsize() async {
    return (await tier1.dbsize()).toInteger().payload;
  }

  Future<int> incr(String key) async {
    return (await tier1.incr(key)).toInteger().payload;
  }

  Future<int> incrby(String key, int increment) async {
    return (await tier1.incrby(key, increment)).toInteger().payload;
  }

  Future<int> decr(String key) async {
    return (await tier1.decr(key)).toInteger().payload;
  }

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

  Future<int> publish(String channel, Object message) async {
    return (await tier1.publish(channel, message)).toInteger().payload;
  }

  Future<void> subscribe(List<String> channels) async {
    await tier1.subscribe(channels);
  }

  Future<void> unsubscribe(Iterable<String> channels) async {
    await tier1.unsubscribe(channels);
  }
}

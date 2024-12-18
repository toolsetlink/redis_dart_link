part of commands;

/// The mode when to set a value for a key.
/// 设置键值的模式。
enum SetMode {
  onlyIfNotExists,
  onlyIfExists,
}

/// The mode how to handle expiration.
/// 如何处理过期的模式。
class ExpireMode {
  final DateTime? timestamp;
  final Duration? time;

  ExpireMode.timestamp(this.timestamp) : time = null;
  ExpireMode.time(this.time) : timestamp = null;
  ExpireMode.keepTtl()
      : timestamp = null,
        time = null;
}

/// Where to insert a value.
/// 在哪里插入值。
class InsertMode {
  static const before = InsertMode._('BEFORE');
  static const after = InsertMode._('AFTER');

  final String _value;

  const InsertMode._(this._value);
}

/// Type of a Redis client.
/// Redis客户端的类型。
class ClientType {
  static const normal = ClientType._('normal');
  static const master = ClientType._('master');
  static const replica = ClientType._('replica');
  static const pubsub = ClientType._('pubsub');

  final String _value;

  const ClientType._(this._value);

  String get value => _value;
}

/// Commands of tier 1 always return a [RespType]. It is up
/// to the consumer to convert the result correctly into the
/// concrete subtype.
///
/// 第一级的命令总是返回一个[RespType]。再上级将结果正确地转换为具体子类型。
class RespCommandsTier1 {
  final RespCommandsTier0 tier0;

  RespCommandsTier1(RespClient client) : tier0 = RespCommandsTier0(client);
  RespCommandsTier1.tier0(this.tier0);

  Future<RespType> execute(List<Object> command) async {
    return tier0.execute([...command]);
  }

  ///  ------------------------------   Key  ------------------------------

  /// del
  Future<RespType> del(List<String> keys) async {
    return tier0.execute(['DEL', ...keys]);
  }

  /// exists
  Future<RespType> exists(List<String> keys) async {
    return tier0.execute(['EXISTS', ...keys]);
  }

  /// expire
  Future<RespType> expire(String key, Duration timeout) async {
    return tier0.execute(['EXPIRE', key, timeout.inSeconds]);
  }

  /// pexpire
  Future<RespType> pexpire(String key, Duration timeout) async {
    return tier0.execute(['PEXPIRE', key, timeout.inMilliseconds]);
  }

  /// rename
  Future<RespType> rename(String keyName, String newKeyName) async {
    return tier0.execute([
      'RENAME',
      keyName,
      newKeyName,
    ]);
  }

  /// scan
  Future<RespType> scan(int cursor, {String? pattern, int? count}) async {
    return tier0.execute([
      'SCAN',
      '$cursor',
      if (pattern != null) ...['MATCH', pattern],
      if (count != null) ...['COUNT', count],
    ]);
  }

  /// ttl
  Future<RespType> ttl(String key) async {
    return tier0.execute(['TTL', key]);
  }

  /// type
  Future<RespType> type(String key) async {
    return tier0.execute(['TYPE', key]);
  }

  ///  ------------------------------   String  ------------------------------

  /// decr
  Future<RespType> decr(String key) async {
    return tier0.execute(['DECR', key]);
  }

  /// decrby
  Future<RespType> decrby(String key, int decrement) async {
    return tier0.execute(['DECRBY', key, '$decrement']);
  }

  /// get
  Future<RespType> get(String key) async {
    return tier0.execute(['GET', key]);
  }

  /// incr
  Future<RespType> incr(String key) async {
    return tier0.execute(['INCR', key]);
  }

  /// incrby
  Future<RespType> incrby(String key, int increment) async {
    return tier0.execute(['INCRBY', key, '$increment']);
  }

  /// set
  /// EX Relative expiration time set in seconds
  /// EXAT Absolute expiration time corresponding to the time of the UNIX timestamp in seconds
  /// PX Relative expiration time set in milliseconds
  /// PXAT Absolute expiration time corresponding to the time of the UNIX timestamp in milliseconds
  /// EX 相对过期时间 以秒为单位设置过期时间
  /// EXAT 绝对过期时间 以秒为单位的UNIX时间戳所对应的时间为过期时间
  /// PX 相对过期时间 以毫秒为单位设置过期时间
  /// PXAT 绝对过期时间 以毫秒为单位的UNIX时间戳所对应的时间为过期时间
  Future<RespType> set(
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
    return tier0.execute([
      'SET',
      key,
      value,
      if (ex != null) ...[
        'EX',
        '${ex.inSeconds}',
      ],
      if (exat != null) ...[
        'EXAT',
        '${exat.millisecondsSinceEpoch ~/ Duration.microsecondsPerSecond} ',
      ],
      if (px != null) ...[
        'PX',
        '${px.inMilliseconds}',
      ],
      if (pxat != null) ...[
        'PXAT',
        '${pxat.millisecondsSinceEpoch}',
      ],
      if (ex != null && exat == null && px == null && pxat == null) 'KEEPTTL',
      if (nx) 'NX',
      if (xx) 'XX',
      if (get) 'GET',
    ]);
  }

  Future<RespType> strlen(String key) async {
    return tier0.execute(['STRLEN', key]);
  }

  ///  ------------------------------   Hash  ------------------------------

  /// hsetnx
  Future<RespType> hsetnx(String key, String field, Object value) async {
    return tier0.execute(['HSETNX', key, field, value]);
  }

  /// hmget
  Future<RespType> hmget(String key, List<String> fields) async {
    return tier0.execute(['HMGET', key, ...fields]);
  }

  /// hdel
  Future<RespType> hdel(String key, List<String> fields) async {
    return tier0.execute(['HDEL', key, ...fields]);
  }

  /// hexists
  Future<RespType> hexists(String key, String field) async {
    return tier0.execute(['HEXISTS', key, field]);
  }

  /// hget
  Future<RespType> hget(String key, String field) async {
    return tier0.execute(['HGET', key, field]);
  }

  /// hgetall
  Future<RespType> hgetall(String key) async {
    return tier0.execute([
      'HGETALL',
      key,
    ]);
  }

  /// hkeys
  Future<RespType> hkeys(String key) async {
    return tier0.execute(['HKEYS', key]);
  }

  /// hlen
  Future<RespType> hlen(String key) async {
    return tier0.execute(['HLEN', key]);
  }

  /// hset
  Future<RespType> hset(String key, String field, Object value) async {
    return tier0.execute(['HSET', key, field, value]);
  }

  /// hmset
  Future<RespType> hmset(String key, Map<Object, Object> keysAndValues) async {
    return tier0.execute([
      'HMSET',
      key,
      ...keysAndValues.entries.expand((e) => [e.key, e.value]),
    ]);
  }

  /// hscan
  Future<RespType> hscan(String key, int cursor,
      {String? pattern, int? count}) async {
    return tier0.execute([
      'HSCAN',
      key,
      '$cursor',
      if (pattern != null) ...['MATCH', pattern],
      if (count != null) ...['COUNT', count],
    ]);
  }

  /// hvals
  Future<RespType> hvals(String key) async {
    return tier0.execute(['HVALS', key]);
  }

  ///  ------------------------------   List  ------------------------------

  /// blpop
  Future<RespType> blpop(List<String> keys, int timeout) async {
    return tier0.execute(['BLPOP', ...keys, timeout]);
  }

  /// brpop
  Future<RespType> brpop(List<String> keys, int timeout) async {
    return tier0.execute(['BRPOP', ...keys, timeout]);
  }

  /// brpoplpush
  Future<RespType> brpoplpush(
      String source, String destination, int timeout) async {
    return tier0.execute(['BRPOPLPUSH', source, destination, timeout]);
  }

  /// lindex
  Future<RespType> lindex(String key, int index) async {
    return tier0.execute(['LINDEX', key, index]);
  }

  /// linsert
  Future<RespType> linsert(
      String key, InsertMode insertMode, Object pivot, Object value) async {
    return tier0.execute(['LINSERT', key, insertMode._value, pivot, value]);
  }

  /// llen
  Future<RespType> llen(String key) async {
    return tier0.execute(['LLEN', key]);
  }

  /// lpop
  Future<RespType> lpop(String key) async {
    return tier0.execute(['LPOP', key]);
  }

  /// lpush
  Future<RespType> lpush(String key, List<Object> values) async {
    return tier0.execute(['LPUSH', key, ...values]);
  }

  /// lpushx
  Future<RespType> lpushx(String key, List<Object> values) async {
    return tier0.execute(['LPUSHX', key, ...values]);
  }

  /// lrange
  Future<RespType> lrange(String key, int start, int stop) async {
    return tier0.execute(['LRANGE', key, start, stop]);
  }

  /// lrem
  Future<RespType> lrem(String key, int count, Object value) async {
    return tier0.execute(['LREM', key, count, value]);
  }

  /// lset
  Future<RespType> lset(String key, int index, Object value) async {
    return tier0.execute(['LSET', key, index, value]);
  }

  /// ltrim
  Future<RespType> ltrim(String key, int start, int stop) async {
    return tier0.execute(['LTRIM', key, start, stop]);
  }

  /// rpop
  Future<RespType> rpop(String key) async {
    return tier0.execute(['RPOP', key]);
  }

  /// rpoplpush
  Future<RespType> rpoplpush(String source, String destination) async {
    return tier0.execute(['RPOPLPUSH', source, destination]);
  }

  /// rpush
  Future<RespType> rpush(String key, List<Object> values) async {
    return tier0.execute(['RPUSH', key, ...values]);
  }

  /// rpushx
  Future<RespType> rpushx(String key, List<Object> values) async {
    return tier0.execute(['RPUSHX', key, ...values]);
  }

  ///  ------------------------------   Set  ------------------------------

  /// sadd
  Future<RespType> sadd(String key, List<Object> values) async {
    return tier0.execute(['SADD', key, ...values]);
  }

  /// scard
  Future<RespType> scard(String key) async {
    return tier0.execute(['SCARD', key]);
  }

  /// smembers
  Future<RespType> smembers(String key) async {
    return tier0.execute(['SMEMBERS', key]);
  }

  /// srem
  Future<RespType> srem(String key, List<Object> members) async {
    return tier0.execute(['SREM', key, ...members]);
  }

  /// sscan
  Future<RespType> sscan(String key, int cursor,
      {String? pattern, int? count}) async {
    return tier0.execute([
      'SSCAN',
      key,
      '$cursor',
      if (pattern != null) ...['MATCH', pattern],
      if (count != null) ...['COUNT', count],
    ]);
  }

  ///  ------------------------------   SortedSet  ------------------------------

  /// zadd
  Future<RespType> zadd(String key, Map<Object, double> values) async {
    List<Object> params = ['ZADD', key];

    values.forEach((member, score) {
      params.add(score);
      params.add(member);
    });

    return tier0.execute(params);
  }

  /// zcard
  Future<RespType> zcard(String key) async {
    return tier0.execute(['ZCARD', key]);
  }

  /// zrange
  Future<RespType> zrange(String key, int start, int stop) async {
    return tier0.execute(['ZRANGE', key, start, stop, 'WITHSCORES']);
  }

  /// zrem
  Future<RespType> zrem(String key, List<Object> members) async {
    return tier0.execute(['ZREM', key, ...members]);
  }

  /// zscan
  Future<RespType> zscan(String key, int cursor,
      {String? pattern, int? count}) async {
    return tier0.execute([
      'ZSCAN',
      key,
      '$cursor',
      if (pattern != null) ...['MATCH', pattern],
      if (count != null) ...['COUNT', count],
    ]);
  }

  ///  ------------------------------   HyperLogLog  ------------------------------
  ///  ------------------------------   Geo  ------------------------------
  ///  ------------------------------   PubSub  ------------------------------

  /// psubscribe
  Stream<RespType> psubscribe(List<String> pattern) {
    return tier0.psubscribe(pattern);
  }

  /// subscribe
  Stream<RespType> subscribe(List<String> channels) {
    return tier0.subscribe(channels);
  }

  /// publish
  Future<RespType> publish(String channel, Object message) async {
    return tier0.execute(['PUBLISH', channel, message]);
  }

  /// unsubscribe
  Future<RespType> unsubscribe(Iterable<String> channels) async {
    return tier0.execute(['UNSUBSCRIBE', ...channels]);
  }

  ///  ------------------------------   transactions  ------------------------------

  /// discard
  Future<RespType> discard() async {
    return tier0.execute(['DISCARD']);
  }

  /// exec
  Future<RespType> exec() async {
    return tier0.execute(['EXEC']);
  }

  /// multi
  Future<RespType> multi() async {
    return tier0.execute(['MULTI']);
  }

  /// unwatch
  Future<RespType> unwatch() async {
    return tier0.execute(['UNWATCH']);
  }

  /// watch
  Future<RespType> watch(List<String> keys) async {
    return tier0.execute(['WATCH', ...keys]);
  }

  ///  ------------------------------   scripting  ------------------------------

  ///  ------------------------------   connection  ------------------------------

  /// auth
  Future<RespType> auth(String password) async {
    return tier0.execute(['AUTH', password]);
  }

  /// ping
  Future<RespType> ping() async {
    return tier0.execute(['PING']);
  }

  /// select
  Future<RespType> select(int index) async {
    return tier0.execute(['SELECT', index]);
  }

  ///  ------------------------------   server  ------------------------------

  /// clientList
  Future<RespType> clientList() async {
    return tier0.execute(['CLIENT', 'LIST']);
  }

  /// info
  Future<RespType> info(String? section) async {
    return tier0.execute([
      'INFO',
      if (section != null) section,
    ]);
  }

  /// dbsize
  Future<RespType> dbsize() async {
    return tier0.execute(['DBSIZE']);
  }

  /// flushAll
  Future<RespType> flushAll({bool? doAsync}) async {
    return tier0.execute([
      'FLUSHALL',
      if (doAsync != null) doAsync ? 'ASYNC' : 'SYNC',
    ]);
  }

  /// flushDb
  Future<RespType> flushDb({bool? doAsync}) async {
    return tier0.execute([
      'FLUSHDB',
      if (doAsync != null) doAsync ? 'ASYNC' : 'SYNC',
    ]);
  }

  /// slowlogGet
  Future<RespType> slowlogGet(int? count) async {
    return tier0.execute([
      'SLOWLOG',
      'GET',
      if (count != null) '$count',
    ]);
  }

  /// slowlogLen
  Future<RespType> slowlogLen() async {
    return tier0.execute(['SLOWLOG', 'LEN']);
  }

  /// slowlogReset
  Future<RespType> slowlogReset() async {
    return tier0.execute(['SLOWLOG', 'RESET']);
  }

  ///  ------------------------------   json  ------------------------------

  /// jsonArrappend
  Future<RespType> jsonArrappend({
    required String key,
    String path = r'$',
    required Object value,
  }) async {
    return tier0.execute([
      'JSON.ARRAPPEND',
      key,
      path,
      value,
    ]);
  }

  /// jsonArrIndex
  Future<RespType> jsonArrIndex({
    required String key,
    String path = '\$',
    int? index = 0,
    required Object value,
  }) async {
    return tier0.execute([
      'JSON.ARRINDEX',
      key,
      path,
      index,
      value,
    ]);
  }

  /// jsonArrInsert
  Future<RespType> jsonArrInsert({
    required String key,
    String path = r'$',
    int? index = 0,
    required List<Object> values,
  }) async {
    return tier0.execute([
      'JSON.ARRINSERT',
      key,
      path,
      index,
      values,
    ]);
  }

  /// jsonArrLen
  Future<RespType> jsonArrLen({
    required String key,
    String path = r'$',
  }) async {
    return tier0.execute([
      'JSON.ARRLEN',
      key,
      path,
    ]);
  }

  /// jsonArrPop
  Future<RespType> jsonArrPop({
    required String key,
    String path = r'$',
  }) async {
    return tier0.execute([
      'JSON.ARRPOP',
      key,
      path,
    ]);
  }

  /// jsonArrTrim
  Future<RespType> jsonArrTrim({
    required String key,
    String path = r'$',
    required int start,
    required int stop,
  }) async {
    return tier0.execute([
      'JSON.ARRTRIM',
      key,
      path,
      start,
      stop,
    ]);
  }

  /// jsonClear
  Future<RespType> jsonClear({
    required String key,
    String path = r'$',
  }) async {
    return tier0.execute([
      'JSON.CLEAR',
      key,
      path,
    ]);
  }

  /// jsonDebug
  Future<RespType> jsonDebug() async {
    return tier0.execute(['JSON.DEBUG']);
  }

  /// jsonDebugHelp
  Future<RespType> jsonDebugHelp() async {
    return tier0.execute(['JSON.DEBUG HELP']);
  }

  /// jsonDebugMemory
  Future<RespType> jsonDebugMemory({
    required String key,
    String path = r'$',
  }) async {
    return tier0.execute([
      'JSON.DEBUG MEMORY',
      key,
      path,
    ]);
  }

  /// jsonDel
  Future<RespType> jsonDel({required String key, String path = r'$'}) async {
    return tier0.execute([
      'JSON.DEL',
      '$key',
      '$path',
    ]);
  }

  /// jsonForget
  Future<RespType> jsonForget({
    required String key,
    String path = r'$',
  }) async {
    return tier0.execute([
      'JSON.FORGET',
      '$key',
      '$path',
    ]);
  }

  /// jsonGet
  Future<RespType> jsonGet({required String key, String path = r'$'}) async {
    return tier0.execute(['JSON.GET', '$key', '$path']);
  }

  /// jsonMerge
  Future<RespType> jsonMerge({
    required String key,
    String path = r'$',
    required Object value,
  }) async {
    return tier0.execute([
      'JSON.MERGE',
      key,
      path,
      value,
    ]);
  }

  /// jsonMget
  Future<RespType> jsonMget(
      {required List<String> keys, String path = r'$'}) async {
    return tier0.execute(['JSON.MGET', ...keys, '$path']);
  }

  /// jsonMset
  Future<RespType> jsonMset({
    required String key,
    String path = r'$',
    required Object value,
  }) async {
    return tier0.execute(['JSON.MSET', key, '$path', value]);
  }

  /// jsonNumincrby
  Future<RespType> jsonNumincrby({
    required String key,
    String path = r'$',
    required Object value,
  }) async {
    return tier0.execute(['JSON.NUMINCRBY', key, '$path', value]);
  }

  /// jsonNummultby
  Future<RespType> jsonNummultby({
    required String key,
    String path = r'$',
    required Object value,
  }) async {
    return tier0.execute(['JSON.NUMMULTBY', key, '$path', value]);
  }

  /// jsonObjkeys
  Future<RespType> jsonObjkeys({
    required String key,
    String path = r'$',
  }) async {
    return tier0.execute(['JSON.OBJKEYS', key, '$path']);
  }

  /// jsonObjlen
  Future<RespType> jsonObjlen({
    required String key,
    String path = r'$',
  }) async {
    return tier0.execute(['JSON.OBJLEN', key, '$path']);
  }

  /// jsonResp
  Future<RespType> jsonResp({
    required String key,
    String path = r'$',
  }) async {
    return tier0.execute(['JSON.RESP', key, '$path']);
  }

  /// jsonSet
  /// # The NX option is used, set if the specified path does not exist, not set if it already exists and returns nil
  /// # The XX option is used, set when the specified path exists, not set if it does not and returns nil
  /// # 使用了NX选项，当指定的路径不存在时则设置，如果已经存在则不设置并返回nil
  /// # 使用了XX选项，当指定的路径存在时则设置，如果不存在则不设置并返回nil
  Future<RespType> jsonSet({
    required String key,
    String path = r'$',
    required String value,
    bool nx = false,
    bool xx = false,
  }) async {
    return tier0.execute([
      'JSON.SET',
      '$key',
      '$path',
      '$value',
      if (nx) 'NX',
      if (xx) 'XX',
    ]);
  }

  /// jsonStrappend
  Future<RespType> jsonStrappend({
    required String key,
    String path = r'$',
    required Object value,
  }) async {
    return tier0.execute(['JSON.STRAPPEND', key, '$path', value]);
  }

  /// jsonStrlen
  Future<RespType> jsonStrlen({
    required String key,
    String path = r'$',
  }) async {
    return tier0.execute(['JSON.STRLEN', key, '$path']);
  }

  /// jsonToggle
  Future<RespType> jsonToggle({
    required String key,
    String path = r'$',
  }) async {
    return tier0.execute(['JSON.TOGGLE', key, '$path']);
  }

  /// jsonType
  Future<RespType> jsonType({
    required String key,
    String path = r'$',
  }) async {
    return tier0.execute(['JSON.TYPE', key, '$path']);
  }

  ///  ------------------------------   Commands  ------------------------------

  /// moduleList
  Future<RespType> moduleList() async {
    return tier0.execute(['MODULE', 'LIST']);
  }

  /////////////////////////////////////////////////////////////////////////
}

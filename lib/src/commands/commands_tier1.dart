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

/// Commands of tier 1 always return a [RespType2]. It is up
/// to the consumer to convert the result correctly into the
/// concrete subtype.
///
/// 第一级的命令总是返回一个[RespType2]。再上级将结果正确地转换为具体子类型。
class RespCommandsTier1 {
  final RespCommandsTier0 tier0;

  RespCommandsTier1(RespClient client) : tier0 = RespCommandsTier0(client);
  RespCommandsTier1.tier0(this.tier0);

  Future<Object> execute(List<Object> command) async {
    return tier0.execute([...command]);
  }

  ///  ------------------------------   Key  ------------------------------

  /// del
  Future<Object> del<T>(List<String> keys) async {
    return tier0.execute(['DEL', ...keys]);
  }

  /// exists
  Future<Object> exists(List<String> keys) async {
    return tier0.execute(['EXISTS', ...keys]);
  }

  /// expire
  Future<Object> expire(String key, Duration timeout) async {
    return tier0.execute(['EXPIRE', key, timeout.inSeconds]);
  }

  /// pexpire
  Future<Object> pexpire(String key, Duration timeout) async {
    return tier0.execute(['PEXPIRE', key, timeout.inMilliseconds]);
  }

  /// rename
  Future<Object> rename(String keyName, String newKeyName) async {
    return tier0.execute([
      'RENAME',
      keyName,
      newKeyName,
    ]);
  }

  /// scan
  Future<Object> scan(int cursor, {String? pattern, int? count}) async {
    return tier0.execute([
      'SCAN',
      '$cursor',
      if (pattern != null) ...['MATCH', pattern],
      if (count != null) ...['COUNT', count],
    ]);
  }

  /// ttl
  Future<Object> ttl(String key) async {
    return tier0.execute(['TTL', key]);
  }

  /// type
  Future<Object> type(String key) async {
    return tier0.execute(['TYPE', key]);
  }

  ///  ------------------------------   String  ------------------------------

  /// decr
  Future<Object> decr(String key) async {
    return tier0.execute(['DECR', key]);
  }

  /// decrby
  Future<Object> decrby(String key, int decrement) async {
    return tier0.execute(['DECRBY', key, '$decrement']);
  }

  /// get
  Future<Object> get(String key) async {
    return tier0.execute(['GET', key]);
  }

  /// incr
  Future<Object> incr(String key) async {
    return tier0.execute(['INCR', key]);
  }

  /// incrby
  Future<Object> incrby(String key, int increment) async {
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
  Future<Object> set(
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

  Future<Object> strlen(String key) async {
    return tier0.execute(['STRLEN', key]);
  }

  ///  ------------------------------   Hash  ------------------------------

  /// hsetnx
  Future<Object> hsetnx(String key, String field, Object value) async {
    return tier0.execute(['HSETNX', key, field, value]);
  }

  /// hmget
  Future<Object> hmget(String key, List<String> fields) async {
    return tier0.execute(['HMGET', key, ...fields]);
  }

  /// hdel
  Future<Object> hdel(String key, List<String> fields) async {
    return tier0.execute(['HDEL', key, ...fields]);
  }

  /// hexists
  Future<Object> hexists(String key, String field) async {
    return tier0.execute(['HEXISTS', key, field]);
  }

  /// hget
  Future<Object> hget(String key, String field) async {
    return tier0.execute(['HGET', key, field]);
  }

  /// hgetall
  Future<Object> hgetall(String key) async {
    return tier0.execute([
      'HGETALL',
      key,
    ]);
  }

  /// hkeys
  Future<Object> hkeys(String key) async {
    return tier0.execute(['HKEYS', key]);
  }

  /// hlen
  Future<Object> hlen(String key) async {
    return tier0.execute(['HLEN', key]);
  }

  /// hset
  Future<Object> hset(String key, String field, Object value) async {
    return tier0.execute(['HSET', key, field, value]);
  }

  /// hmset
  Future<Object> hmset(String key, Map<Object, Object> keysAndValues) async {
    return tier0.execute([
      'HMSET',
      key,
      ...keysAndValues.entries.expand((e) => [e.key, e.value]),
    ]);
  }

  /// hscan
  Future<Object> hscan(String key, int cursor,
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
  Future<Object> hvals(String key) async {
    return tier0.execute(['HVALS', key]);
  }

  ///  ------------------------------   List  ------------------------------

  /// blpop
  Future<Object> blpop(List<String> keys, int timeout) async {
    return tier0.execute(['BLPOP', ...keys, timeout]);
  }

  /// brpop
  Future<Object> brpop(List<String> keys, int timeout) async {
    return tier0.execute(['BRPOP', ...keys, timeout]);
  }

  /// brpoplpush
  Future<Object> brpoplpush(
      String source, String destination, int timeout) async {
    return tier0.execute(['BRPOPLPUSH', source, destination, timeout]);
  }

  /// lindex
  Future<Object> lindex(String key, int index) async {
    return tier0.execute(['LINDEX', key, index]);
  }

  /// linsert
  Future<Object> linsert(
      String key, InsertMode insertMode, Object pivot, Object value) async {
    return tier0.execute(['LINSERT', key, insertMode._value, pivot, value]);
  }

  /// llen
  Future<Object> llen(String key) async {
    return tier0.execute(['LLEN', key]);
  }

  /// lpop
  Future<Object> lpop(String key) async {
    return tier0.execute(['LPOP', key]);
  }

  /// lpush
  Future<Object> lpush(String key, List<Object> values) async {
    return tier0.execute(['LPUSH', key, ...values]);
  }

  /// lpushx
  Future<Object> lpushx(String key, List<Object> values) async {
    return tier0.execute(['LPUSHX', key, ...values]);
  }

  /// lrange
  Future<Object> lrange(String key, int start, int stop) async {
    return tier0.execute(['LRANGE', key, start, stop]);
  }

  /// lrem
  Future<Object> lrem(String key, int count, Object value) async {
    return tier0.execute(['LREM', key, count, value]);
  }

  /// lset
  Future<Object> lset(String key, int index, Object value) async {
    return tier0.execute(['LSET', key, index, value]);
  }

  /// ltrim
  Future<Object> ltrim(String key, int start, int stop) async {
    return tier0.execute(['LTRIM', key, start, stop]);
  }

  /// rpop
  Future<Object> rpop(String key) async {
    return tier0.execute(['RPOP', key]);
  }

  /// rpoplpush
  Future<Object> rpoplpush(String source, String destination) async {
    return tier0.execute(['RPOPLPUSH', source, destination]);
  }

  /// rpush
  Future<Object> rpush(String key, List<Object> values) async {
    return tier0.execute(['RPUSH', key, ...values]);
  }

  /// rpushx
  Future<Object> rpushx(String key, List<Object> values) async {
    return tier0.execute(['RPUSHX', key, ...values]);
  }

  ///  ------------------------------   Set  ------------------------------

  /// sadd
  Future<Object> sadd(String key, List<Object> values) async {
    return tier0.execute(['SADD', key, ...values]);
  }

  /// scard
  Future<Object> scard(String key) async {
    return tier0.execute(['SCARD', key]);
  }

  /// smembers
  Future<Object> smembers(String key) async {
    return tier0.execute(['SMEMBERS', key]);
  }

  /// srem
  Future<Object> srem(String key, List<Object> members) async {
    return tier0.execute(['SREM', key, ...members]);
  }

  /// sscan
  Future<Object> sscan(String key, int cursor,
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
  Future<Object> zadd(String key, Map<Object, double> values) async {
    List<Object> params = ['ZADD', key];

    values.forEach((member, score) {
      params.add(score);
      params.add(member);
    });

    return tier0.execute(params);
  }

  /// zcard
  Future<Object> zcard(String key) async {
    return tier0.execute(['ZCARD', key]);
  }

  /// zrange
  Future<Object> zrange(String key, int start, int stop) async {
    return tier0.execute(['ZRANGE', key, start, stop, 'WITHSCORES']);
  }

  /// zrem
  Future<Object> zrem(String key, List<Object> members) async {
    return tier0.execute(['ZREM', key, ...members]);
  }

  /// zscan
  Future<Object> zscan(String key, int cursor,
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
  /// geoAdd
  Future<Object> geoAdd(
      String key, double longitude, double latitude, String member) async {
    return tier0.execute(['GEOADD', key, longitude, latitude, member]);
  }

  /// geoDist
  Future<Object> geoDist(
    String key,
    String member1,
    String member2,
    String? unit,
  ) async {
    return tier0.execute([
      'GEODIST',
      key,
      member1,
      member2,
      if (unit != null) unit,
    ]);
  }

  /// geoHash
  Future<Object> geoHash(String key, List<Object> members) async {
    return tier0.execute(['GEOHASH', key, ...members]);
  }

  /// geoPos
  Future<Object> geoPos(String key, List<Object> members) async {
    return tier0.execute(['GEOPOS', key, ...members]);
  }

  ///  ------------------------------   PubSub  ------------------------------

  /// psubscribe
  Stream<Object> psubscribe(List<String> pattern) {
    return tier0.psubscribe(pattern);
  }

  /// subscribe
  Stream<Object> subscribe(List<String> channels) {
    return tier0.subscribe(channels);
  }

  /// publish
  Future<Object> publish(String channel, Object message) async {
    return tier0.execute(['PUBLISH', channel, message]);
  }

  /// unsubscribe
  Future<Object> unsubscribe(Iterable<String> channels) async {
    return tier0.execute(['UNSUBSCRIBE', ...channels]);
  }

  ///  ------------------------------   transactions  ------------------------------

  /// discard
  Future<Object> discard() async {
    return tier0.execute(['DISCARD']);
  }

  /// exec
  Future<Object> exec() async {
    return tier0.execute(['EXEC']);
  }

  /// multi
  Future<Object> multi() async {
    return tier0.execute(['MULTI']);
  }

  /// unwatch
  Future<Object> unwatch() async {
    return tier0.execute(['UNWATCH']);
  }

  /// watch
  Future<Object> watch(List<String> keys) async {
    return tier0.execute(['WATCH', ...keys]);
  }

  ///  ------------------------------   scripting  ------------------------------

  ///  ------------------------------   connection  ------------------------------

  /// auth
  Future<Object> auth(String password) async {
    return tier0.execute(['AUTH', password]);
  }

  /// ping
  Future<Object> ping() async {
    return tier0.execute(['PING']);
  }

  /// select
  Future<Object> select(int index) async {
    return tier0.execute(['SELECT', index]);
  }

  /// hello
  Future<Object> hello(int protover) async {
    // print("tier0.client.respType: ${tier0.client.respType}");
    return tier0.execute(['HELLO', protover]);
  }

  ///  ------------------------------   server  ------------------------------

  /// clientList
  Future<Object> clientList() async {
    return tier0.execute(['CLIENT', 'LIST']);
  }

  /// info
  Future<Object> info(String? section) async {
    return tier0.execute([
      'INFO',
      if (section != null) section,
    ]);
  }

  /// dbsize
  Future<Object> dbsize() async {
    return tier0.execute(['DBSIZE']);
  }

  /// flushAll
  Future<Object> flushAll({bool? doAsync}) async {
    return tier0.execute([
      'FLUSHALL',
      if (doAsync != null) doAsync ? 'ASYNC' : 'SYNC',
    ]);
  }

  /// flushDb
  Future<Object> flushDb({bool? doAsync}) async {
    return tier0.execute([
      'FLUSHDB',
      if (doAsync != null) doAsync ? 'ASYNC' : 'SYNC',
    ]);
  }

  /// slowlogGet
  Future<Object> slowlogGet(int? count) async {
    return tier0.execute([
      'SLOWLOG',
      'GET',
      if (count != null) '$count',
    ]);
  }

  /// slowlogLen
  Future<Object> slowlogLen() async {
    return tier0.execute(['SLOWLOG', 'LEN']);
  }

  /// slowlogReset
  Future<Object> slowlogReset() async {
    return tier0.execute(['SLOWLOG', 'RESET']);
  }

  ///  ------------------------------   json  ------------------------------

  /// jsonArrAppend
  Future<Object> jsonArrAppend({
    required String key,
    String path = '\$',
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
  Future<Object> jsonArrIndex({
    required String key,
    String path = '\$',
    required Object value,
    int? start,
    int? end,
  }) async {
    return tier0.execute([
      'JSON.ARRINDEX',
      key,
      path,
      value,
      if (start != null) start,
      if (end != null) end,
    ]);
  }

  /// jsonArrInsert
  Future<Object> jsonArrInsert({
    required String key,
    String path = '\$',
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
  Future<Object> jsonArrLen({
    required String key,
    String path = '\$',
  }) async {
    return tier0.execute([
      'JSON.ARRLEN',
      key,
      path,
    ]);
  }

  /// jsonArrPop
  Future<Object> jsonArrPop({
    required String key,
    String path = '\$',
    index = 0,
  }) async {
    return tier0.execute([
      'JSON.ARRPOP',
      key,
      path,
      index,
    ]);
  }

  /// jsonArrTrim
  Future<Object> jsonArrTrim({
    required String key,
    String path = '\$',
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
  Future<Object> jsonClear({
    required String key,
    String path = '\$',
  }) async {
    return tier0.execute([
      'JSON.CLEAR',
      key,
      path,
    ]);
  }

  /// jsonDebug
  Future<Object> jsonDebug() async {
    return tier0.execute(['JSON.DEBUG']);
  }

  /// jsonDebugHelp
  Future<Object> jsonDebugHelp() async {
    return tier0.execute(['JSON.DEBUG HELP']);
  }

  /// jsonDebugMemory
  Future<Object> jsonDebugMemory({
    required String key,
    String path = '\$',
  }) async {
    return tier0.execute([
      'JSON.DEBUG MEMORY',
      key,
      path,
    ]);
  }

  /// jsonDel
  Future<Object> jsonDel({required String key, String path = '\$'}) async {
    return tier0.execute([
      'JSON.DEL',
      '$key',
      '$path',
    ]);
  }

  /// jsonForget
  Future<Object> jsonForget({
    required String key,
    String path = '\$',
  }) async {
    return tier0.execute([
      'JSON.FORGET',
      '$key',
      '$path',
    ]);
  }

  /// jsonGet
  Future<Object> jsonGet({required String key, String path = '\$'}) async {
    return tier0.execute(['JSON.GET', '$key', '$path']);
  }

  /// jsonMerge
  Future<Object> jsonMerge({
    required String key,
    String path = '\$',
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
  Future<Object> jsonMget(
      {required List<String> keys, String path = '\$'}) async {
    return tier0.execute(['JSON.MGET', ...keys, '$path']);
  }

  /// jsonMset
  Future<Object> jsonMset({
    required String key,
    String path = '\$',
    required Object value,
  }) async {
    return tier0.execute(['JSON.MSET', key, '$path', value]);
  }

  /// jsonNumincrby
  Future<Object> jsonNumincrby({
    required String key,
    String path = '\$',
    required Object value,
  }) async {
    return tier0.execute(['JSON.NUMINCRBY', key, '$path', value]);
  }

  /// jsonNummultby
  Future<Object> jsonNummultby({
    required String key,
    String path = '\$',
    required Object value,
  }) async {
    return tier0.execute(['JSON.NUMMULTBY', key, '$path', value]);
  }

  /// jsonObjkeys
  Future<Object> jsonObjkeys({
    required String key,
    String path = '\$',
  }) async {
    return tier0.execute(['JSON.OBJKEYS', key, '$path']);
  }

  /// jsonObjlen
  Future<Object> jsonObjlen({
    required String key,
    String path = '\$',
  }) async {
    return tier0.execute(['JSON.OBJLEN', key, '$path']);
  }

  /// jsonResp
  Future<Object> jsonResp({
    required String key,
    String path = '\$',
  }) async {
    return tier0.execute(['JSON.RESP', key, '$path']);
  }

  /// jsonSet
  /// # The NX option is used, set if the specified path does not exist, not set if it already exists and returns nil
  /// # The XX option is used, set when the specified path exists, not set if it does not and returns nil
  /// # 使用了NX选项，当指定的路径不存在时则设置，如果已经存在则不设置并返回nil
  /// # 使用了XX选项，当指定的路径存在时则设置，如果不存在则不设置并返回nil
  Future<Object> jsonSet({
    required String key,
    String path = '\$',
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
  Future<Object> jsonStrappend({
    required String key,
    String path = '\$',
    required Object value,
  }) async {
    return tier0.execute(['JSON.STRAPPEND', key, '$path', value]);
  }

  /// jsonStrlen
  Future<Object> jsonStrlen({
    required String key,
    String path = '\$',
  }) async {
    return tier0.execute(['JSON.STRLEN', key, '$path']);
  }

  /// jsonToggle
  Future<Object> jsonToggle({
    required String key,
    String path = '\$',
  }) async {
    return tier0.execute(['JSON.TOGGLE', key, '$path']);
  }

  /// jsonType
  Future<Object> jsonType({
    required String key,
    String path = '\$',
  }) async {
    return tier0.execute(['JSON.TYPE', key, '$path']);
  }

  ///  ------------------------------   Commands  ------------------------------

  /// moduleList
  Future<Object> moduleList() async {
    return tier0.execute(['MODULE', 'LIST']);
  }

  /////////////////////////////////////////////////////////////////////////
}

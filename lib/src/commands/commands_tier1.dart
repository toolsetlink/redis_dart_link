part of commands;

///
/// The mode when to set a value for a key.
/// 设置键值的模式。
///
enum SetMode {
  onlyIfNotExists,
  onlyIfExists,
}

///
/// The mode how to handle expiration.
/// 如何处理过期的模式。
///
class ExpireMode {
  final DateTime? timestamp;
  final Duration? time;

  ExpireMode.timestamp(this.timestamp) : time = null;
  ExpireMode.time(this.time) : timestamp = null;
  ExpireMode.keepTtl()
      : timestamp = null,
        time = null;
}

///
/// Where to insert a value.
/// 在哪里插入值。
///
class InsertMode {
  static const before = InsertMode._('BEFORE');
  static const after = InsertMode._('AFTER');

  final String _value;

  const InsertMode._(this._value);
}

///
/// Type of a Redis client.
/// Redis客户端的类型。
///
class ClientType {
  static const normal = ClientType._('normal');
  static const master = ClientType._('master');
  static const replica = ClientType._('replica');
  static const pubsub = ClientType._('pubsub');

  final String _value;

  const ClientType._(this._value);
}

///
/// Commands of tier 1 always return a [RespType]. It is up
/// to the consumer to convert the result correctly into the
/// concrete subtype.
///
/// 第一级的命令总是返回一个[RespType]。再上级将结果正确地转换为具体子类型。
///
class RespCommandsTier1 {
  final RespCommandsTier0 tier0;

  RespCommandsTier1(RespClient client) : tier0 = RespCommandsTier0(client);
  RespCommandsTier1.tier0(this.tier0);

  Future<RespType> execute(List<Object> command) async {
    return tier0.execute([...command]);
  }

  ///  ------------------------------   Key  ------------------------------

  Future<RespType> del(List<String> keys) async {
    return tier0.execute(['DEL', ...keys]);
  }

  Future<RespType> exists(List<String> keys) async {
    return tier0.execute(['EXISTS', ...keys]);
  }

  Future<RespType> expire(String key, Duration timeout) async {
    return tier0.execute(['EXPIRE', key, timeout.inSeconds]);
  }

  Future<RespType> pexpire(String key, Duration timeout) async {
    return tier0.execute(['PEXPIRE', key, timeout.inMilliseconds]);
  }

  Future<RespType> rename(String keyName, String newKeyName) async {
    return tier0.execute([
      'RENAME',
      keyName,
      newKeyName,
    ]);
  }

  Future<RespType> scan(int cursor, {String? pattern, int? count}) async {
    return tier0.execute([
      'SCAN',
      '$cursor',
      if (pattern != null) ...['MATCH', pattern],
      if (count != null) ...['COUNT', count],
    ]);
  }

  Future<RespType> ttl(String key) async {
    return tier0.execute(['TTL', key]);
  }

  Future<RespType> type(String key) async {
    return tier0.execute(['TYPE', key]);
  }

  ///  ------------------------------   String  ------------------------------

  Future<RespType> decr(String key) async {
    return tier0.execute(['DECR', key]);
  }

  Future<RespType> decrby(String key, int decrement) async {
    return tier0.execute(['DECRBY', key, '$decrement']);
  }

  Future<RespType> get(String key) async {
    return tier0.execute(['GET', key]);
  }

  Future<RespType> incr(String key) async {
    return tier0.execute(['INCR', key]);
  }

  Future<RespType> incrby(String key, int increment) async {
    return tier0.execute(['INCRBY', key, '$increment']);
  }

  // EX 相对过期时间 以秒为单位设置过期时间
  // EXAT 绝对过期时间 以秒为单位的UNIX时间戳所对应的时间为过期时间
  // PX 相对过期时间 以毫秒为单位设置过期时间
  // PXAT 绝对过期时间 以毫秒为单位的UNIX时间戳所对应的时间为过期时间
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

  Future<RespType> hsetnx(String key, String field, Object value) async {
    return tier0.execute(['HSETNX', key, field, value]);
  }

  Future<RespType> hmget(String key, List<String> fields) async {
    return tier0.execute(['HMGET', key, ...fields]);
  }

  //
  Future<RespType> hdel(String key, List<String> fields) async {
    return tier0.execute(['HDEL', key, ...fields]);
  }

  Future<RespType> hexists(String key, String field) async {
    return tier0.execute(['HEXISTS', key, field]);
  }

  Future<RespType> hget(String key, String field) async {
    return tier0.execute(['HGET', key, field]);
  }

  Future<RespType> hgetall(String key) async {
    return tier0.execute([
      'HGETALL',
      key,
    ]);
  }

  Future<RespType> hkeys(String key) async {
    return tier0.execute(['HKEYS', key]);
  }

  Future<RespType> hlen(String key) async {
    return tier0.execute(['HLEN', key]);
  }

  Future<RespType> hset(String key, String field, Object value) async {
    return tier0.execute(['HSET', key, field, value]);
  }

  Future<RespType> hmset(String key, Map<Object, Object> keysAndValues) async {
    return tier0.execute([
      'HMSET',
      key,
      ...keysAndValues.entries.expand((e) => [e.key, e.value]),
    ]);
  }

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

  Future<RespType> hvals(String key) async {
    return tier0.execute(['HVALS', key]);
  }

  ///  ------------------------------   List  ------------------------------

  Future<RespType> blpop(List<String> keys, int timeout) async {
    return tier0.execute(['BLPOP', ...keys, timeout]);
  }

  Future<RespType> brpop(List<String> keys, int timeout) async {
    return tier0.execute(['BRPOP', ...keys, timeout]);
  }

  Future<RespType> brpoplpush(
      String source, String destination, int timeout) async {
    return tier0.execute(['BRPOPLPUSH', source, destination, timeout]);
  }

  Future<RespType> lindex(String key, int index) async {
    return tier0.execute(['LINDEX', key, index]);
  }

  Future<RespType> linsert(
      String key, InsertMode insertMode, Object pivot, Object value) async {
    return tier0.execute(['LINSERT', key, insertMode._value, pivot, value]);
  }

  Future<RespType> llen(String key) async {
    return tier0.execute(['LLEN', key]);
  }

  Future<RespType> lpop(String key) async {
    return tier0.execute(['LPOP', key]);
  }

  Future<RespType> lpush(String key, List<Object> values) async {
    return tier0.execute(['LPUSH', key, ...values]);
  }

  Future<RespType> lpushx(String key, List<Object> values) async {
    return tier0.execute(['LPUSHX', key, ...values]);
  }

  Future<RespType> lrange(String key, int start, int stop) async {
    return tier0.execute(['LRANGE', key, start, stop]);
  }

  Future<RespType> lrem(String key, int count, Object value) async {
    return tier0.execute(['LREM', key, count, value]);
  }

  Future<RespType> lset(String key, int index, Object value) async {
    return tier0.execute(['LSET', key, index, value]);
  }

  Future<RespType> ltrim(String key, int start, int stop) async {
    return tier0.execute(['LTRIM', key, start, stop]);
  }

  Future<RespType> rpop(String key) async {
    return tier0.execute(['RPOP', key]);
  }

  Future<RespType> rpoplpush(String source, String destination) async {
    return tier0.execute(['RPOPLPUSH', source, destination]);
  }

  Future<RespType> rpush(String key, List<Object> values) async {
    return tier0.execute(['RPUSH', key, ...values]);
  }

  Future<RespType> rpushx(String key, List<Object> values) async {
    return tier0.execute(['RPUSHX', key, ...values]);
  }

  ///  ------------------------------   Set  ------------------------------

  Future<RespType> sadd(String key, List<Object> values) async {
    return tier0.execute(['SADD', key, ...values]);
  }

  Future<RespType> scard(String key) async {
    return tier0.execute(['SCARD', key]);
  }

  Future<RespType> smembers(String key) async {
    return tier0.execute(['SMEMBERS', key]);
  }

  Future<RespType> srem(String key, List<Object> members) async {
    return tier0.execute(['SREM', key, ...members]);
  }

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

  Future<RespType> zadd(String key, Map<Object, double> values) async {
    List<Object> params = ['ZADD', key];

    values.forEach((member, score) {
      params.add(score);
      params.add(member);
    });

    return tier0.execute(params);
  }

  Future<RespType> zcard(String key) async {
    return tier0.execute(['ZCARD', key]);
  }

  Future<RespType> zrange(String key, int start, int stop) async {
    return tier0.execute(['ZRANGE', key, start, stop, 'WITHSCORES']);
  }

  Future<RespType> zrem(String key, List<Object> members) async {
    return tier0.execute(['ZREM', key, ...members]);
  }

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

  Stream<RespType> psubscribe(List<String> pattern) {
    return tier0.psubscribe(pattern);
  }

  Stream<RespType> subscribe(List<String> channels) {
    return tier0.subscribe(channels);
  }

  Future<RespType> publish(String channel, Object message) async {
    return tier0.execute(['PUBLISH', channel, message]);
  }

  Future<RespType> unsubscribe(Iterable<String> channels) async {
    return tier0.execute(['UNSUBSCRIBE', ...channels]);
  }

  ///  ------------------------------   transactions  ------------------------------

  Future<RespType> discard() async {
    return tier0.execute(['DISCARD']);
  }

  Future<RespType> exec() async {
    return tier0.execute(['EXEC']);
  }

  Future<RespType> multi() async {
    return tier0.execute(['MULTI']);
  }

  Future<RespType> unwatch() async {
    return tier0.execute(['UNWATCH']);
  }

  Future<RespType> watch(List<String> keys) async {
    return tier0.execute(['WATCH', ...keys]);
  }

  ///  ------------------------------   scripting  ------------------------------

  ///  ------------------------------   connection  ------------------------------

  Future<RespType> auth(String password) async {
    return tier0.execute(['AUTH', password]);
  }

  Future<RespType> ping() async {
    return tier0.execute(['PING']);
  }

  Future<RespType> select(int index) async {
    return tier0.execute(['SELECT', index]);
  }

  ///  ------------------------------   server  ------------------------------

  Future<RespType> clientList() async {
    return tier0.execute(['CLIENT', 'LIST']);
  }

  Future<RespType> info(String? section) async {
    return tier0.execute([
      'INFO',
      if (section != null) section,
    ]);
  }

  Future<RespType> dbsize() async {
    return tier0.execute(['DBSIZE']);
  }

  Future<RespType> flushAll({bool? doAsync}) async {
    return tier0.execute([
      'FLUSHALL',
      if (doAsync != null) doAsync ? 'ASYNC' : 'SYNC',
    ]);
  }

  Future<RespType> flushDb({bool? doAsync}) async {
    return tier0.execute([
      'FLUSHDB',
      if (doAsync != null) doAsync ? 'ASYNC' : 'SYNC',
    ]);
  }

  Future<RespType> slowlogGet(int? count) async {
    return tier0.execute([
      'SLOWLOG',
      'GET',
      if (count != null) '$count',
    ]);
  }

  Future<RespType> slowlogLen() async {
    return tier0.execute(['SLOWLOG', 'LEN']);
  }

  Future<RespType> slowlogReset() async {
    return tier0.execute(['SLOWLOG', 'RESET']);
  }

  ///  ------------------------------   json  ------------------------------

  // # 使用了NX选项，当指定的路径不存在时则设置，如果已经存在则不设置并返回nil
  // # 使用了XX选项，当指定的路径存在时则设置，如果不存在则不设置并返回nil
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

  Future<RespType> jsonGet({required String key, String path = r'$'}) async {
    return tier0.execute(['JSON.GET', '$key', '$path']);
  }

  Future<RespType> jsonDel({required String key, String path = r'$'}) async {
    return tier0.execute(['JSON.DEL', '$key', '$path']);
  }

  Future<RespType> jsonMget(
      {required List<String> key, String path = r'$'}) async {
    return tier0.execute(['JSON.MGET', ...key, '$path']);
  }

  ///  ------------------------------   Commands  ------------------------------
  Future<RespType> moduleList() async {
    return tier0.execute(['MODULE', 'LIST']);
  }

  /////////////////////////////////////////////////////////////////////////
}

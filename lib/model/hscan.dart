part of model;

/// Hscan
class Hscan {
  /// 游标
  final int cursor;

  /// key列表
  final Map<String, String> keys;

  /// Hscan
  Hscan({
    required this.cursor,
    required this.keys,
  });

  /// fromResult
  factory Hscan.fromResult(Object result) {
    int _cursor = 0;
    Map<String, String> _keys = {};

    if (result is RespType2<dynamic>) {
      final result1 = result.toArray().payload;
      if (result1 != null && result1.length == 2) {
        final element1 = result1[0] as RespBulkString2;
        final payload1 = element1.payload;
        if (payload1 != null) {
          _cursor = int.parse(payload1);
        }
        final element2 = result1[1] as RespArray2;
        final payload2 = element2.payload;
        if (payload2 != null) {
          // 将原来处理列表的逻辑改为处理映射
          for (var i = 0; i < payload2.length; i += 2) {
            var keyItem = payload2[i] as RespBulkString2;
            var valueItem = payload2[i + 1] as RespBulkString2;
            if (keyItem.payload != null && valueItem.payload != null) {
              _keys[keyItem.payload!] = valueItem.payload!;
            }
          }
        }
      }

      return Hscan(
        cursor: _cursor,
        keys: _keys,
      );
    }

    final result1 = (result as RespType3).toArray().payload;
    if (result1 != null && result1.length == 2) {
      final element1 = result1[0] as RespBulkString2;
      final payload1 = element1.payload;
      if (payload1 != null) {
        _cursor = int.parse(payload1);
      }
      final element2 = result1[1] as RespArray2;
      final payload2 = element2.payload;
      if (payload2 != null) {
        // 将原来处理列表的逻辑改为处理映射
        for (var i = 0; i < payload2.length; i += 2) {
          var keyItem = payload2[i] as RespBulkString2;
          var valueItem = payload2[i + 1] as RespBulkString2;
          if (keyItem.payload != null && valueItem.payload != null) {
            _keys[keyItem.payload!] = valueItem.payload!;
          }
        }
      }
    }

    return Hscan(
      cursor: _cursor,
      keys: _keys,
    );
  }

  @override
  String toString() {
    String keyValuePairs =
        keys.entries.map((entry) => '${entry.key}: ${entry.value}').join(', ');
    return 'Hscan(cursor: $cursor, keys: {$keyValuePairs})';
  }
}

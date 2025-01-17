part of models;

/// Zscan
class Zscan {
  /// 游标
  final int cursor;

  /// key列表
  final Map<String, double> keys;

  Zscan({
    required this.cursor,
    required this.keys,
  });

  factory Zscan.fromResult(Object reqResult) {
    var _cursor = 0;
    var _keys = <String, double>{};

    if (reqResult is RespType2<dynamic>) {
      final result = reqResult.toArray().payload;
      if (result != null && result.length == 2) {
        final element1 = result[0] as RespBulkString2;
        final payload1 = element1.payload;
        if (payload1 != null) {
          _cursor = int.parse(payload1);
        }

        final element2 = result[1] as RespArray2;
        final payload2 = element2.payload;

        if (payload2 != null) {
          // 将原来处理列表的逻辑改为处理映射
          for (var i = 0; i < payload2.length; i += 2) {
            var keyItem = payload2[i] as RespBulkString2;
            var valueItem = payload2[i + 1] as RespBulkString2;
            if (keyItem.payload != null && valueItem.payload != null) {
              _keys[keyItem.payload!] = double.parse(valueItem.payload!);
            }
          }
        }
      }

      return Zscan(cursor: _cursor, keys: _keys);
    }

    final result = (reqResult as RespType3<dynamic>).toArray().payload;
    if (result != null && result.length == 2) {
      final element1 = result[0] as RespBulkString2;
      final payload1 = element1.payload;
      if (payload1 != null) {
        _cursor = int.parse(payload1);
      }

      final element2 = result[1] as RespArray3;
      final payload2 = element2.payload;

      if (payload2 != null) {
        // 将原来处理列表的逻辑改为处理映射
        for (var i = 0; i < payload2.length; i += 2) {
          var keyItem = payload2[i] as RespBulkString2;
          var valueItem = payload2[i + 1] as RespBulkString2;
          if (keyItem.payload != null && valueItem.payload != null) {
            _keys[keyItem.payload!] = double.parse(valueItem.payload!);
          }
        }
      }
    }

    return Zscan(cursor: _cursor, keys: _keys);
  }
}

part of model;

/// Sscan
class Sscan {
  /// 游标
  final int cursor;

  /// key列表
  final List<String?> keys;

  /// Sscan
  Sscan({
    required this.cursor,
    required this.keys,
  });

  /// fromResult
  factory Sscan.fromResult(Object result) {
    int _cursor = 0;
    List<String> _keys = [];

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
          _keys = payload2
              .cast<RespBulkString2>()
              .map((e) => e.payload!)
              .toList(growable: false);
        }
      }
      return Sscan(cursor: _cursor, keys: _keys);
    }

    final result1 = (result as RespType3<dynamic>).toArray().payload;
    if (result1 != null && result1.length == 2) {
      final element1 = result1[0] as RespBulkString2;
      final payload1 = element1.payload;
      if (payload1 != null) {
        _cursor = int.parse(payload1);
      }

      final element2 = result1[1] as RespArray2;
      final payload2 = element2.payload;
      if (payload2 != null) {
        _keys = payload2
            .cast<RespBulkString2>()
            .map((e) => e.payload!)
            .toList(growable: false);
      }
    }

    return Sscan(cursor: _cursor, keys: _keys);
  }
}

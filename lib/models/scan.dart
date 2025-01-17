part of models;

/// Scan
class Scan {
  /// 游标
  final int cursor;

  /// keys 列表
  final List<String> keys;

  Scan({
    required this.cursor,
    required this.keys,
  });

  /// fromResult
  factory Scan.fromResult(Object reqResult) {
    int _cursor = 0;
    List<String> _keys = [];

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
          _keys = payload2
              .cast<RespBulkString2>()
              .map((e) => e.payload!)
              .toList(growable: false);
        }
      }

      return Scan(
        cursor: _cursor,
        keys: _keys,
      );
    }

    final result = (reqResult as RespType3<dynamic>).toArray().payload;
    if (result != null && result.length == 2) {
      final element1 = result[0] as RespBulkString2;
      final payload1 = element1.payload;
      if (payload1 != null) {
        _cursor = int.parse(payload1);
      }

      final element2 = result[1] as RespArray2;
      final payload2 = element2.payload;
      if (payload2 != null) {
        _keys = payload2
            .cast<RespBulkString2>()
            .map((e) => e.payload!)
            .toList(growable: false);
      }
    }

    return Scan(
      cursor: _cursor,
      keys: _keys,
    );
  }
}

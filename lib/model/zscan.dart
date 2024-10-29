import '../src/client.dart';

class Zscan {
  final int cursor; // 游标
  final Map<String, double> keys; // key列表

  Zscan({
    required this.cursor,
    required this.keys,
  });

  factory Zscan.fromResult(List<RespType<dynamic>>? result) {
    var _cursor = 0;
    var _keys = <String, double>{};

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
            _keys[keyItem.payload!] = double.parse(valueItem.payload!);
          }
        }
      }
    }

    return Zscan(cursor: _cursor, keys: _keys);
  }
}

import '../client/client.dart';

class Scan {
  final int cursor; // 游标
  final List<String> keys; // key列表

  Scan({
    required this.cursor,
    required this.keys,
  });

  factory Scan.fromResult(List<RespType<dynamic>>? result) {
    int _cursor = 0;
    List<String> _keys = [];

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

    return Scan(
      cursor: _cursor,
      keys: _keys,
    );
  }
}

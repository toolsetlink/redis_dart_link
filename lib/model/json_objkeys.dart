import '../src/client.dart';

/// JsonObjkeys
class JsonObjkeys {
  final List<String> values;

  /// JsonObjkeys
  JsonObjkeys({
    required this.values,
  });

  factory JsonObjkeys.fromResult(List<RespType<dynamic>>? result) {
    print("result: ${result.toString()}");

    List<String> _values = [];

    // if (result != null && result.length == 2) {
    //   final element1 = result[0] as RespBulkString;
    //   final payload1 = element1.payload;
    //   if (payload1 != null) {
    //     _cursor = int.parse(payload1);
    //   }
    //
    //   final element2 = result[1] as RespArray;
    //   final payload2 = element2.payload;
    //   if (payload2 != null) {
    //     // 将原来处理列表的逻辑改为处理映射
    //     for (var i = 0; i < payload2.length; i += 2) {
    //       var keyItem = payload2[i] as RespBulkString;
    //       var valueItem = payload2[i + 1] as RespBulkString;
    //       if (keyItem.payload != null && valueItem.payload != null) {
    //         _values[keyItem.payload!] = valueItem.payload!;
    //       }
    //     }
    //   }
    // }

    return JsonObjkeys(
      values: _values,
    );
  }
}

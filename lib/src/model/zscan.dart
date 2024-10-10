import '../client/commands.dart';

class Zscan {
  final int cursor; // 游标
  final Map<String, double> keys; // key列表

  Zscan({
    required this.cursor,
    required this.keys,
  });

  factory Zscan.fromResult(ZscanResult result) {
    // 转换 _keys 中的 String 值为 double
    Map<String, double> convertedKeys = {};
    result.keys.forEach((key, value) {
      convertedKeys[key] = double.parse(value); // 将 String 转换为 double
    });

    return Zscan(
      cursor: result.cursor,
      keys: convertedKeys,
    );
  }
}

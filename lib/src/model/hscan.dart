import '../client/commands.dart';

class Hscan {
  final int cursor; // 游标
  final Map<String, String> keys; // key列表

  Hscan({
    required this.cursor,
    required this.keys,
  });

  factory Hscan.fromResult(HscanResult result) {
    return Hscan(
      cursor: result.cursor,
      keys: result.keys,
    );
  }
}

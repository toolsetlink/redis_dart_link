import '../client/commands.dart';

class Sscan {
  final int cursor; // 游标
  final List<String?> keys; // key列表

  Sscan({
    required this.cursor,
    required this.keys,
  });

  factory Sscan.fromResult(SscanResult result) {
    return Sscan(
      cursor: result.cursor,
      keys: result.keys,
    );
  }
}

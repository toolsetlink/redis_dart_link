import '../client/commands.dart';

class Scan {
  final int cursor; // 游标
  final List<String?> keys; // key列表

  Scan({
    required this.cursor,
    required this.keys,
  });

  factory Scan.fromResult(ScanResult result) {
    return Scan(
      cursor: result.cursor,
      keys: result.keys,
    );
  }
}

import '../client/commands.dart';

class SlowlogGet {
  final int cursor; // 游标
  final List<String?> keys; // key列表

  SlowlogGet({
    required this.cursor,
    required this.keys,
  });

  factory SlowlogGet.fromResult(SlowlogGetResult result) {
    return SlowlogGet(
      cursor: result.cursor,
      keys: result.keys,
    );
  }
}

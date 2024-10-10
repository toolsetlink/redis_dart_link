import '../client/commands.dart';

class Set {
  final bool ok; // 是否成功
  final Object? oldVal; // 旧val

  Set({
    required this.ok,
    required this.oldVal,
  });

  factory Set.fromResult(SetResult result) {
    return Set(
      ok: result.ok,
      oldVal: result.old,
    );
  }

  // 重写toString方法
  @override
  String toString() {
    return '{ok: $ok, oldVal: $oldVal}';
  }
}

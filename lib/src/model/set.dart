import 'package:redis_dart_link/src/client/client.dart';

class Set {
  final bool ok; // 是否成功
  final Object? oldVal; // 旧val

  Set({
    required this.ok,
    required this.oldVal,
  });

  factory Set.fromResult(RespType<dynamic> result) {
    return result.handleAs<Set>(
      simple: (_) => Set(ok: true, oldVal: null),
      bulk: (type) => Set(ok: type.payload != null, oldVal: type.payload),
      error: (_) => Set(ok: false, oldVal: null),
    );
  }

  // 重写toString方法
  @override
  String toString() {
    return '{ok: $ok, oldVal: $oldVal}';
  }
}

part of model;

/// Set
class Set {
  /// ok 是否成功
  final bool ok;

  /// oldVal
  final Object? oldVal;

  /// Set
  Set({
    required this.ok,
    required this.oldVal,
  });

  /// fromResult
  factory Set.fromResult(Object result) {
    if (result is RespType2<dynamic>) {
      return result.handleAs<Set>(
        simple: (_) => Set(ok: true, oldVal: null),
        bulk: (type) => Set(ok: type.payload != null, oldVal: type.payload),
        error: (_) => Set(ok: false, oldVal: null),
      );
    }

    return (result as RespType3<dynamic>).handleAs<Set>(
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

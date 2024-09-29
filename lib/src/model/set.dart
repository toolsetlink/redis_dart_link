class SetModel {
  final bool ok; // 是否成功
  final Object? oldVal; // 旧val

  SetModel({
    required this.ok,
    required this.oldVal,
  });

  factory SetModel.fromVal(ok, oldVal) {
    return SetModel(
      ok: ok,
      oldVal: oldVal,
    );
  }

  // 重写toString方法
  @override
  String toString() {
    return '{ok: $ok, oldVal: $oldVal}';
  }
}

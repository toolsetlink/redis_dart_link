part of models;

/// ModuleList
class ModuleList {
  /// key列表
  final List<ModuleListInfo> list;

  /// ModuleList
  ModuleList({
    required this.list,
  });

  /// fromResult
  factory ModuleList.fromResult(Object reqResult) {
    if (reqResult is RespType2<dynamic>) {
      final result = reqResult.toArray().payload;
      if (result == null) return ModuleList(list: []);

      List<ModuleListInfo> _list = result.map((item) {
        final payload1 = item.payload;

        // 确保 payload1 不为空，并且至少有 4 个元素
        if (payload1 != null && payload1.length > 3) {
          return ModuleListInfo(
            name: payload1[1].payload?.toString() ?? '',
            ver: payload1[3].payload as int? ?? 0,
          );
        } else {
          // 如果 payload 不符合预期，可以返回一个默认值或其他处理逻辑
          return ModuleListInfo(name: 'Unknown', ver: 0);
        }
      }).toList(growable: false);

      return ModuleList(list: _list);
    }

    final result = (reqResult as RespType3<dynamic>).toArray().payload;
    if (result == null) return ModuleList(list: []);

    List<ModuleListInfo> _list = result.map((item) {
      final payload1 = item.payload;

      // 确保 payload1 不为空，并且至少有 4 个元素
      if (payload1 != null && payload1.length > 3) {
        return ModuleListInfo(
          name: payload1[1].payload?.toString() ?? '',
          ver: payload1[3].payload as int? ?? 0,
        );
      } else {
        // 如果 payload 不符合预期，可以返回一个默认值或其他处理逻辑
        return ModuleListInfo(name: 'Unknown', ver: 0);
      }
    }).toList(growable: false);

    return ModuleList(list: _list);
  }

  @override
  String toString() {
    return 'ModuleList(list: [${list.join(", ")}])';
  }
}

/// ModuleListInfo
class ModuleListInfo {
  /// 模块名称
  final String name;

  /// 模块版本
  final int ver;

  /// ModuleListInfo
  ModuleListInfo({
    required this.name,
    required this.ver,
  });

  @override
  String toString() {
    return 'ModuleListInfo(name: $name, ver: $ver)';
  }
}

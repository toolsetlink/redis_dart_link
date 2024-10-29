import '../src/client.dart';

class ModuleList {
  final List<ModuleListInfo> list; // key列表

  ModuleList({
    required this.list,
  });

  factory ModuleList.fromResult(List<RespType<dynamic>>? result) {
    if (result == null) return ModuleList(list: []);

    List<ModuleListInfo> _list = result.map((item) {
      var item1 = item as RespArray;
      final payload1 = item1.payload;

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

class ModuleListInfo {
  final String name; // 模块名称
  final int ver; // 模块版本

  ModuleListInfo({
    required this.name,
    required this.ver,
  });

  @override
  String toString() {
    return 'ModuleListInfo(name: $name, ver: $ver)';
  }
}

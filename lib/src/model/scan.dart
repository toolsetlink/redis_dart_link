class Scan {
  final String cursor; // 游标
  final List<String?> list; // key列表

  Scan({
    required this.cursor,
    required this.list,
  });

  factory Scan.fromList(List<String?>? list) {
    if (list == null || list.isEmpty) {
      return Scan(
        cursor: '',
        list: [],
      );
    }

    return Scan(
      cursor: list[0]!,
      list: list.sublist(1).cast<String>(),
    );
  }
}

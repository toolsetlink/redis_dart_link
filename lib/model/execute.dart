part of model;

/// Execute
class Execute {
  final List<dynamic> list;

  /// Execute
  Execute({
    required this.list,
  });

  /// fromResult
  factory Execute.fromResult(RespType2<dynamic> result) {
    return result.handleAs<Execute>(
      integer: (type) => Execute(list: [type.payload.toString()]),
      simple: (type) => Execute(list: [type.payload]),
      bulk: (type) => Execute(list: type.toBulkString().payload!.split("\r\n")),
      array: (type) =>
          Execute(list: _parseMultiLevelArrayWithNumbering(type.payload!)),
      error: (type) => throw type,
    );
  }

  /// fromResultResp3
  factory Execute.fromResultResp3(RespType3<dynamic> result) {
    return result.handleAs<Execute>(
      integer: (type) => Execute(list: [type.payload.toString()]),
      simple: (type) => Execute(list: [type.payload]),
      bulk: (type) => Execute(list: type.toBulkString().payload!.split("\r\n")),
      array: (type) =>
          Execute(list: _parseMultiLevelArrayWithNumberingResp3(type.payload!)),
      map: (type) =>
          Execute(list: _parseMultiLevelMapWithNumberingResp3(type.payload!)),
      error: (type) => throw type,
    );
  }

  static List<String> _parseMultiLevelArrayWithNumbering(List<RespType2> array,
      [int arrIndex = 1, int arrLevel = 1]) {
    List<String> parsedList = [];

    for (var i = 0; i < array.length; i++) {
      var element = array[i];
      if (element.isArray && element.payload != null) {
        parsedList.addAll(_parseMultiLevelArrayWithNumbering(
            element.payload!, arrIndex, arrLevel + 1));

        // 数组前的序号
        arrIndex++;
      } else {
        // 判断前面是显示序号，还是显示空格
        if (parsedList.length == 0) {
          parsedList.add('${arrIndex}) ${i + 1}) ${element.payload ?? ''}');
        } else {
          String str = '${arrIndex})';
          parsedList
              .add('${' ' * str.length} ${i + 1}) ${element.payload ?? ''}');
        }
      }
    }
    return parsedList;
  }

  static List<String> _parseMultiLevelArrayWithNumberingResp3(
      List<RespType3> array,
      [int arrIndex = 1,
      int arrLevel = 1]) {
    List<String> parsedList = [];

    for (var i = 0; i < array.length; i++) {
      var element = array[i];
      if (element.isArray && element.payload != null) {
        parsedList.addAll(_parseMultiLevelArrayWithNumbering(
            element.payload!, arrIndex, arrLevel + 1));

        // 数组前的序号
        arrIndex++;
      } else {
        // 判断前面是显示序号，还是显示空格
        if (parsedList.length == 0) {
          parsedList.add('${arrIndex}) ${i + 1}) ${element.payload ?? ''}');
        } else {
          String str = '${arrIndex})';
          parsedList
              .add('${' ' * str.length} ${i + 1}) ${element.payload ?? ''}');
        }
      }
    }
    return parsedList;
  }

  static List<String> _parseMultiLevelMapWithNumberingResp3(List<RespType3> map,
      [int arrIndex = 1, int arrLevel = 1]) {
    List<String> parsedList = [];

    for (var i = 0; i < map.length; i++) {
      var element = map[i];
      if (element.isMap && element.payload != null) {
        parsedList.addAll(_parseMultiLevelMapWithNumberingResp3(
            element.payload!, arrIndex, arrLevel + 1));

        // 数组前的序号
        arrIndex++;
      } else {
        // 判断前面是显示序号，还是显示空格
        if (parsedList.length == 0) {
          parsedList.add('${arrIndex}) ${i + 1}) ${element.payload ?? ''}');
        } else {
          String str = '${arrIndex})';
          parsedList
              .add('${' ' * str.length} ${i + 1}) ${element.payload ?? ''}');
        }
      }
    }
    return parsedList;
  }
}

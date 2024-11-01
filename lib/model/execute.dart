import '../src/client.dart';

class Execute {
  final List<dynamic> list;

  Execute({
    required this.list,
  });

  factory Execute.fromResult(RespType<dynamic> result) {
    return result.handleAs<Execute>(
      integer: (type) => Execute(list: [type.payload.toString()]),
      simple: (type) => Execute(list: [type.payload]),
      bulk: (type) => Execute(list: type.toBulkString().payload!.split("\r\n")),
      array: (type) =>
          Execute(list: _parseMultiLevelArrayWithNumbering(type.payload!)),
      error: (type) => throw type,
    );
  }

  static List<String> _parseMultiLevelArrayWithNumbering(List<RespType> array,
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
          // parsedList
          //     .add('${' ' * arrLevel} ${i + 1}) ${element.payload ?? ''}');
          // 使用等宽空格，例如Em Space（'\u2003'）替换原来的空格
          // parsedList.add(
          //     '${'\u2003' * arrLevel}\u2003${i + 1}) ${element.payload ?? ''}');

          String str = '${arrIndex})';
          parsedList
              .add('${' ' * str.length} ${i + 1}) ${element.payload ?? ''}');
          // parsedList.add(
          //     '${'\u2003' * str.length} ${i + 1}) ${element.payload ?? ''}');
        }
      }
    }
    return parsedList;
  }

  static List<dynamic> _parseMultiLevelArray(List<RespType> array) {
    List<dynamic> parsedList = [];
    for (var element in array) {
      if (element.isArray && element.payload != null) {
        parsedList.addAll(_parseMultiLevelArray(element.payload!));
      } else {
        parsedList.add(element.payload);
      }
    }
    print("parsedList: $parsedList");

    return parsedList;
  }
}
